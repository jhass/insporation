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
    var state : OIDAuthState?
    
    init() {
        
    }
    
    convenience init(sessionData : [String:Any?]) {
        self.init()
        
        userId = (sessionData["userId"] as? String)!
        scopes = (sessionData["scopes"] as? String)!
        state = (sessionData["state"] as? OIDAuthState)
    }
    
    func uppdate(state: OIDAuthState) {
        self.state = state
    }
    
    // TODO: Nicht JSON-Style machen, somndern für Data Serialisieren lassen
    func toDict() -> [String: Any?] {
        var dict = [String: Any?]()
        dict["userId"] = userId
        dict["scopes"] = scopes
        
        
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: self.state, requiringSecureCoding: false) {
            do {
                let encoder = JSONEncoder()
                
                if let json = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) as? [String: Any] {
                // try to read out a string array
                print("Converted to JSON: \(json)")
            }
            } catch {
                print("\(error)")
            }
        }
        return dict
    }
}
