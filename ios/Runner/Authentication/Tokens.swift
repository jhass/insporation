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
    var idToken: String?
    
    init(accessToken: String, idToken: String?) {
        self.accessToken = accessToken
        self.idToken = idToken
    }
    
    func toDict() -> [String:String] {
        var dict = [String:String]()
        dict["accessToken"] = accessToken
        
        if let idToken = idToken {
            dict["idToken"] =  idToken
        }
        
        return dict
    }
    
    func debugDescription() -> String {
        return toDict().debugDescription
    }
}
