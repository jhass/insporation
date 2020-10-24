//
//  Session.swift
//  Runner
//
//  Created by Thorsten Claus on 17.10.20.
//

import UIKit
import AppAuth

class Session {
    
    var userId = ""
    var scopes = ""
    var state : String?
    
    init() {
        
    }
    
    convenience init(sessionData : [String:Any?]) {
        self.init()
        
        userId = (sessionData["userId"] as? String)!
        scopes = (sessionData["scopes"] as? String)!
        state = (sessionData["state"] as? String)
    }
    
    func update(state: OIDAuthState?) {
        if let state = state {
            self.state = state.description
        } else {
            self.state = nil
        }
    }
    
    // TODO: Nicht JSON-Style machen, somndern für Data Serialisieren lassen
    func toDict() -> [String: Any?] {
        var dict = [String: Any?]()
        dict["userId"] = userId
        dict["scopes"] = scopes
        dict["state"] = state
        return dict
    }
    
    func debugDescription() -> String {
        return toDict().debugDescription
    }
}
