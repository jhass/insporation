//
//  Registration.swift
//  Runner
//
//  Created by Thorsten Claus on 18.10.20.
//

import Foundation

class Registration {
    
    var host : String?
    var state : String?
    
    var description : String {
        return "Host: \(String(describing: host)), with state: \(String(describing: state))"
    }
    
    init(host: String, state: String) {
        self.host = host
        self.state = state
    }
    
    init(dict : [String: Any?]) {
        host = dict["host"] as? String
        state = dict["state"] as? String
    }
    
    func toDict() -> [String: Any?] {
        return ["host": host, "state" : state]
    }
}
