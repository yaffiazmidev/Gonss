//
//  AuthMediaUploadClient.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 18/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class AuthenticatedMediaUploadClientDecorator : MediaUploader {
    
    private let keystore: String
    private let decoratee: MediaUploader
    private let loader: STSTokenLoader
    
    typealias Result = Swift.Result<MediaUploaderResult, Error>
    
    init(keystore: String, decoratee: MediaUploader, loader: STSTokenLoader) {
        self.keystore = keystore
        self.decoratee = decoratee
        self.loader = loader
    }
    
    func upload(request: MediaUploaderRequestable, completion: @escaping (Result) -> Void) {
        guard var request = request as? AuthenticatedMediaUploaderRequest else {
            completion(.failure(KKNetworkError.invalidData))
            return
        }
        
//        if let token = request.token {
//            reqWithToken.token = token
//            decoratee.upload(request: reqWithToken, completion: completion, uploadProgress: uploadProgress)
//            return
//        }
        
        guard let username = request.username, let password = request.password else {
            completion(.failure(KKNetworkError.invalidData))
            return
        }
        
        let reqSTSToken = STSTokenLoaderRequest(keystore: keystore, username: username, password: password)
        loader.load(request: reqSTSToken) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(item):
                request.token = item
                self.decoratee.upload(request: request, completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    func upload(request: MediaUploaderRequestable, completion: @escaping (Result) -> Void, uploadProgress: @escaping (Double) -> Void) {
        guard var request = request as? AuthenticatedMediaUploaderRequest else {
            completion(.failure(KKNetworkError.invalidData))
            return
        }
        
//        if let token = request.token {
//            reqWithToken.token = token
//            decoratee.upload(request: reqWithToken, completion: completion, uploadProgress: uploadProgress)
//            return
//        }
        
        guard let username = request.username, let password = request.password else {
            completion(.failure(KKNetworkError.invalidData))
            return
        }
        
        let reqSTSToken = STSTokenLoaderRequest(keystore: keystore, username: username, password: password)
        loader.load(request: reqSTSToken) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(item):
                request.token = item
                self.decoratee.upload(request: request, completion: completion, uploadProgress: uploadProgress)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
