//
//  RegistrationStore.swift
//  Runner
//
//  Created by Thorsten Claus on 18.10.20.
//
import Foundation

class RegistrationStore {
    
    static let _registrationPrefix = "registration_"
    
    /// Fetches a Registration object for a special userId from iOS store
    /// - Parameter userId: Diaspora UserId
    /// - Throws: <#description#>
    /// - Returns: <#description#>
    static func fetchRegistration(userId: String) -> Registration {
        
        let hostname = hostForUser(userId: userId)
        let key = "\(_registrationPrefix)\(hostname)"
        if let map = UserDefaults.standard.object(forKey: key) as? [String: Any?] {
            return Registration(dict: map)
        } else {
            return Registration(host: hostname, state: "")
        }
    }

    static func storeRegistration(registration : Registration) {
        if let hostname = registration.host {
            let key = "\(_registrationPrefix)\(hostname)"
            let map = registration.toDict()
            UserDefaults.standard.setValue( map, forKey: key)
        }
    }
    
    /// Separates hostname from usderId which is a email address
    private static func hostForUser(userId : String) -> String {
        if let hostname = userId.split(separator: "@").last {
            return String(hostname).lowercased()
        }
        return ""
    }
}
