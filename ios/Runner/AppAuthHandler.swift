//
//  AppAuthHandler.swift
//  Runner
//
//  Created by Thorsten Claus on 17.10.20.
//

import AppAuth
import Foundation
import Flutter.FlutterChannels
import os.log

typealias PostRegistrationCallback = (_ configuration: OIDServiceConfiguration?, _ registrationResponse: OIDRegistrationResponse?) -> Void


class AppAuthHandler {
    
    private var authState: OIDAuthState?
    let kAppAuthAuthStateKey = "authState_" // Key is extended by UserID
    
    // A single slash between shema and path is recommended for iOS
    let APP_AUTH_REDIRECT_URI =  URL.init(string: "eu.jhass.insporation:/callback/")!
    
    let controller: UIViewController
    let authMethodChannel: FlutterMethodChannel
    var currentSession: Session?
    
    private var completionHandler: [(_ tokens:Tokens) -> Void] = []
    private var errorHandler: [(_ errorMessage:String) -> Void] = []
    
    init(methodChannel: FlutterMethodChannel, controller: UIViewController) {
        self.authMethodChannel = methodChannel
        self.controller = controller
        os_log("Init App Auth Handler")
    }
    
    private func invokeCompletionHandler(tokens: Tokens) {
        while !self.completionHandler.isEmpty {
            self.completionHandler.removeFirst()(tokens)
        }
    }
    
    private func invokeErrorHandler(errorMessage: String) {
        while !self.errorHandler.isEmpty {
            self.errorHandler.removeFirst()(errorMessage)
        }
    }
    
    /**
     Gets a token from auth
     */
    func getAccessTokens(_ session: Session, completionHandler: @escaping (Tokens) -> Void, errorHandler:@escaping (String) -> Void) {
        self.currentSession = session
        
        self.completionHandler.append(completionHandler)
        self.errorHandler.append(errorHandler)
        
        if !session.hasState() {
            
            os_log("Provided session for fetching access token has no authorization, launching authorization process")
            authorizeUser()
            
        } else {
            os_log("State was set previously, refreshing token from existing state")
            // A textual state was set, recover laste stored State Obejct
            recoverToken()
        }
    }
    
    func recoverToken() {
        guard let session = self.currentSession else {
            os_log("Error in getting last session")
            self.errorHandler.first?("Error in getting last session")
            return
        }
        
        if let authState = loadState(forUserId: session.userId) {
            // State exists, perform refreshing
            
            guard authState.isAuthorized else {
                authorizeUser()
                return
            }
            
            guard let tokenResponse = authState.lastTokenResponse else {
                self.invokeErrorHandler(errorMessage: "No token received")
                return
            }
            
            // Request fresh token
            authState.performAction { (accessToken, idToken, error) in
                
                if let error = error {
                    self.invokeErrorHandler(errorMessage: error.localizedDescription)
                    return
                }
                // Got new token
                let tokens = Tokens(accessToken: tokenResponse.accessToken!, idToken: tokenResponse.idToken!)
                self.invokeCompletionHandler(tokens: tokens)
            }
            
        } else {
            // State does not exist, reauthenticate
            authorizeUser()
        }
    }
    
    func authorizeUser() {
        guard let userId = self.currentSession?.userId else {
            os_log("No userID set")
            self.invokeErrorHandler(errorMessage: "No user ID set")
            return
        }
        discoverConfiguration(forUserId: userId)
    }
    
    func discoverConfiguration(forUserId userId: String) {
        
        let hostname = StateHandler.hostForUser(userId: userId)
        os_log("Discovering service config for '%{public}@'", log: .default, type: .debug, hostname)
        
        let discoveryURL = URL(string: "https://\(hostname)")!
        OIDAuthorizationService.discoverConfiguration(forIssuer: discoveryURL) { (configuration, error) in
            
            if let error = error {
                os_log("Failed to discover service config for %{public}@: %{public}@", log: .default, type: .error, hostname, error.localizedDescription)
                self.invokeErrorHandler(errorMessage: "Failed to discover service")
                return
            }
            
            guard let configuration = configuration else {
                os_log("Configuration Object was empty")
                self.invokeErrorHandler(errorMessage: "Configuraton object was empty")
                return
            }
            
            os_log("Discovered service config for '%{public}@'", log: .default, type: .debug, hostname)
            self.checkForRegistration(configuration: configuration, userId: userId)
        }
    }
    
    /// If this client is already registered, use persisted ID. Request a registration else.
    func checkForRegistration(configuration: OIDServiceConfiguration, userId: String) {
        
        os_log("Starting registration request with: %{public}@", log: .default, type: .debug, configuration)
        
        // Get registration from device store
        let registration = RegistrationStore.fetchRegistration(forUserId: userId)
        
        if let registration = registration, registration.hasValidState() {
            // Use existing registration
            guard let scopes = self.currentSession?.scopes else {
                os_log("Provided session has empty scopes to request.", log: .default, type: .error)
                return
            }
            os_log("Using existing client registration")
            self.doAuthWithAutoCodeExchange(configuration: configuration,
                                            scopes: scopes,
                                            clientID: registration.clientId!,
                                            clientSecret: registration.clientSecret!)
        } else {
            os_log("Request a new client registration")
            registerClient(serviceConfiguration: configuration)
        }
    }
    
