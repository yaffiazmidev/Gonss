//
//  GeneralResponse.swift
//  KipasKipas
//
//  Created by iOS Dev on 21/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import Alamofire

struct GeneralResponseType<T:Codable>: Codable {
    let message: String
    let code: String
    let data: T?
    let error: ErrorResponse?
}

struct GeneralResponseArrayType<T:Codable>: Codable {
    let message: String
    let code: String
    let data: [T]?
    let error: ErrorResponse?
}

struct GeneralResponseBoolType: Codable {
    let data: Bool?
    let message: String?
    let code: String?
    let error: ErrorResponse?
}

enum Response<Value> {
    case success(Value)
    case failure(ErrorResponse)
    case error
    
    var value: Value? {
        switch self {
        case .success(let value):
            return value
        default:
            return nil
        }
    }
    
    static func initResult<T: Codable>(_ response: DataResponse<GeneralResponseType<T>, AFError>) -> Response<T> {
        if let data = response.value?.data {
            return .success(data)
        }
        else if let error = response.value?.error {
            if response.response?.statusCode ?? 0 == 401 {
            }
            return .failure(error)
        } else {
            return .error
        }
    }
    
    static func initWithdrawalResult<T: Codable>(_ response: DataResponse<GeneralResponseType<T>, AFError>) -> Response<T> {
        if let data = response.value?.data {
            if let message = response.value?.message, message == "General Success" {
                return .success(data)
            } else {
                return .error
            }
        }
        else if let error = response.value?.error {
            if response.response?.statusCode ?? 0 == 401 {
            }
            return .failure(error)
        } else {
            return .error
        }
    }
    
    static func initArrayResult<T: Codable>(_ response: DataResponse<GeneralResponseArrayType<T>, AFError>) -> Response<[T]> {
        if let data = response.value?.data {
            return .success(data)
        } else if let error = response.value?.error {
            if response.response?.statusCode ?? 0 == 401 {
            }
            return .failure(error)
        } else {
            return .error
        }
    }
    
    static func initBoolResult(_ response: DataResponse<GeneralResponseBoolType, AFError>) -> Response<(Bool)> {
        if let error = response.value?.error {
            return .failure(error)
        } else if let data = response.value?.data {
            return .success(data)
        } else {
            return .error
        }
    }
}

class ErrorResponse: Codable {
    let statusCode: Int?
    let statusData: String?
    let statusMessage: String?
    let code: String?
    
    enum CodingKeys: String, CodingKey {
        case statusCode = "status"
        case statusMessage = "message"
        case statusData = "data"
        case code = "code"
    }
}
