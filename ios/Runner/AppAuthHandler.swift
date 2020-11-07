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

struct ErrorMessage {
    var code: String
    var message: String
}

class AppAuthHandler {
    
    private var authState: OIDAuthState?
    let kAppAuthAuthStateKey = "authState_" // Key is extended by UserID
    
    // A single slash between shema and path is recommended for iOS
    let APP_AUTH_REDIRECT_URI =  URL.init(string: "eu.jhass.insporation:/callback/")!
    
    let controller: UIViewController
    let authMethodChannel: FlutterMethodChannel
    var currentSession: Session?
    
    private let TIMEOUT_IN_SECONDS = 6.0 // Wait a relative short ammout of time.
    
    private var completionHandler: [(_ tokens:Tokens) -> Void] = []
    private var errorHandler: [(_ code: String, _ errorMessage:String) -> Void] = []
    
    private let FAILED_TIMEOUT = "timeout"
    private let FAILED_TOKEN_FETCH = "failed_token_fetch"
    private let FAILED_AUTHORIZE = "failed_authorize"
    private let FAILED_REGISTER = "failed_register"
    private let FAILED_DISCOVERY = "failed_discovery" // Is the first call on new or unknown services, if this fails, service is not available or not the right API Version
    
    private let RUNTIME_ERROR = "runtime_error" // Not fixable by user
    
    init(methodChannel: FlutterMethodChannel, controller: UIViewController) {
        self.authMethodChannel = methodChannel
        self.controller = controller
        os_log("Init App Auth Handler")
        predefineURLSession()
    }
    
// Set some custom configurations for authorization sessions
    private func predefineURLSession() {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForResource = TIMEOUT_IN_SECONDS
        let session = URLSession(configuration: sessionConfig)
        OIDURLSessionProvider.setSession(session)
    }
    
    
    // Calls all stored handler
    private func invokeCompletionHandler(tokens: Tokens) {
        while !self.completionHandler.isEmpty {
            self.completionHandler.removeFirst()(tokens)
        }
    }
    
    // Calls all stored handler
    private func invokeErrorHandler(code: String, errorMessage: String) {
        while !self.errorHandler.isEmpty {
            self.errorHandler.removeFirst()(code, errorMessage)
        }
    }
    
    /**
     Gets a token from auth
     */
    func getAccessTokens(_ session: Session, completionHandler: @escaping (Tokens) -> Void, errorHandler: @escaping (String, String) -> Void) {
        self.currentSession = session
        
        self.completionHandler.append(completionHandler)
        self.errorHandler.append(errorHandler)
        
        if !session.hasState() {
            
            os_log("Provided session for fetching access token has no authorization, launching authorization process")
            authorizeUser()
            
        } else {
            os_log("State was set previously, refreshing token from existing state")
            // A textual state was set, recover latest stored State Object
            recoverToken()
        }
    }
    
    func recoverToken() {
        guard let session = self.currentSession else {
            os_log("Error in getting last session")
            self.errorHandler.first?(FAILED_TOKEN_FETCH, "Internal error in getting last session")
            return
        }
        
        if let authState = loadState(forUserId: session.userId) {
            // State exists, perform refreshing
            
            guard authState.isAuthorized else {
                authorizeUser()
                return
            }
            
            guard let tokenResponse = authState.lastTokenResponse else {
                self.invokeErrorHandler(code: FAILED_TOKEN_FETCH, errorMessage: "No token received")
                return
            }
            
            // Request fresh token
            authState.performAction { (accessToken, idToken, error) in
                
                if let error = error {
                    self.invokeErrorHandler(code: self.FAILED_TOKEN_FETCH, errorMessage: error.localizedDescription)
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
            self.invokeErrorHandler(code: self.FAILED_AUTHORIZE, errorMessage: "No user ID set")
            return
        }
        discoverConfiguration(forUserId: userId)
    }
    
    func discoverConfiguration(forUserId userId: String) {
        
        let hostname = StateHandler.hostForUser(userId: userId)
        os_log("Discovering service config for '%{public}@'...", log: .default, type: .debug, hostname)
        
        let discoveryURL = URL(string: "https://\(hostname)")!
        
        OIDAuthorizationService.discoverConfiguration(forIssuer: discoveryURL) { (configuration, error) in
            // 1001: Timeout, 1003 = Hostnot found
            if let error = error as NSError? {
                if self.isTimeoutError(error) {
                    os_log("The connection timed out. ")
                    self.invokeErrorHandler(code: self.FAILED_TIMEOUT, errorMessage: "Timeout to discover service")
                    return
                }
                
                os_log("Failed to discover service config for %{public}@: %{public}@", log: .default, type: .error, hostname, error.localizedDescription)
                self.invokeErrorHandler(code: self.FAILED_DISCOVERY, errorMessage: "Failed to discover service")
                return
            }
            
            guard let configuration = configuration else {
                os_log("Configuration Object was empty")
                self.invokeErrorHandler(code: self.FAILED_DISCOVERY, errorMessage: "Configuraton object was empty")
                return
            }
            
            os_log("Discovered service config for '%{public}@'", log: .default, type: .debug, hostname)
            self.checkForRegistration(configuration: configuration, userId: userId)
        }
    }
    
    /// If this client is already registered, use persisted ID. Request a registration otherwise.
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
                
                if self.isTimeoutError(error) {
                    os_log("The connection timed out. ")
                    self.invokeErrorHandler(code: self.RUNTIME_ERROR, errorMessage: "Timeout to register service")
                    return
                }
                
                os_log("Failed registration client %{error}@", log: .default, type: .error, error.localizedDescription)
                self.setAuthState(nil) // Clear local store - if already stored
                self.invokeErrorHandler(code: self.FAILED_REGISTER, errorMessage: "Failed to register service: \(error.localizedDescription)")
                return
            }
            
            guard let response = response else { return }
            
            os_log("Got registration response: %{public}@", log: .default, type: .default, response)
            
            // Succesful registration
            // Store registration in device store
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
            os_log("RuntimeError: AppDelegate not set in code.")
            self.invokeErrorHandler(code: self.RUNTIME_ERROR, errorMessage: "AppDelegate not set in code")
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
        os_log("Initiating authorization request with request: '%{public}@'...", log: .default, type: .default,  request.debugDescription )
        
        appDelegate.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: self.controller) { authState, error in
            
            if let error = error {
                
                if self.isTimeoutError(error) {
                    os_log("The connection timed out. ")
                    self.invokeErrorHandler(code: self.RUNTIME_ERROR, errorMessage: "Timeout to authorize")
                    return
                }
                
                os_log("Authorization error: %{public}@", log:.default, type: .error,  error.localizedDescription )
                self.setAuthState(nil)
                self.invokeErrorHandler(code: self.FAILED_AUTHORIZE, errorMessage: "Authorization error: \(error.localizedDescription)")
                return
            }
            
            if let authState = authState {
                
                // Token setting should end waiting service
                guard let tokenResponse = authState.lastTokenResponse else {
                    self.invokeErrorHandler(code: self.FAILED_TOKEN_FETCH, errorMessage: "No token received")
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

/// Load / Save changeable states
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
            // Attention! The archivedData method is marked as deprecated in iOS 12.0, but recommended method
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
        
        // Attention! The archivedData method is marked as deprecated, but recommended method
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

extension AppAuthHandler {
    
    func isTimeoutError(_ error: Error?) -> Bool {
        if let error = error as NSError? {
            if let uError = error.userInfo["NSUnderlyingError"] as! NSError? {
                return uError.code == CFNetworkErrors.cfurlErrorTimedOut.rawValue
            }
        }
        return false
    }
}
