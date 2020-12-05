//
//  SharedHandler.swift
//  Runner
//
//  Created by Thorsten Claus on 02.12.20.
//

import Foundation

class SharedHandler {
    
    private static let sharedSubjectKey = "SharedSubjectKey"
    private static let sharedTextKey = "SharedTextKey"
    private static let sharedMediaKey = "SharedMediaKey"
    private static let sharedUrlKey = "SharedUrlKey"
    
    /// Builds a map to share for the types
    /// text, Url, and Image. Url and Image can have a separate subject
    static func buildMapFromSharedUserDefaults() -> [String: Any]? {
        guard let userDefaults = UserDefaults(suiteName: "group.\(AppDelegate.hostAppBundleIdentifier)") else {
            return [:]
        }
        
        // URL => URL + subject
        // Image => Image + Subject
        // Text => Text
        
        // Shared text
        if let sharedText = userDefaults.value(forKey: sharedTextKey) as? [String] {
            userDefaults.removeObject(forKey: sharedTextKey)
            return ["type" : "text",
                    "text" : sharedText.joined()]
        }
        
        // Shared URL
        if let sharedUrl = userDefaults.value(forKey: sharedUrlKey) as? [String] {
            var shareMap =  ["type" : "text",
                             "text" : sharedUrl.joined()]
            if let subjectText = userDefaults.value(forKey: sharedSubjectKey) as? String {
                shareMap["subject"] = subjectText
            }
            userDefaults.removeObject(forKey: sharedUrlKey)
            userDefaults.removeObject(forKey: sharedSubjectKey)
            return shareMap
        }
        
        if let sharedImageData = userDefaults.value(forKey: sharedMediaKey) as? Data {
            let sharedImages = fromData(sharedImageData)
            
            var imageUrls = [String]()
            sharedImages.forEach { (sharedMediaFile) in
                imageUrls.append(sharedMediaFile.path)
            }
            
            var shareMap = ["type" : "images",
                            "images" : imageUrls] as [String : Any]
            if let subjectText = userDefaults.value(forKey: sharedSubjectKey) as? String {
                shareMap["text"] = subjectText
            }
            
            userDefaults.removeObject(forKey: sharedMediaKey)
            userDefaults.removeObject(forKey: sharedSubjectKey)
            return shareMap as [String : Any]
        }
        
        return nil
    }    
}
extension SharedHandler {
    static func fromData(_ data: Data) -> [SharedMediaFile] {
        let decodedData = try? JSONDecoder().decode([SharedMediaFile].self, from: data)
        return decodedData!
    }
}
