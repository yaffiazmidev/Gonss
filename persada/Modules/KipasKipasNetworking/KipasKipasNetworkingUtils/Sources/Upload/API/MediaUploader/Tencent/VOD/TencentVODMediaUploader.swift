//
//  TencentVODMediaUploader.swift
//  KipasKipasNetworkingUtils
//
//  Created by Rahmat Trinanda Pramudya Amar on 05/11/23.
//

import Foundation
import KipasKipasNetworking

public final class TencentVODMediaUploader: NSObject, MediaUploader {
    
    private var publisher: TXUGCPublish?
    private let signatureUrl: URL
    private let transcodeUrl: URL
    private let client: HTTPClient
    
    public typealias Result = MediaUploader.Result
    private typealias ParamResult = Swift.Result<TXPublishParam, Error>
    private typealias SignatureResult = Swift.Result<String, Error>
    
    private var request: MediaUploaderRequestable?
    private var completion: ((Result) -> Void)?
    private var uploadProgress: ((Double) -> Void)?
    
    private var IS_TRANSCODE_ENABLE = false // is use Tencent Trancode ?
    
    public init(signatureUrl: URL, transcodeUrl: URL, client: HTTPClient) {
        self.signatureUrl = signatureUrl
        self.transcodeUrl = transcodeUrl
        self.client = client
        super.init()
    }
    
    deinit {
        destroy()
    }
    
    public func upload(request: MediaUploaderRequestable, completion: @escaping (Result) -> Void) {
        createParam(with: request) { [weak self] result in
            guard let self = self else {
                completion(.failure(KKNetworkError.failed))
                return
            }
            
            switch result {
            case let .success(param):
                let res = self.publisher?.publishVideo(param) ?? -100
                self.handlePublishResult(code: res) {
                    self.request = request
                    self.completion = completion
                } onError: { error in
                    completion(.failure(error))
                    self.destroy()
                }
                
            case let .failure(error):
                print("**@@ error create param", error.localizedDescription)
                completion(.failure(error))
                self.destroy()
            }
        }
    }
    
    public func upload(request: MediaUploaderRequestable, completion: @escaping (Result) -> Void, uploadProgress: @escaping (Double) -> Void) {
        createParam(with: request) { [weak self] result in
            guard let self = self else {
                completion(.failure(KKNetworkError.failed))
                return
            }
            
            switch result {
            case let .success(param):
                let res = self.publisher?.publishVideo(param) ?? -100
                self.handlePublishResult(code: res) {
                    self.request = request
                    self.completion = completion
                    self.uploadProgress = uploadProgress
                } onError: { error in
                    completion(.failure(error))
                    self.destroy()
                }
                
            case let .failure(error):
                print("**@@ error create param", error.localizedDescription)
                completion(.failure(error))
                self.destroy()
            }
        }
    }
}

