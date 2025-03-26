//
//  VerifyIdentityLoaderFactory.swift
//  KipasKipasVerificationIdentity
//
//  Created by DENAZMI on 07/06/24.
//

import Foundation
import KipasKipasShared
import KipasKipasNetworking
import KipasKipasNetworkingUtils

public enum VerifyIdentityLoaderItem {
    case country
    case uploadIdentity
    case verificationStatus
    case mediaUploader
}

public class VerifyIdentityLoaderFactory {
    
    public static let shared = VerifyIdentityLoaderFactory()
    
    private var baseURL: URL?
    private var toolsURL: URL?
    private var httpClient: HTTPClient?
    private var authHTTPClient: HTTPClient?
    
    public func setClient(
        baseURL: URL,
        toolsURL: URL,
        httpClient: HTTPClient,
        authHTTPClient: HTTPClient
    )  {
        self.baseURL = baseURL
        self.toolsURL = toolsURL
        self.httpClient = httpClient
        self.authHTTPClient = authHTTPClient
    }
    
    public func get<T>(_ item: VerifyIdentityLoaderItem) -> T {
        guard let baseURL = baseURL else {
            fatalError("baseURL not set")
        }
        
        guard let client = authHTTPClient else {
            fatalError("client not set")
        }
        
        switch item {
        case .country:
            let decoratee: VerifyIdentityCountryLoader = RemoteVerifyIdentityCountryLoader(baseURL: baseURL, client: client)
            guard let loader = MainQueueDispatchDecorator(decoratee: decoratee) as? T else {
                fatalError("Type mismatch: Expected \(T.self), but got RemoteVerifyIdentityCountryLoader")
            }
            return loader
        case .uploadIdentity:
            let decoratee: VerifyIdentityUploader = RemoteVerifyIdentityUploader(baseURL: baseURL, client: client)
            guard let uploader = MainQueueDispatchDecorator(decoratee: decoratee) as? T else {
                fatalError("Type mismatch: Expected \(T.self), but got RemoteVerifyIdentityUploader")
            }
            return uploader
        case .verificationStatus:
            let decoratee: VerifyIdentityStatusLoader = RemoteVerifyIdentityStatusLoader(baseURL: baseURL, client: client)
            guard let loader = MainQueueDispatchDecorator(decoratee: decoratee) as? T else {
                fatalError("Type mismatch: Expected \(T.self), but got RemoteVerifyIdentityProcessLoader")
            }
            return loader
            
        case .mediaUploader:
            let decoratee: MediaUploader = MediaUploadManager()
            guard let loader = MainQueueDispatchDecorator(decoratee: decoratee) as? T else {
                fatalError("Type mismatch: Expected \(T.self), but got MediaUploadManager")
            }
            return loader
        }
    }
}

extension MainQueueDispatchDecorator: VerifyIdentityCountryLoader where T == VerifyIdentityCountryLoader {
    public func load(completion: @escaping (VerifyIdentityCountryLoader.Result) -> Void) {
        decoratee.load{ [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: VerifyIdentityUploader where T == VerifyIdentityUploader {
    public func upload(_ request: VerifyIdentityUploadParam, completion: @escaping (VerifyIdentityUploader.Result) -> Void) {
        decoratee.upload(request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: VerifyIdentityStatusLoader where T == VerifyIdentityStatusLoader {
    public func load(completion: @escaping (VerifyIdentityStatusLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
