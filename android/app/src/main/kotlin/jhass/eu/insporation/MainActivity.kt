package jhass.eu.insporation

import android.content.Intent
import android.net.Uri
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import net.openid.appauth.*

const val APP_AUTH_CHANNEL = "insporation/appauth"
const val APP_AUTH_REQUEST_CODE = 1
val APP_AUTH_REDIRECT_URI : Uri = Uri.parse("eu.jhass.insporation://callback")

fun Throwable.fullMessage() : String {
    val builder = StringBuilder();
    var exception : Throwable?  = this;
    while (exception != null && exception.message != null) {
        builder.append(exception.message)
        exception = exception.cause
        if (exception != null) {
           builder.append(" - ")
        }
    }
    return builder.toString()
}

class MainActivity: FlutterActivity() {
    private var currentAuthState : AuthState = AuthState()
    private var currentAppAuthResult : MethodChannel.Result? = null

    private val authorizationService: AuthorizationService
        get() = AuthorizationService(context)

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, APP_AUTH_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "registerClient" -> {
                        if (call.hasArgument("url")) {
                            handleRegisterClient(call, result, authorizationService)
                        } else {
                            result.notImplemented()
                        }
                    }
                    "authorize" -> {
                        if (call.hasArgument("authState") &&
                            call.hasArgument("username") &&
                            call.hasArgument("scopes")) {
                            handleAuthorize(call, result, authorizationService)
                        } else {
                            result.notImplemented()
                        }
                    }
                    "getAccessToken" -> {
                        if (call.hasArgument("authState")) {
                            handleGetAccessToken(call, result, authorizationService)
                        } else {
                            result.notImplemented()
                        }
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }

    private fun handleRegisterClient(call: MethodCall, result: MethodChannel.Result, authorizationService: AuthorizationService) {
        AuthorizationServiceConfiguration.fetchFromIssuer(Uri.parse(call.argument<String>("url"))) { serviceConfig, exception ->
            handleServiceDiscoveryResponse(result, serviceConfig, exception, authorizationService)
        }
    }

    private fun handleServiceDiscoveryResponse(result: MethodChannel.Result, serviceConfig: AuthorizationServiceConfiguration?, exception: AuthorizationException?, authorizationService: AuthorizationService) {
        if (exception != null) {
            result.error("failed_fetch", "Failed to fetch service config: ${exception.fullMessage()}", null)
            return
        } else if (serviceConfig == null) {
            result.error("failed_fetch", "Got not service config or error", null)
            return
        }

        currentAuthState = AuthState(serviceConfig)
        val registrationRequest = RegistrationRequest.Builder(serviceConfig, listOf(APP_AUTH_REDIRECT_URI))
                .setAdditionalParameters(mapOf(
                    "client_name" to "insporation* on ${android.os.Build.MODEL}"
                ))
                .build()
        authorizationService.performRegistrationRequest(registrationRequest) { registrationResponse, registrationException ->
            handleRegistrationResponse(result, registrationResponse, registrationException)
        }
    }

    private fun handleRegistrationResponse(result: MethodChannel.Result, registrationResponse: RegistrationResponse?, exception: AuthorizationException?) {
        if (exception != null) {
            result.error("failed_register", "Failed to register client: ${exception.fullMessage()}", null)
            return
        } else if (registrationResponse == null) {
            result.error("failed_register", "Got no registration response or error", null)
            return
        }

        currentAuthState.update(registrationResponse)
        result.success(currentAuthState.jsonSerializeString())
    }

    private fun handleAuthorize(call: MethodCall, result: MethodChannel.Result, authorizationService: AuthorizationService) {
        if (currentAppAuthResult != null) {
            result.error("concurrent_request", "Authorization in progress", null)
            return
        }

        currentAuthState = AuthState.jsonDeserialize(call.argument<String>("authState")!!)
        val request = AuthorizationRequest.Builder(currentAuthState.authorizationServiceConfiguration!!,
                currentAuthState.lastRegistrationResponse!!.clientId,
                ResponseTypeValues.CODE,
                APP_AUTH_REDIRECT_URI
            )
                .setLoginHint(call.argument("username"))
                .setPrompt("login")
                .setScope(call.argument<String>("scopes"))
                .build()

        currentAppAuthResult = result
        startActivityForResult(authorizationService.getAuthorizationRequestIntent(request), APP_AUTH_REQUEST_CODE)
    }

    private fun handleGetAccessToken(call: MethodCall, result: MethodChannel.Result, authorizationService: AuthorizationService) {
        currentAuthState = AuthState.jsonDeserialize(call.argument<String>("authState")!!)
        currentAuthState.performActionWithFreshTokens(authorizationService, currentAuthState.clientAuthentication) { accessToken, idToken, exception ->
            if (exception != null) {
                result.error("failed_token_fetch", "Failed to obtain access token: ${exception.message}", null)
            } else if (accessToken != null || idToken != null) {
                result.success(mapOf("accessToken" to accessToken, "idToken" to idToken, "authState" to currentAuthState.jsonSerializeString()))
            } else {
                result.error("failed_token_fetch", "Got no tokens or error", null)
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == APP_AUTH_REQUEST_CODE) {
            val authorizationResponse = AuthorizationResponse.fromIntent(data!!)
            val exception = AuthorizationException.fromIntent(data)
            currentAuthState.update(authorizationResponse, exception)

            val result = currentAppAuthResult
            if (result != null) {
                when {
                    authorizationResponse != null -> exchangeAuthorizationCode(authorizationResponse, result)
                    exception != null -> result.error("failed_authorization", "Failed to authorize: ${exception.fullMessage()}", null)
                    else -> result.error("failed_authorization",  "Failed to authorize and no error", null)
                }
                currentAppAuthResult = null
            }
        } else {
            super.onActivityResult(requestCode, resultCode, data)
        }
    }

    private fun exchangeAuthorizationCode(authorizationResponse: AuthorizationResponse, result: MethodChannel.Result) {
        authorizationService.performTokenRequest(authorizationResponse.createTokenExchangeRequest(), currentAuthState.clientAuthentication) { tokenResponse, exception ->
            currentAuthState.update(tokenResponse, exception)
            when {
                tokenResponse != null -> result.success(currentAuthState.jsonSerializeString())
                exception != null -> result.error("failed_token_fetch", "Failed to exchange authorization code: ${exception.fullMessage()}", null)
                else -> result.error("failed_token_fetch", "Failed to exchange authorization code and got no error", null)
            }
        }
    }
}
