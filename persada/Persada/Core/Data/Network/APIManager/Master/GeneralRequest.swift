//
//  GeneralRequest.swift
//  KipasKipas
//
//  Created by iOS Dev on 21/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Alamofire
import UIKit

protocol GeneralRequest {
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: [String: Any]? { get }
    var headers: [String: String]? { get }
}

enum GeneralRequestHeaderType {
    case general
    case json
    case upload
    
    var heeaderValue: [String: String]? {
        var header: [String: String]?
        switch self {
        case .general:
            header = [
                "Authorization": "Bearer \(getToken() ?? "")",
                "Content-Type": "application/json",
                "Accept": "application/json",
                "model":UIDevice.modelName
            ]
            
        case .upload:
            header = [
                "Content-Type": "multipart/form-data",
                "Authorization": "Bearer \(getToken() ?? "")"
            ]
            
        default:
            header = [
                "Authorization": "Bearer \(getToken() ?? "")",
                "Content-Type": "application/json",
                "Accept": "application/json"
            ]
        }
        
        return header
    }
}
