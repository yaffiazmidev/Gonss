//
//  TencentVODEndpoint.swift
//  KipasKipasNetworkingUtils
//
//  Created by Rahmat Trinanda Pramudya Amar on 06/11/23.
//

import Foundation

enum TencentVODEndpoint {
    case signature
    case transcode(original: AuthenticatedMediaUploaderRequest, data: TencentVODMediaUploadTranscodeRequest)
    
    func url(baseUrl: URL) -> URLRequest {
        switch self {
        case .signature:
            
            var request = URLRequest(url: baseUrl)
            request.httpMethod = "GET"
            
            return request
            
        case let .transcode(original, data):
            
            let loginString = String(format: "%@:%@", original.username ?? "", original.password ?? "")
            let loginData = loginString.data(using: String.Encoding.utf8)!
            let base64LoginString = loginData.base64EncodedString()
            
            var req = URLRequest(url: baseUrl)
            req.httpMethod = "POST"
            req.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
            req.setValue("application/json", forHTTPHeaderField: "Accept")
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let body = try? JSONEncoder().encode(data)
            print("**@@ transcode url:", baseUrl)
            print("**@@ transcode auth:", "Basic \(base64LoginString)", String(describing:  original.username), String(describing: original.password))
            print("**@@ transcode body:", String(describing: String(data: body ?? Data(), encoding: .utf8)))
            req.httpBody = body
            
            return req
        }
    }
}