// MARK: - Tencent Helper
private extension TencentVODMediaUploader {
    private func createParam(with request: MediaUploaderRequestable, completion: @escaping (ParamResult) -> Void) {
        if publisher == nil {
            publisher = TXUGCPublish()
            publisher?.delegate = self
        }
        
        let directory = NSTemporaryDirectory()
        let fileName = "\(Date().millisecondsSince1970).\(request.ext)"
        guard let fileUrl = NSURL.fileURL(withPathComponents: [directory, fileName]),
              let _ = createTmpFile(data: request.media, fileUrl: fileUrl) else {
            completion(.failure(KKNetworkError.invalidData))
            KKLoggerUpload.instance.send(error: "Create Param", description: "Invalid Data")
            return
        }
        let filePath = fileUrl.path
        print("**@@ file path:", filePath)
        
        loadSignature { result in
            switch result {
            case let .success(signature):
                let param = TXPublishParam()
                param.signature = signature
                param.secretId = UploadConstants.Tencent.VOD.secretId
                param.videoPath = filePath
                param.enablePreparePublish = false
                completion(.success(param))
            case let .failure(error):
                KKLoggerUpload.instance.send(error: "Create Param", description: error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
    private func createTmpFile(data: Data, fileUrl: URL) -> Bool? {
        do {
            try data.write(to: fileUrl, options: .atomic)
            return true
        } catch {
            KKLoggerUpload.instance.send(error: "Create Temp File", description: error.localizedDescription)
            print("**@@ createTmpFile error", error)
        }
        
        return nil
    }
    
    private func handlePublishResult(code: Int32, onSuccess: () -> Void, onError: (KKNetworkError) -> Void) {
        switch code {
        case 0:
            onSuccess()
        case -1:
            KKLoggerUpload.instance.send(error: "Result", description: "There is an upload process in progress")
            onError(KKNetworkError.responseFailure(KKErrorNetworkResponse(code: "\(code)", message: "There is an upload process in progress")))
        case -2:
            KKLoggerUpload.instance.send(error: "Result", description: "Invalid Data")
            onError(KKNetworkError.responseFailure(KKErrorNetworkResponse(code: "\(code)", message: "Invalid Data")))
        case -4:
            KKLoggerUpload.instance.send(error: "Result", description: "Invalid Signature")
            onError(KKNetworkError.responseFailure(KKErrorNetworkResponse(code: "\(code)", message: "Invalid Signature")))
        default:
            KKLoggerUpload.instance.send(error: "Result", description: "Unknown Error")
            onError(KKNetworkError.responseFailure(KKErrorNetworkResponse(code: "-100", message: "Unknown Error")))
        }
    }
    
    private func destroy() {
        publisher = nil
        completion = nil
        uploadProgress = nil
    }
}

// MARK: - Signature Helper
private extension TencentVODMediaUploader {
    private func loadSignature(completion: @escaping (SignatureResult) -> Void) {
        let request = TencentVODEndpoint.signature.url(baseUrl: signatureUrl)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                let signature = try TencentVODMediaUploader.mapSignature(data, from: response)
                completion(.success(signature))
            } catch {
                print("**@@ failed get signature:", error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
    private static func mapSignature(_ data: Data, from response: HTTPURLResponse) throws -> String {
        do {
            let items = try TencentVODMediaUploadSignatureMapper.map(data, from: response)
            return items
        } catch {
            throw error
        }
    }
}

// MARK: - Transcode Helper
private extension TencentVODMediaUploader {
    private func processTranscode(videoUrl: String, videoId: String) {
        guard let request = request as? AuthenticatedMediaUploaderRequest else {
            completion?(.failure(KKNetworkError.invalidData))
            return
        }
        
        let transcodeId = Int(UploadConstants.Tencent.VOD.Transcode.id) ?? 0
        let data = TencentVODMediaUploadTranscodeRequest(videoId: videoId, transcodeId: transcodeId)
        let transcodeRequest = TencentVODEndpoint.transcode(original: request, data: data).url(baseUrl: transcodeUrl)
        
        Task {

            if(IS_TRANSCODE_ENABLE){
                do {
                    let (data, response) = try await client.request(from: transcodeRequest)
                    let url = try TencentVODMediaUploader.mapTranscode(data, from: response)
                    print("**@@ success transcode:", url)
                    
                } catch {
                    KKLoggerUpload.instance.send(error: "Transcode", description: error.localizedDescription)
                    print("**@@ failed transcode:", error.localizedDescription)
                }
            }
            
            self.completion?(.success(
                MediaUploaderResult(
                    tmpUrl: videoUrl,
                    url: videoUrl,
                    vod: MediaUploaderVODResult(id: videoId, url: videoUrl)
                )
            ))
            self.destroy()
        }
    }
    
    private static func mapTranscode(_ data: Data, from response: HTTPURLResponse) throws -> Bool {
        do {
            let items = try TencentVODMediaUploadTranscodeMapper.map(data, from: response)
            return items
        } catch {
            KKLoggerUpload.instance.send(error: "Mapping Transcode", description: error.localizedDescription)
            throw error
        }
    }
}

// MARK: - Publish Listener
extension TencentVODMediaUploader: TXVideoPublishListener {
    public func onPublishEvent(_ evt: [AnyHashable : Any]!) {}
    
    public func onPublishProgress(_ uploadBytes: Int, totalBytes: Int) {
        print("**@@ progress", Double(uploadBytes)/Double(totalBytes), uploadBytes, totalBytes)
        let percent = Double(uploadBytes) / Double(totalBytes) // range between 0 & 1
        uploadProgress?(percent)
    }
    
    public func onPublishComplete(_ result: TXPublishResult!) {
        print("**@@ complete", result.retCode, String(describing: result.descMsg), String(describing: result.videoId), String(describing: result.videoURL))
        if result.retCode == 0 {
            processTranscode(videoUrl: result.videoURL, videoId: result.videoId)
        } else {
            let error = KKNetworkError.responseFailure(KKErrorNetworkResponse(code: "\(result.retCode)", message: result.descMsg))
            completion?(.failure(error))
            destroy()
        }
    }
}
