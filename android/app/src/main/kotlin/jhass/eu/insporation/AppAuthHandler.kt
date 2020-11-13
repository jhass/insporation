package jhass.eu.insporation

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import kotlinx.coroutines.channels.Channel
import net.openid.appauth.*
import org.json.JSONObject
import java.sql.Time
import kotlin.coroutines.Continuation
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine

private const val APP_AUTH_CHANNEL = "insporation/appauth"
private const val APP_AUTH_SESSION_CHANNEL = "insporation/appauth_authorization_events"
private val APP_AUTH_REDIRECT_URI : Uri = Uri.parse("eu.jhass.insporation://callback")
private const val TIMEOUT = 30_000L // In Milliseconds

typealias OnLaunchAuthorizationIntent = (intent: Intent, data: String) -> Unit

private suspend inline fun <T> suspendCoroutineWithTimeout(
  timeout: Long,
  crossinline block: (Continuation<T>) -> Unit
) = withTimeout(timeout) {
  suspendCancellableCoroutine(block = block)
}

class AppAuthHandler {
  private val authorizationResponses = Channel<Pair<Intent, String>>()

  fun setup(context: Context, flutterEngine: FlutterEngine, onLaunchAuthorizationIntent: OnLaunchAuthorizationIntent) {
    val authorizationEvents = Channel<AuthorizationEvent>()

    EventChannel(flutterEngine.dartExecutor, APP_AUTH_SESSION_CHANNEL).apply {
      setStreamHandler(QueueEventHandler(authorizationEvents) { event -> event.toMap() })
    }

    MethodChannel(flutterEngine.dartExecutor, APP_AUTH_CHANNEL).apply {
      setMethodCallHandler(CallHandler(context, this, authorizationResponses, authorizationEvents, onLaunchAuthorizationIntent))
    }
  }

  fun process(response: Intent, data: String) {
    GlobalScope.launch { authorizationResponses.send(Pair(response, data)) }
  }
}