    func registerClient(serviceConfiguration configuration: OIDServiceConfiguration) {
        
        let registrationRequest = OIDRegistrationRequest(configuration: configuration,
                                                         redirectURIs: [APP_AUTH_REDIRECT_URI],
                                                         responseTypes: ["code"],
                                                         grantTypes: nil,
                                                         subjectType: nil,
                                                         tokenEndpointAuthMethod: nil,
                                                         additionalParameters: ["client_name":"insporation*"])
        
        OIDAuthorizationService.perform(registrationRequest) { (response, error) in
            
            if let error = error {
                os_log("Failed registration client %{error}@", log: .default, type: .error, error.localizedDescription)
                self.setAuthState(nil) // Clear local store - if already stored
                self.invokeErrorHandler(errorMessage: "Failed to register service: \(error.localizedDescription)")
                return
            }
            
            guard let response = response else { return }
            
            os_log("Got registration response: %{public}@", log: .default, type: .default, response)
            
            // Succesful registration
            // Store registration in devise store
            let hostname = StateHandler.hostForUser(userId: self.currentSession!.userId)
            let registration = Registration(host: hostname, clientSecret: response.clientSecret, clientId: response.clientID)
            RegistrationStore.storeRegistration(registration)
            
            guard let scopes = self.currentSession?.scopes else { return }
            self.doAuthWithAutoCodeExchange(configuration: configuration,
                                            scopes: scopes,
                                            clientID: registration.clientId!,
                                            clientSecret: registration.clientSecret!)
        }
    }
    
    func doAuthWithAutoCodeExchange(configuration: OIDServiceConfiguration, scopes: String,  clientID: String, clientSecret: String?) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            os_log("Error accessing AppDelegate")
            self.invokeErrorHandler(errorMessage: "Error accessing AppDelegate")
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
        
        appDelegate.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: self.controller) { authState, error in
            
            if let error = error {
                os_log("Authorization error: %{public}@", log:.default, type: .error,  error.localizedDescription )
                self.setAuthState(nil)
                self.invokeErrorHandler(errorMessage: "Authorization error: \(error.localizedDescription)")
                return
            }
            
            if let authState = authState {
                
                // Token setting should end waiting service
                guard let tokenResponse = authState.lastTokenResponse else {
                    self.invokeErrorHandler(errorMessage: "No token received")
                    return
                }
                
                let tokens = Tokens(accessToken: tokenResponse.accessToken!, idToken: tokenResponse.idToken!)
                
                os_log("Got authorization tokens")
                self.setAuthState(authState)
                self.invokeCompletionHandler(tokens: tokens)
            }
        }
    }
}

/// Load / Save Chnage States
extension AppAuthHandler {
    
    func setAuthState(_ authState: OIDAuthState?) {
        if (self.authState == authState) {
            return;
        }
        self.authState = authState;
        
        if let currentSession = self.currentSession {
            currentSession.update(state: authState)
            storeSession(session: currentSession)
            saveState(forUserId: currentSession.userId, state: authState)
        }
    }
    
    /// Save State for full userID into device
    /// - Parameters:
    ///   - forUserId: Full userID (name and instance hostname)
    ///   - state: Current State object
    func saveState(forUserId userId: String, state: OIDAuthState?) {
        
        var data: Data? = nil
        
        if let authState = state {
            // Attention! This arhcive-Methis is marked as depricated, but recommended method
            // will not recover the OIDAuthState correctly
            data = NSKeyedArchiver.archivedData(withRootObject: authState)
        }
        
        let userIdAuthKey = kAppAuthAuthStateKey + userId
        let userDefaults = UserDefaults()
        userDefaults.set(data, forKey: userIdAuthKey)
    }
    
    /// Loads and initializes a state object for userID from device
    /// - Parameter userId: The full userId to get an authState for
    /// - Returns: Nil if never set or userId is unknown
    func loadState(forUserId userId: String) -> OIDAuthState? {
        let userIdAuthKey = kAppAuthAuthStateKey + userId
        guard let data = UserDefaults().object(forKey: userIdAuthKey) as? Data else {
            return nil
        }
        
        // Attention! This arhcive-Methis is marked as depricated, but recommended method
        // will not recover the OIDAuthState correctly
        if let authState = NSKeyedUnarchiver.unarchiveObject(with: data) as? OIDAuthState {
            self.setAuthState(authState)
            return authState
        }
        return nil
    }
    
    /// Stores session into Flutter system, by using state as a textual representation
    func storeSession(session: Session) {
        self.authMethodChannel.invokeMethod("storeSession", arguments: session.toDict())
    }
}
