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
        var debugDescription = "{ "
        debugDescription.append("accessToken = ")
        debugDescription.append(contentsOf: accessToken.prefix(5))
        debugDescription.append("...; ")
        if let idToken = idToken {
            debugDescription.append("idToken = ")
            debugDescription.append(contentsOf: idToken.prefix(5))
            debugDescription.append("...; ")
        }
        debugDescription.append(" }")
        return debugDescription
    }
}