private class CallHandler(private val context: Context,
                          private val methodChannel: MethodChannel,
                          private val authorizationResponses: Channel<Pair<Intent, String>>,
                          private val authorizationEvents: Channel<AuthorizationEvent>,
                          private val onLaunchAuthorizationIntent: OnLaunchAuthorizationIntent) : MethodChannel.MethodCallHandler {
  private val authorizationService: AuthorizationService
    get() = AuthorizationService(context)
  private var awaitingAuthorizationResult: Channel<AuthorizationResult<AuthorizationResponse>>? = null

  init {
    GlobalScope.launch { listenForAuthorizationResponses() }
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    GlobalScope.launch(Dispatchers.Main) {
      try {
        val response = dispatch(call)
        if (response != null) {
          result.success(response)
        } else {
          result.notImplemented()
        }
      } catch (e: CallError) {
        result.error(e.code, e.fullMessage(), null)
      } catch (e : Throwable) {
        result.error("unhandled_exception", e.fullMessage(), null)
      }
    }
  }

  private suspend fun dispatch(call: MethodCall): Any? {
    when (call.method) {
      "getAccessToken" -> {
        if (call.hasArgument("session")) {
          return getAccessToken(Session(call.argument<Map<String, Any>>("session")!!)).toMap()
        }
      }
    }

    return null
  }

  private suspend fun getAccessToken(session: Session): Tokens {
    var state = session.state
    var currentSession = session
    if (state == null) {
      Log.d("AppAuth", "Provided session for fetching access token has no authorization, launching authorization process")
      currentSession = authorizeUser(session.userId, session.scopes)
      storeSession(currentSession)
      state = currentSession.state!!
    }

    Log.d("AppAuth", "Fetching access token for ${currentSession.userId}")
    try {
      return suspendCoroutineWithTimeout(TIMEOUT) { continuation ->
        state.performActionWithFreshTokens(authorizationService, state.clientAuthentication) { accessToken, idToken, exception ->
          if (accessToken != null || idToken != null) {
            Log.d("AppAuth", "Got access token for ${currentSession.userId}")
            storeSession(currentSession) // In case the access token was refreshed
            continuation.resume(Tokens(accessToken!!, idToken))
          } else {
            Log.d("AppAuth", "Failed to fetch access token for ${currentSession.userId}: ${exception?.fullMessage()}")
            continuation.resumeWithException(CallError("failed_token_fetch", "Failed to obtain access token"))
          }
        }
      }
    } catch (e : TimeoutCancellationException) {
      throw CallError("timeout_token_fetch", "Timed out while fetching token")
    }
  }

  private suspend fun listenForAuthorizationResponses() {
    Log.d("AppAuth", "Started listening for authorization responses")
    for ((data, sessionData) in authorizationResponses) {
      val session = Session(sessionData)
      val response = AuthorizationResponse.fromIntent(data)
      val exception = AuthorizationException.fromIntent(data)

      val awaitingAuthorizationResult = this.awaitingAuthorizationResult
      if (awaitingAuthorizationResult != null) {
        Log.d("AppAuth", "Handing authorization result for ${session.userId} to waiting authorization call")
        awaitingAuthorizationResult.send(AuthorizationResult(response, exception))
        continue
      }

      if (exception != null) {
        Log.d("AppAuth", "Got failed authorization event: ${exception.fullMessage()}, passing on")
        authorizationEvents.send(AuthorizationEvent(null, exception.fullMessage()))
        continue
      }

      try {
        withContext(Dispatchers.Main) {
          val registration = fetchRegistration(session.userId)
          val authorizedSession = buildSessionFromAuthorization(registration.state!!, session, response!!)
          Log.d("AppAuth", "Publishing new session for ${authorizedSession.userId}")
          authorizationEvents.send(AuthorizationEvent(authorizedSession, null))
        }
      } catch (e: Exception) {
        Log.d("AppAuth", "Failed to complete authorization: ${e.fullMessage()}")
        authorizationEvents.send(AuthorizationEvent(null, e.fullMessage()))
      }
    }

    Log.d("AppAuth", "Stopped listening for authorization responses")
  }

  private suspend fun authorizeUser(userId: String, scopes: String): Session {
    if (awaitingAuthorizationResult != null) {
      Log.d("AppAuth", "Tried to trigger multiple authorizations concurrently")
      throw CallError("concurrent_request", "Cannot start multiple authorizations at once")
    }

    var registration = fetchRegistration(userId)
    if (registration.state == null) {
      Log.d("AppAuth", "Tried to authorize to ${registration.host} which we don't have a registration for yet, triggering it")
      try {
        registration = register(registration.host)
        storeRegistration(registration)
      } catch (e : TimeoutCancellationException) {
        throw CallError("timeout_register", "Timed out while trying to register client")
      }
    }

    val state = registration.state!!
    val request = AuthorizationRequest.Builder(
      state.authorizationServiceConfiguration!!,
      state.lastRegistrationResponse!!.clientId,
      ResponseTypeValues.CODE,
      APP_AUTH_REDIRECT_URI
    )
      .setLoginHint(userId.split('@').first())
      .setPrompt("login")
      .setScope(scopes)
      .build()

    val session = Session(userId, scopes, null)
    val responseChannel = Channel<AuthorizationResult<AuthorizationResponse>>()
    awaitingAuthorizationResult = responseChannel
    Log.d("AppAuth", "Launching authorization for $userId and waiting for result")
    onLaunchAuthorizationIntent(authorizationService.getAuthorizationRequestIntent(request), session.toJson())
    val result = responseChannel.receive()
    Log.d("AppAuth", "Received result for authorization for $userId we've been waiting for")
    responseChannel.close()
    awaitingAuthorizationResult = null

    if (result.exception != null) {
      Log.d("AppAuth", "Failed to authorize $userId: ${result.exception.fullMessage()}")
      throw CallError("failed_authorize", "Failed to authorize user")
    }

    try {
      return buildSessionFromAuthorization(state, session, result.response!!)
    } catch (e : TimeoutCancellationException) {
      throw CallError("timeout_token_fetch", "Timed out while trying to fetch token")
    }
  }

  private suspend fun buildSessionFromAuthorization(registrationState: AuthState, session: Session, authorizationResponse: AuthorizationResponse): Session {
    // Copy registration state, then update it with the authorization response
    val sessionState = AuthState.jsonDeserialize(registrationState.jsonSerialize()).apply { update(authorizationResponse, null) }

    // Exchange authorization code for access and refresh token
    Log.d("AppAuth", "Exchange successful authorization for ${session.userId} for tokens")
    val result = suspendCoroutineWithTimeout<AuthorizationResult<TokenResponse>>(TIMEOUT) { continuation ->
      authorizationService.performTokenRequest(authorizationResponse.createTokenExchangeRequest(), sessionState.clientAuthentication) { response, exception ->
        continuation.resume(AuthorizationResult(response, exception))
      }
    }

    sessionState.update(result.response, result.exception)

    if (result.exception != null) {
      Log.d("AppAuth", "Failed to exchange authorization for ${session.userId} for tokens: ${result.exception.fullMessage()}")
      throw CallError("failed_authorize", "Failed to exchange authorization token")
    }

    Log.d("AppAuth", "Successfully exchanged token for authorization for ${session.userId}")
    session.state = sessionState
    storeSession(session)
    return session
  }

  private suspend fun register(host: String): Registration {
    Log.d("AppAuth", "Starting service discovery for $host")
    val serviceConfig = suspendCoroutineWithTimeout<AuthorizationServiceConfiguration>(TIMEOUT) { continuation ->
      AuthorizationServiceConfiguration.fetchFromIssuer(Uri.Builder().scheme("https").authority(host).build()) { serviceConfig, exception ->
        if (serviceConfig != null) {
          Log.d("AppAuth", "Discovered service config for $host")
          continuation.resume(serviceConfig)
        } else {
          Log.d("AppAuth", "Failed to discover service config for $host: ${exception?.fullMessage()}")
          continuation.resumeWithException(CallError("failed_discovery", "Failed to discover service config"))
        }
      }
    }

    Log.d("AppAuth", "Starting registration to $host")
    val registrationRequest = RegistrationRequest.Builder(serviceConfig, listOf(APP_AUTH_REDIRECT_URI))
      .setAdditionalParameters(mapOf(
        "client_name" to "insporation* ${if (BuildConfig.DEBUG) "debug " else " "}on ${android.os.Build.MODEL}"
      )).build()
    val response = suspendCoroutineWithTimeout<RegistrationResponse>(TIMEOUT) { continuation ->
      authorizationService.performRegistrationRequest(registrationRequest) { response, exception ->
        if (response != null) {
          Log.d("AppAuth", "Successfully registered to $host")
          continuation.resume(response)
        } else {
          Log.d("AppAuth", "Failed to register to $host: ${exception?.fullMessage()}")
          continuation.resumeWithException(CallError("failed_register", "Failed to register"))
        }
      }
    }

    return Registration(host, AuthState(serviceConfig).apply { update(response) })
  }

  private suspend fun fetchRegistration(userId: String): Registration {
    return suspendCoroutine { continuation ->
      methodChannel.invokeMethod("fetchRegistration", userId, object : MethodChannel.Result {
        override fun notImplemented() {
          continuation.resumeWithException(CallError("bad_client", "Client does not provide a way to fetch a registration"))
        }

        override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
          continuation.resumeWithException(CallError("failed_fetch", "Could not fetch registration from client: $errorCode - $errorMessage"))
        }

        @Suppress("UNCHECKED_CAST")
        override fun success(result: Any?) {
          continuation.resume(Registration(result as Map<String, Any?>))
        }
      })
    }
  }

  private fun storeRegistration(registration: Registration) {
    methodChannel.invokeMethod("storeRegistration", registration.toMap())
  }

  private fun storeSession(session: Session) {
    methodChannel.invokeMethod("storeSession", session.toMap())
  }
}


