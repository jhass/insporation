import UIKit
import Flutter
import AppAuth
import os.log

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

    // property of the app's AppDelegate
    var currentAuthorizationFlow: OIDExternalUserAgentSession?

    static let hostAppBundleIdentifier = "eu.jhass.insporation"
    private let APP_AUTH_PLUGIN = "insporation/appauth_delegate"
    private let APP_AUTH_CHANNEL = "insporation/appauth"
    private let APP_AUTH_EVENTS = "insporation/appauth_authorization_events"
    private let SHARE_EVENTS = "insporation/share_receiver"
    private var appAuthHandler : AppAuthHandler?
    private let appAuthStreamHandler = StreamHandler()
    private let shareStreamHandler = StreamHandler()

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

        let messenger = engineBridge.applicationRegistrar.messenger()
        let authChannel = FlutterMethodChannel(name: APP_AUTH_CHANNEL,
                                               binaryMessenger: messenger)

        if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: APP_AUTH_PLUGIN) {
            appAuthHandler = AppAuthHandler(methodChannel: authChannel, registrar: registrar)
        }

        authChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            guard let self else {
                result(FlutterError(code: "runtime_error", message: "AppDelegate unavailable", details: nil))
                return
            }

            guard call.method == "getAccessToken" else {
                result(FlutterMethodNotImplemented)
                return
            }

            guard let arguments = call.arguments as? [String: Any?],
                  let sessionArgs = arguments["session"] as? [String: Any?] else {
                result("Invalid Arguments (need at least a session")
                return
            }

            guard let appAuthHandler = self.appAuthHandler else {
                result(FlutterError(code: "runtime_error", message: "AppAuth handler unavailable", details: nil))
                return
            }

            let session = Session(sessionData: sessionArgs)
            appAuthHandler.getAccessTokens(session) { (tokens) in
                os_log("Got token: %{public}@", log: .default, type: .default, tokens.debugDescription())
                result(tokens.toDict())
            } errorHandler: { (code, errorMessage, details) in
                os_log("Error: %{public}@", log: .default, type: .error, errorMessage)
                result(FlutterError(code: code, message: errorMessage, details: details))
            }
        }

        // Stub, this is used with Android to deliver authorization results
        // after the app died in the background while the user was using the browser
        // to authenticate. This, the app dying in the background, does not happen on iOS
        let appAuthEvents = FlutterEventChannel(name: APP_AUTH_EVENTS,
                                                binaryMessenger: messenger)
        appAuthEvents.setStreamHandler(appAuthStreamHandler)

        // TODO receive share events and send them to this channel, see ShareEventStream in Android
        let shareEvents = FlutterEventChannel(name: SHARE_EVENTS,
                                              binaryMessenger: messenger)
        shareEvents.setStreamHandler(shareStreamHandler)
    }

    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return handleIncomingURL(url) || super.application(app, open: url, options: options)
    }

    @discardableResult
    func handleIncomingURL(_ url: URL) -> Bool {
        if let currentAuthorizationFlow,
           currentAuthorizationFlow.resumeExternalUserAgentFlow(with: url) {
            self.currentAuthorizationFlow = nil
            return true
        }

        guard url.scheme?.caseInsensitiveCompare("ShareMedia") == .orderedSame else {
            return false
        }

        let shared = SharedHandler.buildMapFromSharedUserDefaults()
        shareStreamHandler.eventSink?(shared)
        return true
    }

    class StreamHandler : NSObject, FlutterStreamHandler {
        var eventSink : FlutterEventSink?

        func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
            self.eventSink = events
            return nil
        }

        func onCancel(withArguments arguments: Any?) -> FlutterError? {
            return nil
        }
    }
}
