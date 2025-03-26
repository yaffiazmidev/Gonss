//
//  RemoteCOSMediaUploadClient.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 17/05/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import QCloudCOSXML
import KipasKipasNetworking

final class TencentCOSMediaUploader: NSObject, MediaUploader{
    
    private var credentialFenceQueue: QCloudCredentailFenceQueue? = nil
    
    typealias Result = MediaUploader.Result
    
    override init() {
        super.init()
        self.configure()
    }
    
    deinit {
        credentialFenceQueue = nil
    }
    
    func upload(request: MediaUploaderRequestable, completion: @escaping (Result) -> Void) {
        let request = createRequest(with: request)
        
        request.finishBlock = { [weak self] (result, error) in
            guard self != nil else { return }
            completion(TencentCOSMediaUploader.map(result, error))
        }
        QCloudCOSTransferMangerService.defaultCOSTransferManager().uploadObject(request)
    }
    
    func upload(request: MediaUploaderRequestable, completion: @escaping (Result) -> Void, uploadProgress: @escaping (Double) -> Void) {
        let request = createRequest(with: request) { [weak self] (progress) in
            guard self != nil else { return }
            uploadProgress(progress)
        }
        
        request.finishBlock = { [weak self] (result, error) in
            guard self != nil else { return }
            completion(TencentCOSMediaUploader.map(result, error))
        }
        QCloudCOSTransferMangerService.defaultCOSTransferManager().uploadObject(request)
    }
}

// MARK: General Helper
private extension TencentCOSMediaUploader {
    private func configure(){
        if self.credentialFenceQueue != nil { return }
        let config = QCloudServiceConfiguration.init()
        config.signatureProvider = self
        let endpoint = QCloudCOSXMLEndPoint.init()
        endpoint.regionName = UploadConstants.Tencent.COS.region
        endpoint.useHTTPS = true
        config.endpoint = endpoint
        QCloudCOSXMLService.registerDefaultCOSXML(with: config)
        QCloudCOSTransferMangerService.registerDefaultCOSTransferManger(with: config)
        
        self.credentialFenceQueue = QCloudCredentailFenceQueue()
        self.credentialFenceQueue?.delegate = self
    }
    
    private static func map(_ result: Any?, _ error: Error?) -> Result {
        do {
            let items = try MediaUploadMapper.map(result, error: error)
            return .success(items)
        } catch {
            KKLoggerUpload.instance.send(error: "Mapping", description: error.localizedDescription)
            return .failure(error)
        }
    }
}

// MARK: Tencent Helper
private extension TencentCOSMediaUploader {
    private func createRequest(with request: MediaUploaderRequestable, uploadProgress: ((Double) -> Void)? = nil) -> QCloudCOSXMLUploadObjectRequest<AnyObject> {
        if self.credentialFenceQueue == nil {
            self.configure()
        }
        
        let date = Date()
        let fileName = date.millisecondsSince1970
        let format = DateFormatter()
        format.dateFormat = "yyyyMMdd"
        format.timeZone = TimeZone.init(identifier: "Asia/Jakarta")
        let path = format.string(from: date)
        
        let req = QCloudCOSXMLUploadObjectRequest<AnyObject>.init()
        req.bucket = UploadConstants.Tencent.COS.bucketName
        req.regionName = UploadConstants.Tencent.COS.region
        req.object =  "origin/\(path)/\(fileName).\(request.ext)"
        req.body = request.media as NSData
        req.sendProcessBlock = { [weak self] (bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) in
            guard self != nil else { return }
            let percent = Double(totalBytesSent) / Double(totalBytesExpectedToSend) // range between 0 & 1
            uploadProgress?(percent)
        }
        return req
    }
}

// MARK: - Tencent Signature Delegate
extension TencentCOSMediaUploader: QCloudSignatureProvider {
    func signature(with fileds: QCloudSignatureFields!, request: QCloudBizHTTPRequest!, urlRequest urlRequst: NSMutableURLRequest!, compelete continueBlock: QCloudHTTPAuthentationContinueBlock!) {
        if let queue = self.credentialFenceQueue {
            queue.performAction({ [weak self] (creator, error) in
                guard self != nil else { return }
                if error != nil {
                    continueBlock(nil, error!)
                }else{
                    let signature = creator?.signature(forData: urlRequst)
                    continueBlock(signature, nil)
                }
            })
            return
        }
        continueBlock(nil, KKNetworkError.connectivity)
    }
}

// MARK: - Tencent Credential Delegate
extension TencentCOSMediaUploader: QCloudCredentailFenceQueueDelegate {
    func fenceQueue(_ queue: QCloudCredentailFenceQueue!, requestCreatorWithContinue continueBlock: QCloudCredentailFenceQueueContinue!) {
        let cre = QCloudCredential.init()
        cre.secretID = UploadConstants.Tencent.COS.secretId
        cre.secretKey = UploadConstants.Tencent.COS.secretKey
        cre.startDate = Date()
        cre.expirationDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())
        let auth = QCloudAuthentationV5Creator.init(credential: cre)
        continueBlock(auth, nil)
    }
}
