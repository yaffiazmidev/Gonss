//
//  InputUserEndpoint.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 15/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

enum InputUserEndpoint {
    case checkEmail(request: EmailValidatorRequest)
    case checkUsername(request: UsernameValidatorRequest)
    case create(request: CreateUserRequest)
    case upload(request: UserPhotoUploadRequest)
    
    func url(baseURL: URL) -> URLRequest {
        switch self {
        case let .checkEmail(request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/auth/registers/accounts/exists-by"
            components.queryItems = [
                URLQueryItem(name: "email", value: "\(request.email)"),
            ].compactMap { $0 }
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "GET"
            return request
        case let .checkUsername(request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/auth/registers/accounts/exists-by"
            components.queryItems = [
                URLQueryItem(name: "username", value: "\(request.username)"),
            ].compactMap { $0 }
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "GET"
            return request
        case let .create(request):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/auth/registers"
            let body = try! JSONEncoder().encode(request)
                        
            var urlRequest = URLRequest(url: components.url!)
            urlRequest.httpBody = body
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return urlRequest
        case let .upload(request):
            
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/accounts"

            let boundary = "Boundary-\(UUID().uuidString)"
            
            var urlRequest = URLRequest(url: components.url!)
            urlRequest.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            let httpBody = convertFileData(
                fieldName: "file",
                fileName: "imagename.jpg",
                mimeType: "image/jpeg",
                fileData: request.imageData,
                using: boundary
            )
            
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = httpBody
            
            return urlRequest
        }
    }
    
    private func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
        let lineBreak = "\r\n"
        var data = Data()
        
        data.append("--\(boundary)\r\n")
        data.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        data.append("Content-Type: \(mimeType)\r\n\r\n")
        data.append(fileData)
        data.append("\r\n")
        
        data.append("--\(boundary)--\(lineBreak)")
      return data
    }

}


extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}




