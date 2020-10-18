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
import AwaitKit
import PromiseKit


class AppAuthHandler {
    
    enum AuthError: Error {
        case runtimeError(String)
    }
    
    let APP_AUTH_SESSION_CHANNEL = "insporation/appauth_authorization_events"
    let APP_AUTH_REDIRECT_URI =  URL.init(string: "eu.jhass.insporation://callback")
    let TIMEOUT = 6 // Seconds
    
    let authMethodChannel : FlutterMethodChannel
    
    // private var awaitingAuthorizationResult: Channel<AuthorizationResult<AuthorizationResponse>>? = null
    private var awaitingAuthorizationResult: FlutterEventChannel?
    
    init(methodChannel: FlutterMethodChannel) {
        self.authMethodChannel = methodChannel
        print("Init App Auth Handler")
        
    }
    
    /**
     Gets a token from auth
     */
    func getAccessTokens(_ session : Session) -> [String: String]! {
        // mapOf("accessToken" to accessToken, "idToken" to idToken)
        var currentSession = session
        var state = session.state
        
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
        if awaitingAuthorizationResult != nil {
            if #available(iOS 10.0, *) {
                os_log("Tried to trigger multiple authorizations concurrently")
            } else {
                // Fallback on earlier versions
                NSLog("Tried to trigger multiple authorizations concurrently")
            }
            return Session()
        }
        
        guard let registration = RegistrationStore.fetchRegistration(userId: userId) else { return Session() }
        guard let hostname = registration.host else {return Session()}
        
        do {
            try register(hostname: hostname)
        } catch {}
        
        return Session()
    }
    
    
    var registration : Registration
    
    func register(hostname: String) throws  {
        
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
            
            if #available(iOS 10.0, *) {
                os_log("Discovered service config for %{public}@", log: .default, type: .debug, hostname)
            } else {
                NSLog("Discovered service config")
            }
    
            self.registrationRequest(configuration!)
            
        }
    }
    
    func registrationRequest( _ configuration : OIDServiceConfiguration) {
        
        
        let registrationRequest = OIDRegistrationRequest(configuration: configuration,
                                                         redirectURIs: [APP_AUTH_REDIRECT_URI],
                                                         responseTypes: nil,
                                                         grantTypes: nil,
                                                         subjectType: nil,
                                                         tokenEndpointAuthMethod: nil,
                                                         additionalParameters: ["client_name" : "insporation*"])
        let service = OIDAuthorizationService()
        
    }
    
    
}
