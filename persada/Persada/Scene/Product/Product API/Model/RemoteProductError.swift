//
//  RemoteProductError.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 09/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct RemoteProductError: Codable {
    let code, message, data: String?
}
