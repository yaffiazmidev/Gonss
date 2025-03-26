//
//  RemoteReviewError.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 20/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

struct RemoteReviewError: Codable {
    let code, message, data: String?
}
