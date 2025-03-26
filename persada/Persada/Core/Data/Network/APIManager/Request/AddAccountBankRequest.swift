//
//  AddAccountBankRequest.swift
//  KipasKipas
//
//  Created by iOS Dev on 28/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import Alamofire

struct ListBankRequest: URLRequestConvertible, GeneralRequest {
    var method: HTTPMethod = HTTPMethod.get
    var parameters: [String : Any]?
    var headers: [String : String]? = GeneralRequestHeaderType.general.heeaderValue
    
    var pages: Int
    var limit: Int = 20
    
    var path: String {
        return APIConstants.baseURL + "/admin/banks/?page=\(pages)&size=\(limit)"
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = URL(string: path)!
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.httpMethod = method.rawValue
        urlRequest.timeoutInterval = 120
        urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        return urlRequest;
    }
    
}

struct CheckAccountBankRequest: URLRequestConvertible, GeneralRequest {
    var method: HTTPMethod = HTTPMethod.post
    var parameters: [String : Any]? {
        return [
            "bankCode" : bankCode,
            "accountNumber" : accountNumber
        ]
    }
    var headers: [String : String]? = GeneralRequestHeaderType.general.heeaderValue
    
    var bankCode: String
    var accountNumber: String
    
    var path: String {
        return APIConstants.baseURL + "/bankaccounts/check"
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = URL(string: path)!
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.httpMethod = method.rawValue
        urlRequest.timeoutInterval = 120
        if let parameters = parameters {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
            }
        }
        return urlRequest;
    }
}

struct OTPRequest: URLRequestConvertible, GeneralRequest {
    var method: HTTPMethod = HTTPMethod.post
    var parameters: [String : Any]?
    var headers: [String : String]? = GeneralRequestHeaderType.general.heeaderValue
    
    var path: String {
        return APIConstants.baseURL + "/bankaccounts/request-otp"
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = URL(string: path)!
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.httpMethod = method.rawValue
        urlRequest.timeoutInterval = 120
        urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        return urlRequest;
    }
}

struct AddBankRequest: URLRequestConvertible, GeneralRequest {
    var method: HTTPMethod = HTTPMethod.post
    var parameters: [String : Any]? {
        return [
            "bankCode" : bankCode,
            "accountName" : accountName,
            "accountNumber" : accountNumber,
            "otpCode": otpCode
        ]
    }
    var headers: [String : String]? = GeneralRequestHeaderType.general.heeaderValue
    
    var path: String {
        return APIConstants.baseURL + "/bankaccounts"
    }
    
    var bankCode: String
    var accountName: String
    var accountNumber: String
    var otpCode: String
    
    func asURLRequest() throws -> URLRequest {
        let url = URL(string: path)!
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.httpMethod = method.rawValue
        urlRequest.timeoutInterval = 120
        if let parameters = parameters {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
            }
        }
        return urlRequest;
    }
}

struct SearchBankName: URLRequestConvertible, GeneralRequest {
    var method: HTTPMethod = HTTPMethod.get
    var parameters: [String : Any]?
    var headers: [String : String]? = GeneralRequestHeaderType.general.heeaderValue
    
    var path: String {
        return APIConstants.baseURL + "/admin/banks/search?name=\(query)"
    }
    
    var query: String
    
    func asURLRequest() throws -> URLRequest {
        let url = URL(string: path)!
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.httpMethod = method.rawValue
        urlRequest.timeoutInterval = 120
        urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        return urlRequest;
    }
}
