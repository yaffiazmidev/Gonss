//
//  HistoryTransactionRequest.swift
//  KipasKipas
//
//  Created by iOS Dev on 21/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import Alamofire

enum TypeHistoryTransaction: String {
    case refund = "REFUND"
    case transaction = "TRANSACTION"
    case commission = "COMMISSION"
    case reseller = "MODAL"
}

struct HistoryTransactionRequest: URLRequestConvertible, GeneralRequest {
    
    var method: HTTPMethod = HTTPMethod.get
    var parameters: [String : Any]?
    var headers: [String : String]? = GeneralRequestHeaderType.general.heeaderValue
    
    var path: String {
        return APIConstants.baseURL + "/balance/history"
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

struct HistoryTransactionDetailRequest: URLRequestConvertible, GeneralRequest {
    
    var method: HTTPMethod = HTTPMethod.get
    var parameters: [String : Any]?
    var headers: [String : String]? = GeneralRequestHeaderType.general.heeaderValue
    
    var type: TypeHistoryTransaction
    var orderId: String
    
    var path: String {
        switch type {
        case .transaction, .commission, .reseller:
            return APIConstants.baseURL + "/orders/\(orderId)"
        default:
            return APIConstants.baseURL + "/orders/refund/\(orderId)"
        }
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

struct HistoryTransactionFilterRequest: URLRequestConvertible, GeneralRequest {
    var path: String {
        return APIConstants.baseURL + "/balance/history/filter"
    }
    var method: HTTPMethod = HTTPMethod.post
    var headers: [String : String]? = GeneralRequestHeaderType.json.heeaderValue
    
    var dateFrom: Int
    var dateTo: Int
    var typeTransaction: String
    
    var parameters: [String : Any]? {
        return [
            "startDate" : dateFrom,
            "endDate" : dateTo,
            "balanceType" : typeTransaction
        ]
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