private class CallError(val code: String, message: String, cause: Throwable? = null) : Exception(message, cause)

fun Throwable.fullMessage() : String {
  val builder = StringBuilder()
  var exception : Throwable? = this
  while (exception != null) {
    if (exception is AuthorizationException) {
      builder.append(exception.errorDescription)
      builder.append(" (")
      builder.append(exception.error)
      builder.append(')')
      if (exception.cause != null) {
        builder.append(" - ")
      }
    } else if (exception.message != null) {
      builder.append(exception.message)
      if (exception.cause != null) {
        builder.append(" - ")
      }
    }

    exception = exception.cause
  }
  return builder.toString()
}

private class Registration(val host: String, var state: AuthState?) {
  constructor(data: Map<String, Any?>) : this(data["host"] as String, data["state"]?.let { AuthState.jsonDeserialize(it as String) })

  fun toMap(): Map<String, Any?> = mapOf("host" to host, "state" to state?.jsonSerializeString())
}

private class Session(val userId: String, val scopes: String, var state: AuthState?) {
  constructor(data: Map<String, Any?>) : this(data["userId"] as String, data["scopes"] as String, data["state"]?.let { AuthState.jsonDeserialize(it as String) })
  constructor(data: String) : this(JSONObject(data))
  constructor(data: JSONObject): this(data.getString("userId"), data.getString("scopes"),
      data.optString("state")?.let { if (it == "null") null else it }?.let { AuthState.jsonDeserialize(it) })

  fun toMap(): Map<String, Any?> = mapOf("userId" to userId, "scopes" to scopes, "state" to state?.jsonSerializeString())

  fun toJson(): String = JSONObject(toMap()).toString()
}

private class Tokens(val accessToken: String, val idToken: String?) {
  fun toMap(): Map<String, Any?> = mapOf("accessToken" to accessToken, "idToken" to idToken)
}

private class AuthorizationEvent(val session: Session?, val error: String?) {
  fun toMap(): Map<String, Any?> = mapOf("session" to session?.toMap(), "error" to error)
}

private class AuthorizationResult<T>(val response: T?, val exception: AuthorizationException?)
