//
//  Session.swift
//  Runner
//
//  Created by Thorsten Claus on 17.10.20.
//

import UIKit

class Session {
    
    var userId = ""
    var scopes = ""
    var state : Any?
    
    init() {
    }
    
    convenience init(sessionData : [String:Any?]) {
        self.init()
        
        userId = (sessionData["userId"] as? String)!
        scopes = (sessionData["scopes"] as? String)!
        state = sessionData["state"] ?? nil
    }
}
