import UIKit
import Flutter
import AppAuth
import os.log

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    // property of the app's AppDelegate
    var currentAuthorizationFlow: OIDExternalUserAgentSession?
    
    static let hostAppBundleIdentifier = "eu.jhass.insporation"
    private let APP_AUTH_CHANNEL = "insporation/appauth"
    private let APP_AUTH_EVENTS = "insporation/appauth_authorization_events"
    private let SHARE_EVENTS = "insporation/share_receiver"
    private var appAuthHandler : AppAuthHandler?
    private var shareStreamHandler : StreamHandler?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let authChannel = FlutterMethodChannel(name: APP_AUTH_CHANNEL,
                                               binaryMessenger: controller.binaryMessenger)
        
        appAuthHandler = AppAuthHandler(methodChannel: authChannel, controller: controller)
        authChannel.setMethodCallHandler {(call: FlutterMethodCall, result: @escaping FlutterResult) in
            
            guard call.method == "getAccessToken" else {
                result(FlutterMethodNotImplemented)
                return
            }
            
            if let arguments = call.arguments {
                guard let sessionArgs = (arguments as! [String:Any?])["session"] else {
                    result("Invalid Arguments (need at least a session")
                    return
                }
                
                let sessionArgs_:[String: Any?] = (sessionArgs as! [String : Any?])
                let session = Session(sessionData: sessionArgs_)
                if let appAuthHandler = self.appAuthHandler {
                    appAuthHandler.getAccessTokens(session) { (tokens) in
                        os_log("Got token: %{public}@", log: .default, type: .default,tokens.debugDescription())
                        result(tokens.toDict())
                    } errorHandler : { (code, errorMessage, details) in
                        os_log("Error: %{public}@", log:.default, type: .error, errorMessage)
                        result(FlutterError(code: code, message: errorMessage, details: details))
                    }
                }
            }
        }

        // Stub, this is used with Android to deliver authorization results
        // after the app died in the background while the user was using the browser
        // to authenticate. This, the app dying in the background, does not happen on iOS
        let appAuthEvents = FlutterEventChannel(name: APP_AUTH_EVENTS,
                                                binaryMessenger: controller.binaryMessenger)
        appAuthEvents.setStreamHandler(StreamHandler())

        // TODO receive share events and send them to this channel, see ShareEventStream in Android
        let shareEvents = FlutterEventChannel(name: SHARE_EVENTS,
                                              binaryMessenger: controller.binaryMessenger)
        if shareStreamHandler == nil {
            shareStreamHandler = StreamHandler()
        }
        shareEvents.setStreamHandler(shareStreamHandler)

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // Get a map to share, or nil
        let shared = SharedHandler.buildMapFromSharedUserDefaults()
        shareStreamHandler?.eventSink?(shared)
        
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
