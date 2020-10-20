//
//  AppAuthHandler.swift
//  Runner
//
//  Created by Thorsten Claus on 17.10.20.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

import AppAuth
import Foundation
import Flutter.FlutterChannels
import os.log

typealias PostRegistrationCallback = (_ configuration: OIDServiceConfiguration?, _ registrationResponse: OIDRegistrationResponse?) -> Void


class AppAuthHandler : NSObject {
    
    enum AuthError: Error {
        case runtimeError(String)
    }
    
    private var authState : OIDAuthState?
    let kAppAuthExampleAuthStateKey = "authState" // plus name?
    
    let APP_AUTH_SESSION_CHANNEL = "insporation/appauth_authorization_events"
    // A single slash between shema and path is recommended for iOS
    let APP_AUTH_REDIRECT_URI =  URL.init(string: "eu.jhass.insporation:/callback")!
    let TIMEOUT = 6 // Seconds
    let controller : UIViewController
    var registration : Registration?
    let authMethodChannel : FlutterMethodChannel
    var currentSession : Session?
    
    // private var awaitingAuthorizationResult: Channel<AuthorizationResult<AuthorizationResponse>>? = null
    
    init(methodChannel: FlutterMethodChannel, controller: UIViewController) {
        self.authMethodChannel = methodChannel
        self.controller = controller
        
        print("Init App Auth Handler")
    }
    
    /**
     Gets a token from auth
     */
    func getAccessTokens(_ session : Session) -> [String: String]! {
        self.currentSession = session
        let state = session.state
        
        if (state == nil) {
            if #available(iOS 10.0, *) {
                os_log("Provided session for fetching access token has no authorization, launching authorization process")
            } else {
                NSLog("Provided session for fetching access token has no authorization, launching authorization process")
            }
            
            currentSession = authorizeUser(userId: session.userId,scopes: session.scopes)
        }
        
        return [String:String]() // Return empty for Test
    }
    
    func authorizeUser(userId: String, scopes: String) -> Session {
        
        guard let registration = RegistrationStore.fetchRegistration(userId: userId) else { return Session() }
        guard let hostname = registration.host else {return Session()}
        
        do {
            try register(hostname: hostname, scopes: scopes)
        } catch {}
        
        return Session()
    }
    
    func register(hostname: String, scopes: String) throws  {
        
        // discovers endpoints
        let discoveryURL = URL(string: "https://\(hostname)")!
        //var fetchedConfiguration : OIDServiceConfiguration
        
        OIDAuthorizationService.discoverConfiguration(forIssuer: discoveryURL) { (configuration, error) in
            if let error = error {
                if #available(iOS 10.0, *) {
                    os_log("Failed to discover service config for %{public}@: %{public}@", log: .default, type: .info, hostname, error.localizedDescription)
                } else {
                    // Fallback on earlier versions
                    NSLog("Failed to discover service config for @s: @‚", hostname, error.localizedDescription)
                }
                NSLog("Failed to discover service config for @s: @‚", hostname, error.localizedDescription)
                return
            }
            
            guard let configuration = configuration else { return }
            
            if #available(iOS 10.0, *) {
                os_log("Discovered service config for %{public}@", log: .default, type: .debug, hostname)
            } else {
                NSLog("Discovered service config")
            }
            
            self.doRegistrationRequest(configuration: configuration, callback: { (configuration, response) in
                print("Starting with Authorization: \(String(describing: configuration))")
                
                // get Client from respnse
                guard let configuration = configuration, let clientID = response?.clientID else {
                    print("Error retrieving configuration OR clientID")
                    return
                }
                
                self.doAuthWithAutoCodeExchange(configuration: configuration,
                                                scopes: scopes,
                                                clientID: clientID,
                                                clientSecret: response?.clientSecret)
                
            })
            
        }
    }
    
    func doRegistrationRequest(configuration : OIDServiceConfiguration, callback: @escaping PostRegistrationCallback) {
        
        print("Starting registration request")
        
        let registrationRequest = OIDRegistrationRequest(configuration: configuration,
                                                         redirectURIs: [APP_AUTH_REDIRECT_URI],
                                                         responseTypes: nil,
                                                         grantTypes: nil,
                                                         subjectType: nil,
                                                         tokenEndpointAuthMethod: nil,
                                                         additionalParameters: [:])
        
        OIDAuthorizationService.perform(registrationRequest) { response, error in
            
            if let regResponse = response {
                self.setAuthState(OIDAuthState(registrationResponse: regResponse))
                print("Got registration response: \(regResponse)")
                
                callback(configuration, regResponse)
                
            } else {
                print("Registration error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                self.setAuthState(nil)
            }
        }
    }

    func doAuthWithAutoCodeExchange(configuration: OIDServiceConfiguration, scopes: String,  clientID: String, clientSecret: String?) {

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Error accessing AppDelegate")
            return
        }

        let scopeArray = scopes.components(separatedBy: " ")
        
        var login = ""
        if let session = self.currentSession {
            login = session.userId.components(separatedBy: "@").first!
        }
        
        // builds authentication request
        let request = OIDAuthorizationRequest(configuration: configuration,
                                              clientId: clientID,
                                              clientSecret: clientSecret,
                                              scopes: scopeArray,
                                              redirectURL: APP_AUTH_REDIRECT_URI,
                                              responseType: OIDResponseTypeCode,
                                              additionalParameters: ["prompt": "login",
                                                                     "login_hint":login])
        
        // performs authentication request
        print("Initiating authorization request with scope: \(request.scope ?? "DEFAULT_SCOPE")")
    
        appDelegate.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: self.controller) { authState, error in

            if let authState = authState {
                self.setAuthState(authState)
                print("Got authorization tokens. Access token: \(authState.lastTokenResponse?.accessToken ?? "DEFAULT_TOKEN")")
            } else {
                print("Authorization error: \(error?.localizedDescription ?? "DEFAULT_ERROR")")
                self.setAuthState(nil)
            }
        }
        
    }
}

extension AppAuthHandler : OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate {
    
    func didChange(_ state: OIDAuthState) {
        print("Did change State")
        setAuthState(state)
    }
    
    func authState(_ state: OIDAuthState, didEncounterAuthorizationError error: Error) {
        print("Received authorization error: \(error)")
    }
    
}

/// Load / Save Chnage States
extension AppAuthHandler {
    
    func saveState() {
        
        var data: Data? = nil
        
        if let authState = self.authState {
            data = NSKeyedArchiver.archivedData(withRootObject: authState)
        }
        
        // TODO: Set correct defaults for State !
        
        if let userDefaults = UserDefaults(suiteName: "group.net.openid.appauth.Example") {
            userDefaults.set(data, forKey: kAppAuthExampleAuthStateKey)
            userDefaults.synchronize()
        }
    }
    
    func loadState() {
        guard let data = UserDefaults(suiteName: "group.net.openid.appauth.Example")?.object(forKey: kAppAuthExampleAuthStateKey) as? Data else {
            return
        }
        
        if let authState = NSKeyedUnarchiver.unarchiveObject(with: data) as? OIDAuthState {
            self.setAuthState(authState)
        }
    }
    
    func setAuthState(_ authState: OIDAuthState?) {
        if (self.authState == authState) {
            return;
        }
        self.authState = authState;
        self.authState?.stateChangeDelegate = self;
        self.stateChanged()
    }
    
    func stateChanged() {
        self.saveState()
        // self.updateUI()
    }
}

