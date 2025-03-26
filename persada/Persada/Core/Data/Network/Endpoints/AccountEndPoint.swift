//
//  AccountEndPoint.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 01/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

enum AccountEndPoint {
    case updateEmail(email : String)
}

extension AccountEndPoint: EndpointType {

    var baseUrl: URL {
        return URL(string: APIConstants.baseURL)!
    }

    var path: String {
        switch self {
            case .updateEmail(_):
                return "/account/setting"
        }
    }

    var method: HTTPMethod {
        switch self {
            case .updateEmail:
                return .post
        }
    }

    var body: [String: Any] {
        switch self {
            case .updateEmail(let email):
                return [
                    "email" : email
                ]
        }
    }

    var header: [String : String] {
        switch self {
            case .updateEmail(_):
                return [ "Authorization" : "Bearer \(getToken() ?? "")"]
        }
    }

    var parameter: [String : Any] {
        switch self {
            case .updateEmail(let email):
                return ["email" : email]
        }
    }

}
