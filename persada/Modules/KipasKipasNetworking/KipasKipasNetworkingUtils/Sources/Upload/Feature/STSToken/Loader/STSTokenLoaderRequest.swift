//
//  STSTokenLoaderRequest.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 13/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

public struct STSTokenLoaderRequest {
    public let keystore: String
    public let username, password: String
    
    public init(keystore: String, username: String, password: String) {
        self.keystore = keystore
        self.username = username
        self.password = password
    }
}
