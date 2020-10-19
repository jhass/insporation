import UIKit
import Flutter
import AppAuth
import os.log

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    // property of the app's AppDelegate
    var currentAuthorizationFlow: OIDExternalUserAgentSession?
    
    private let APP_AUTH_CHANNEL = "insporation/appauth"
    var appAuthHandler : AppAuthHandler?
    
    
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
                    result(appAuthHandler.getAccessTokens(session))
                }
            }
            
            result("Failure running args code")
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    // Handle redirect from website
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        print("Handle redirect")
        
        if let authorizationFlow = self.currentAuthorizationFlow, authorizationFlow.resumeExternalUserAgentFlow(with: url) {
            self.currentAuthorizationFlow = nil
            return true
        }
        
        return false
    }
    
}
