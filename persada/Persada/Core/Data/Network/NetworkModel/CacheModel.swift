//
//  CacheModel.swift
//  Persada
//
//  Created by Muhammad Noor on 23/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Disk
import Foundation

let CACHE = CacheModel.share

struct KeyObject {
    static let authLogin = "authLogin.json"
}

public class CacheModel: NSObject {
    public static let share = CacheModel()
    
    public enum CacheKeyObject {
        case authLogin
    }
    
    var onSuccessSaveObjectWith: ((_ object: CacheKeyObject) -> Void)?
    var onFailureSaveObjectWith: ((_ object: CacheKeyObject) -> Void)?
    
    var onSuccessClearObjectWith: (() -> Void)?
    var onFailureClearObjectWith: (() -> Void)?
    
    public override init() {}
    
    public func setObject<T: Encodable>(_ value: T, to directory: Disk.Directory, as path: String, keyObject: CacheKeyObject) {
        do {
            try Disk.save(value, to: directory, as: path)
            self.onSuccessSaveObjectWith?(keyObject)
        } catch {
            self.onFailureSaveObjectWith?(keyObject)
        }
    }
    
    public func retrievedObject<T: Decodable>(_ value: T.Type, to directory: Disk.Directory, as path: String, onSuccess: ((_ object: T) -> Void)?, onFailure: (() -> Void)?) {
        do {
            if Disk.exists(path, in: directory) {
                let retrieve = try Disk.retrieve(path, from: directory, as: value)
                onSuccess?(retrieve)
            } else {
                onFailure?()
            }
        } catch let error as NSError {
            fatalError("""
                Domain: \(error.domain)
                Code: \(error.code)
                Description: \(error.localizedDescription)
                Failure Reason: \(error.localizedFailureReason ?? "")
                Suggestions: \(error.localizedRecoverySuggestion ?? "")
                """)
        }
    }
    
    public func clearObject(forPath: String, onSuccessClearObjectWith: (() -> Void)?, onFailureClearObjectWith: (() -> Void)?) {
        do {
            let fileUrl = try Disk.url(for: forPath, in: .caches)
            if Disk.exists(fileUrl) {
                try Disk.remove(fileUrl)
                onSuccessClearObjectWith?()
            }
        } catch let error as NSError {
            onFailureClearObjectWith?()
            fatalError("""
                Domain: \(error.domain)
                Code: \(error.code)
                Description: \(error.localizedDescription)
                Failure Reason: \(error.localizedFailureReason ?? "")
                Suggestions: \(error.localizedRecoverySuggestion ?? "")
                """)
        }
    }
    
    public func onSuccessSaveObjectWith(_ completion: ((_ keyObject: CacheKeyObject) -> Void)?) -> CacheModel {
        self.onSuccessSaveObjectWith = completion
        return self
    }
    
    public func onFailureSaveObjectWith(_ completion: ((_ keyObject: CacheKeyObject) -> Void)?) {
        self.onFailureSaveObjectWith = completion
    }
}
