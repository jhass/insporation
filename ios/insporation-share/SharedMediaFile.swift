//
//  SharedMediaFile.swift
//  Runner
//
//  Created by Thorsten Claus on 02.12.20.
//

import Foundation

enum SharedMediaType: Int, Codable {
    case image
    case video
    case file
}

class SharedMediaFile: Codable {
    var path: String; // can be image, video or url path. It can also be text content
    var thumbnail: String?; // video thumbnail
    var duration: Double?; // video duration in milliseconds
    var type: SharedMediaType;
    
    
    init(path: String, thumbnail: String?, duration: Double?, type: SharedMediaType) {
        self.path = path
        self.thumbnail = thumbnail
        self.duration = duration
        self.type = type
    }
    
    // Debug method to print out SharedMediaFile details in the console
    func toString() {
        print("[SharedMediaFile] \n\tpath: \(self.path)\n\tthumbnail: \(String(describing: self.thumbnail))\n\tduration: \(String(describing: self.duration))\n\ttype: \(self.type)")
    }
}
