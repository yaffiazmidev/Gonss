//
//  KKMediaItemExtension.swift
//  KipasKipasShared
//
//  Created by Rahmat Trinanda Pramudya Amar on 18/03/24.
//

import Foundation

public class KKMediaItemExtension {
    public static let photoExtension: [String] = ["jpg", "jpeg", "heic", "heif", "tiff", "gif", "png", "dib", "ico", "cur", "xbm"]
    
    public static let videoExtension: [String] = ["3gp", "mp4", "hevc", "m4v", "mov"]
    
    /// Get item type from extension only, filepath, filename with extensions
    public class func from(_ string: String) -> KKMediaItemType? {
        let s = string.lowercased()
        
        if hasSuffix(s, from: photoExtension) {
            return .photo
        }
        
        if hasSuffix(s, from: videoExtension) {
            return .video
        }
        
        return nil
    }
    
    /// Decide filepath, filename or extension only is photo
    public class func isPhoto(_ string: String) -> Bool {
        return from(string) == .photo
    }
    
    /// Decide filepath, filename or extension only is video
    public class func isVideo(_ string: String) -> Bool {
        return from(string) == .video
    }
    
    private class func hasSuffix(_ string: String, from array: [String]) -> Bool {
        for item in array {
            if string.hasSuffix(item) {
                return true
            }
        }
        
        return false
    }
}
