//
//  Tokens.swift
//  Runner
//
//  Created by Thorsten Claus on 17.10.20.
//

import Foundation

/// A set of tokens send from instance
class Tokens {
    
    var accessToken: String
    var idToken: String
    
    init(accessToken: String, idToken: String) {
        self.accessToken = accessToken
        self.idToken = idToken
    }
    
    func toDict() -> [String:String] {
        return ["accessToken": accessToken, "idToken":idToken]
    }
    
    func debugDescription() -> String {
        return toDict().debugDescription
    }
    
}
