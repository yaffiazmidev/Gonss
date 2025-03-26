//
//  KKLoggerUpload.swift
//  KipasKipasNetworkingUtils
//
//  Created by Rahmat Trinanda Pramudya Amar on 22/02/24.
//

import Foundation
import KipasKipasShared

class KKLoggerUpload {
    
    private static var _instance: KKLoggerUpload?
    private static let lock = NSLock()
    
    public static var instance: KKLoggerUpload {
        if _instance == nil {
            lock.lock()
            defer {
                lock.unlock()
            }
            if _instance == nil {
                _instance = KKLoggerUpload()
            }
        }
        return _instance!
    }
    
    private init() {}
    
    func send(file: String = #file, function: String = #function, error: String, description: String) {
        let msg =  "Function: \(function)\nError: \(error)\nDescription: \(description)"
        KKLogFile.instance.log(label: "Failure Upload :", message: msg)
        KKLogger.instance.send(
            title: "Failure Upload : \(file.split(separator: "/").last ?? "Unknown file")",
            message: "Function: \(function)\nError: \(error)\nDescription: \(description)"
        )
    }
}
