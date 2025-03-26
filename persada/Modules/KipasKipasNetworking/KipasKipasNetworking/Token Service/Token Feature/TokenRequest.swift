//
//  TokenRequest.swift
//  KipasKipasNetworking
//
//  Created by PT.Koanba on 30/03/22.
//

import Foundation

public struct TokenRequest {
    let refresh_token: String
    let grant_type: String = "refresh_token"
    
    public init(refresh_token: String) {
        self.refresh_token = refresh_token
    }
}
