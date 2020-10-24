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
    let APP_AUTH_REDIRECT_URI =  URL.init(string: "eu.jhass.insporation:/callback/")!
    let TIMEOUT = 6 // Seconds
    let controller : UIViewController
    var registration : Registration?
    let authMethodChannel : FlutterMethodChannel
    var currentSession : Session?
    
    private var completionHandler : [(_ tokens:Tokens) -> Void] = []
    private var errorHandler : [(_ errorMessage:String) -> Void] = []
    
    init(methodChannel: FlutterMethodChannel, controller: UIViewController) {
        self.authMethodChannel = methodChannel
        self.controller = controller
        os_log("Init App Auth Handler")
    }
    
    /**
     Gets a token from auth
     */
    func getAccessTokens(_ session : Session, completionHandler : @escaping (Tokens) -> Void, errorHandler:@escaping (String) -> Void) {
        self.currentSession = session
        
        self.completionHandler.append(completionHandler)
        self.errorHandler.append(errorHandler)
        
        let state = session.state // Hier könnte von flutter schon ein Auth drinn sein?
        
        
        // A incomming session could be searche internally for existing tokens
        
        if (state == nil) {
            if #available(iOS 10.0, *) {
                os_log("Provided session for fetching access token has no authorization, launching authorization process")
            } else {
                NSLog("Provided session for fetching access token has no authorization, launching authorization process")
            }
            
            authorizeUser()
        }
    }
    
    func authorizeUser() {
        guard let userId = self.currentSession?.userId else {
            os_log("No userID set.")
            self.errorHandler.first?("No user ID set")
            return
        }
        
        // Get registration from devise store
        guard let registration = RegistrationStore.fetchRegistration(userId: userId) else { return }
        guard let hostname = registration.host else {return }
        
        discoverConfiguration(hostname: hostname)
        
    }
    
    func discoverConfiguration(hostname: String) {
        
        let discoveryURL = URL(string: "https://\(hostname)")!
        if #available(iOS 10.0, *) {
            os_log("Discovering service config for '%{public}@'", log: .default, type: .debug, hostname)
        } else {
            NSLog("Discovering service config for %s", hostname)
        }
        
        OIDAuthorizationService.discoverConfiguration(forIssuer: discoveryURL) { (configuration, error) in
            if let error = error {
                if #available(iOS 10.0, *) {
                    os_log("Failed to discover service config for %{public}@: %{public}@", log: .default, type: .error, hostname, error.localizedDescription)
                } else {
                    // Fallback on earlier versions
                    NSLog("Failed to discover service config for @s: @‚", hostname, error.localizedDescription)
                }
                self.errorHandler.first?("Failed to discover service")
                return
            }
            
            guard let configuration = configuration else { return }
            
            if #available(iOS 10.0, *) {
                os_log("Discovered service config for '%{public}@'", log: .default, type: .debug, hostname)
            } else {
                NSLog("Discovered service config: \(hostname) ")
            }
            
            self.doRegistrationRequest(configuration: configuration)
        }
    }
    
    /// Query a registration,
    func doRegistrationRequest(configuration: OIDServiceConfiguration) {

        os_log("Starting registration request with: %{public}@", log: .default, type: .debug, configuration)
        
        let registrationRequest = OIDRegistrationRequest(configuration: configuration,
                                                         redirectURIs: [APP_AUTH_REDIRECT_URI],
                                                         responseTypes: nil,
                                                         grantTypes: ["authorization_code"],
                                                         subjectType: nil,
                                                         tokenEndpointAuthMethod: nil,
                                                         additionalParameters: ["client_name":"insporation*"])
        
        OIDAuthorizationService.perform(registrationRequest) { (response, error) in
    
            if let error = error {
                os_log("Failed registration client %{error}@", log: .default, type: .error,  error.localizedDescription)
                self.setAuthState(nil) // Clear local store - if already stored
                self.errorHandler.first?("Failed to register service: \(error.localizedDescription)")
                return
            }
            
            guard let response = response else { return }
            
            // Succesful registration
            // Store registration in devise store
            self.setAuthState(OIDAuthState(registrationResponse: response))
            os_log("Got registration response: %{public}@", log: .default, type: .default, response)
            
            // get Client from response
            let clientID = response.clientID
            
            guard let scopes = self.currentSession?.scopes else { return }
            self.doAuthWithAutoCodeExchange(configuration: configuration,
                                            scopes: scopes,
                                            clientID: clientID,
                                            clientSecret: response.clientSecret)
        }
    }
    
    func doAuthWithAutoCodeExchange(configuration: OIDServiceConfiguration, scopes: String,  clientID: String, clientSecret: String?) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            os_log("Error accessing AppDelegate")
            self.errorHandler.first?("Error accessing AppDelegate")
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
                                                                     "login_hint": login])
        
        // performs authentication request
        os_log("Initiating authorization request with request: %{public}@", log: .default, type: .default,  request.debugDescription )
        
        appDelegate.currentAuthorizationFlow = OIDAuthorizationService.present(request, presenting: self.controller) { (response, error) in
            
            if let error = error {
                os_log("Authorization error: %{public}@", log:.default, type: .error,  error.localizedDescription )
                self.setAuthState(nil)
                self.errorHandler.first?("Authorization error: \(error.localizedDescription)")
                return
            }
            
            if let response = response {
                
                // Token setting should end waiting service
                guard let accessToken = response.accessToken, let idToken = response.idToken else {
                    self.errorHandler.first?("No token received")
                    return
                }
                
                let tokens = Tokens(accessToken: accessToken, idToken: idToken)
                
                let authState = OIDAuthState(authorizationResponse: response)
                os_log("Got authorization tokens")
                self.setAuthState(authState)
                self.completionHandler.first?(tokens)
            }
        }
    }
}

extension AppAuthHandler : OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate {
    
    func didChange(_ state: OIDAuthState) {
        os_log("Did change State")
        setAuthState(state)
    }
    
    func authState(_ state: OIDAuthState, didEncounterAuthorizationError error: Error) {
        os_log("Received authorization error: %{public}@", log:.default, type:.error, error.localizedDescription)
    }
}

/// Load / Save Chnage States
extension AppAuthHandler {
    
    func saveState() {
        
        if let currentSession = self.currentSession {
            storeSession(session: currentSession)
        }
    }
    
    func storeSession(session: Session) {
       //  self.authMethodChannel.invokeMethod("storeSession", arguments: session.toDict())
    }
    
    func setAuthState(_ authState: OIDAuthState?) {
        if (self.authState == authState) {
            return;
        }
        
        self.authState = authState;
        self.authState?.stateChangeDelegate = self;
        // self.currentSession?.uppdate(state: authState!)
        self.stateChanged()
    }
    
    func stateChanged() {
        self.saveState()
    }
}

