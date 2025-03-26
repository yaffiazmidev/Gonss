//
//  LocationDonationCache.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 08/08/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

protocol LocationDonationCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(_ locations: [LocationDonationItem], completion: @escaping (Result) -> Void)
}
