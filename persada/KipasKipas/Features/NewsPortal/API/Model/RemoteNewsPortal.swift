//
//  RemoteNewsPortal.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 07/02/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import Foundation

struct RemoteNewsPortal: Codable {
    let code: String?
    let message: String?
    let data: [RemoteNewsPortalData]?
}
