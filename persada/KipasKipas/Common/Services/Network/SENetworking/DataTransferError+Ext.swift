//
//  DataTransferError+Ext.swift
//  KipasKipas
//
//  Created by DENAZMI on 28/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

extension DataTransferError {
    
    var statusCode: Int {
        switch self {
        case .noResponse:
            return 404
        case .parsing(let error):
            let code = URLError.Code(rawValue: (error as NSError).code)
            return code.rawValue
        case .networkFailure(let networkError):
            switch networkError {
            case .error(let code, _):
                return code
            case .notConnected:
                return 500
            case .cancelled:
                return 499
            case .generic(let error):
                return 9999
            case .urlGeneration:
                return 12005
            }
        case .resolvedNetworkFailure(let error):
            let code = URLError.Code(rawValue: (error as NSError).code)
            return code.rawValue
        }
    }
    
    var message: String {
        switch self {
        case .noResponse:
            return "noResponse"
        case .parsing(let error):
            return "Error: \(error.localizedDescription)"
        case .networkFailure(let networkError):
            switch networkError {
            case .error(_, let data):
                guard let data = data else {
                    return "Error no data"
                }
                return errorMessage(data: data)?.statusData ?? ""
            case .notConnected:
                return "notConnected"
            case .cancelled:
                return "cancelled"
            case .generic(let error):
                return "Error: \(error.localizedDescription)"
            case .urlGeneration:
                return "urlGeneration"
            }
        case .resolvedNetworkFailure(let error):
            return "Error: \(error.localizedDescription)"
        }
    }
    
    var data: Data? {
        switch self {
        case .networkFailure(let networkError):
            switch networkError {
            case .error(_, let data):
                return data
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    private func errorMessage(data: Data) -> ErrorMessage? {
        if let decodeError = try? JSONDecoder().decode(ErrorMessage.self, from: data) {
            return decodeError
        }
        return ErrorMessage(statusCode: 404, statusMessage: "Unknow error", statusData: "Data not found..")
//        do {
//
//        } catch {
//            return ErrorMessage(statusCode: 404, statusMessage: "Unknow error", statusData: "Data not found..")
//        }
    }
}
