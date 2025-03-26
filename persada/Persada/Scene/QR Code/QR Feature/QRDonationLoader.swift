//
//  QRDonationLoader.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 06/04/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct QRDonationLoaderRequest: Equatable {
    let id: String
    let isPublic: Bool
    
    init(id: String, isPublic: Bool) {
        self.id = id
        self.isPublic = isPublic
    }
}

protocol QRDonationLoader {
    typealias Result = Swift.Result<QRDonationItem, Error>
    
    func load(request: QRDonationLoaderRequest, completion: @escaping (Result) -> Void)
}
