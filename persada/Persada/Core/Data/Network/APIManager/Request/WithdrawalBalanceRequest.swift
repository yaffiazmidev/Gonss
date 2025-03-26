//
//  WithdrawalBalanceRequest.swift
//  KipasKipas
//
//  Created by iOS Dev on 25/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import Alamofire

struct WithdrawalBalanceInfoRequest: URLRequestConvertible, GeneralRequest {
    
    var method: HTTPMethod = HTTPMethod.get
    var parameters: [String : Any]?
    var headers: [String : String]? = GeneralRequestHeaderType.general.heeaderValue
    
    var path: String {
        return APIConstants.baseURL + "/balance/info"
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

struct ListBankAccountUserRequest: URLRequestConvertible, GeneralRequest {
    var method: HTTPMethod = HTTPMethod.get
    var parameters: [String : Any]?
    var headers: [String : String]? = GeneralRequestHeaderType.general.heeaderValue
    
    var path: String {
        return APIConstants.baseURL + "/bankaccounts/all"
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

struct VerifyPasswordRequest: URLRequestConvertible, GeneralRequest {
    var method: HTTPMethod = HTTPMethod.post
    var parameters: [String : Any]?
    var headers: [String : String]? = GeneralRequestHeaderType.general.heeaderValue
    let password: String
    
    var path: String {
        return APIConstants.baseURL + "/balance/verify?password=\(password)"
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


struct DeleteBankAccountRequest: URLRequestConvertible, GeneralRequest {
    var method: HTTPMethod = HTTPMethod.delete
    var parameters: [String : Any]?
    var headers: [String : String]? = GeneralRequestHeaderType.general.heeaderValue
    let id: String
    
    var path: String {
        return APIConstants.baseURL + "/bankaccounts/\(id)"
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

struct WithdrawalBalanceRequest: URLRequestConvertible, GeneralRequest {
    var method: HTTPMethod = HTTPMethod.post
    var headers: [String : String]? = GeneralRequestHeaderType.general.heeaderValue
    var parameters: [String : Any]? {
        return [
            "nominal" : nominal,
            "accountBalanceType" : accountBalanceType,
            "bankAccountId" : bankAccountId
        ]
    }
    
    let nominal: Int
    let accountBalanceType: String
    let bankAccountId: String
    let isGopay: Bool
    
    var path: String {
        return APIConstants.baseURL + "/balance/withdrawl\(isGopay ? "/payout" : "")"
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
