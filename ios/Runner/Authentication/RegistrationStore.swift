//
//  RegistrationStore.swift
//  Runner
//
//  Created by Thorsten Claus on 18.10.20.
//
import Foundation

class RegistrationStore {
    
    private static let _registrationPrefix = "registration_"
    
    /// Fetches a Registration object for a special userId from iOS store
    /// - Parameter userId: Diaspora UserId
    static func fetchRegistration(forUserId userId: String) -> Registration? {
        let hostname = StateHandler.hostForUser(userId: userId)
        let key = "\(_registrationPrefix)\(hostname)"
        if let jsonCoded = UserDefaults.standard.data(forKey: key) {
            return try? JSONDecoder().decode(Registration.self, from: jsonCoded)
        }
        return nil
    }
    
    static func storeRegistration(_ registration : Registration) {
        if let hostname = registration.host {
            let jsonenCoded = try? JSONEncoder().encode(registration)
            let key = "\(_registrationPrefix)\(hostname)"
            UserDefaults.standard.setValue(jsonenCoded, forKey: key)
        }
    }
}
