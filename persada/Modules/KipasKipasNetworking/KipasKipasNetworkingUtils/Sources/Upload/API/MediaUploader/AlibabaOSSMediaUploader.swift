//
//  OSSMediaUploadClient.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 18/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import AliyunOSSiOS
import KipasKipasNetworking
import KipasKipasShared

public final class AlibabaOSSMediaUploader: MediaUploader {
    
    private var client: OSSClient?
    private let baseUrl: String
    
    public typealias Result = MediaUploader.Result
    
    public init(baseUrl: String) {
        self.baseUrl = baseUrl
    }
    
    deinit {
        client = nil
    }
    
    public func upload(request: MediaUploaderRequestable, completion: @escaping (Result) -> Void) {
        guard let authRequest = request as? AuthenticatedMediaUploaderRequest,
              let token = authRequest.token else {
            completion(.failure(KKNetworkError.tokenNotFound))
            KKLoggerUpload.instance.send(error: "Token not Found", description: KKNetworkError.tokenNotFound.localizedDescription)
            return
        }
        
        let request = createOSSRequest(with: authRequest) { [weak self] (progress) in
            guard self != nil else { return }
        }
        
        print("**@@ createOSS alibaba upload-1 \(token.expiration)")
        
        let client = createOSSClient(with: token)
        let task = client.putObject(request)
        task.continue ({ [weak self] (response) in
            guard let self = self else { return nil }
            completion(self.map(client, request, from: response))
            
            return nil
        })
    }
    
    public func upload(request: MediaUploaderRequestable, completion: @escaping (Result) -> Void, uploadProgress: @escaping (Double) -> Void) {
        
        
        guard let authRequest = request as? AuthenticatedMediaUploaderRequest,
              let token = authRequest.token else {
            completion(.failure(KKNetworkError.tokenNotFound))
            KKLoggerUpload.instance.send(error: "Token not Found", description: KKNetworkError.tokenNotFound.localizedDescription)
            return
        }
        
        let request = createOSSRequest(with: authRequest) { [weak self] (progress) in
            guard self != nil else { return }
            uploadProgress(progress)
        }

        print("**@@ createOSS alibaba upload-2 \(token.expiration)")
        
        let client = createOSSClient(with: token)
        let task = client.putObject(request)
        task.continue ({ [weak self] (response) in
            guard let self = self else { return nil }
            completion(self.map(client, request, from: response))
            
            return nil
        })
    }
    
    private func map(_ client: OSSClient,_ request: OSSPutObjectRequest, from response: OSSTask<AnyObject>) -> Result {
        do {
            let items = try MediaUploadMapper.map(client, request: request, response: response)
            return .success(items)
        } catch {
            KKLoggerUpload.instance.send(error: "Mapping", description: error.localizedDescription)
            return .failure(error)
        }
    }
    
}


// MARK: - Alibaba Helper
private extension AlibabaOSSMediaUploader {
    
    private func createOSSClient(with token: STSTokenItem) -> OSSClient {
        if let client = self.client {
            return client
        }
        let ossToken = OSSFederationToken()
        ossToken.tAccessKey = token.accessKeyID
        ossToken.tSecretKey = token.accessKeySecret
        ossToken.tToken = token.securityToken
        
        let credentials = OSSFederationCredentialProvider(federationTokenGetter: { return ossToken }) as OSSCredentialProvider
        let config = OSSClientConfiguration()
        config.timeoutIntervalForRequest = 180
        let client = OSSClient(endpoint: baseUrl, credentialProvider: credentials, clientConfiguration: config)
        print("**@@ time out second", client.clientConfiguration.timeoutIntervalForRequest)
        self.client = client
        return client
    }
    
    private func createOSSRequest(with request: AuthenticatedMediaUploaderRequest, uploadProgress: @escaping (Double) -> Void) -> OSSPutObjectRequest {
        let fileName = Date().millisecondsSince1970
        let req = OSSPutObjectRequest()
        req.uploadingData = request.media
        req.objectKey = "img/tmp/media/\(fileName).\(request.ext)"
        req.bucketName = UploadConstants.Alibaba.bucketName
        req.uploadProgress = { [weak self] (bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) in
            guard self != nil else { return }
            let percent = Double(totalBytesSent) / Double(totalBytesExpectedToSend) // range between 0 & 1
            uploadProgress(percent)
        }
        return req
    }
}

