//
//  MediaMapper.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 14/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import AliyunOSSiOS
import KipasKipasNetworking
import QCloudCOSXML

final class MediaUploadMapper {
    static func map(_ client: OSSClient, request: OSSPutObjectRequest, response: OSSTask<AnyObject>) throws -> MediaUploaderResult {
        
        print("**@@ map status code error \(String(describing: (response.error as? NSError)?.code))", client.clientConfiguration.timeoutIntervalForRequest)
        print("**@@ map result \(String(describing: (response.result)))")
        if let error = response.error {// NSError
            print("**@@ map error result:", error.localizedDescription, (error as? NSError))
            KKLoggerUpload.instance.send(error: "MediaUploadMapper Error", description: response.error?.localizedDescription ?? "")
            if (response.error as? NSError)?.code == -400 {
                throw KKNetworkError.tokenExpired
            }else if (response.error as? NSError)?.code == -403 {
                throw KKNetworkError.InvalidAccessKeyId
            }
            throw KKNetworkError.connectivity
        }
        
        if let success = response.result as? OSSPutObjectResult  {
            if success.httpResponseCode == 200 {
                var baseUrl = client.endpoint
                if baseUrl.contains("://") {
                    let endpoint = baseUrl.components(separatedBy: "://").last ?? ""
                    baseUrl = endpoint
                }
                #if Release || ProdDebug
                baseUrl = "https://asset.kipaskipas.com"
                #else
                baseUrl = "https://\(request.bucketName).\(baseUrl)"
                #endif
                let url = "\(baseUrl)/\(request.objectKey)"
                print("**@@ map result tmp url \(url)")
                let permanentUrl = "\(url.replacingOccurrences(of: "/tmp", with: ""))"
                print("**@@ map result permanent url \(url)")
                return MediaUploaderResult(tmpUrl: url, url: permanentUrl)
            }else{
                throw KKNetworkError.connectivity
            }
        }
        
        throw KKNetworkError.invalidData
    }
    
    static func map(_ result: Any?, error: Error?) throws -> MediaUploaderResult {
        if let _ = error {
            print("**@@ map error", error?.localizedDescription)
            throw KKNetworkError.connectivity
        }
        
        if let result = result as? QCloudUploadObjectResult {
            print("**@@ map success", result.key, result.location)
            return MediaUploaderResult(tmpUrl: result.location, url: result.location)
        }
        
        throw KKNetworkError.invalidData
    }
}
