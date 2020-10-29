//
//  Registration.swift
//  Runner
//
//  Created by Thorsten Claus on 18.10.20.
//

import Foundation
import AppAuth
import os.log

struct Registration: Codable  {
    
    let host: String?
    let clientSecret: String?
    let clientId: String?
    
    enum CodingKeys: String, CodingKey {
        case host = "host"
        case clientId = "clientId"
        case clientSecret = "clientSecret"
    }
    
    var description: String {
        return "Host: \(String(describing: host)), clientId: \(String(describing: clientId)), clientSecret: \(String(describing: clientSecret)))"
    }

    func hasValidState() -> Bool {
        guard let _ = clientId, let _ = clientSecret else {
            return false
        }
        return true
    }
}
