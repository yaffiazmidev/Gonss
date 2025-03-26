//
//  DefaultEntity.swift
//  KipasKipas
//
//  Created by DENAZMI on 09/08/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

struct DefaultEntity: Codable {
    let code, data, message: String?
}

struct RemoteDefaultBool: Codable {
    let code, message: String?
    let data: Bool?
}
