//
//  StateHandler.swift
//  Runner
//
//  Created by Thorsten Claus on 27.10.20.
//

import Foundation
import AppAuth
import os.log

class StateHandler {

    /// Separates hostname from usderId which is a email address
    static func hostForUser(userId : String) -> String {
        if let hostname = userId.split(separator: "@").last {
            return String(hostname).lowercased()
        }
        return ""
    }
}
