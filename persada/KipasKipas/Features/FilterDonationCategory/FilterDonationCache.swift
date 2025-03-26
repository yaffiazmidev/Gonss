//
//  FilterDonationCache.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 29/08/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

class FilterDonationCache : NSObject {
    
    static let instance = FilterDonationCache()
    private let userDefaults: UserDefaults
    
    override init() {
        userDefaults = UserDefaults.standard
    }
    
    func getFilterDonations() -> (FilterDonationTemporaryStore?) {
        if let objects = userDefaults.value(forKey: "FilterDonationTemporaryStore") as? Data {
            let decoder = JSONDecoder()
            if let objectsDecoded = try? decoder.decode(FilterDonationTemporaryStore.self, from: objects) {
                return objectsDecoded
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func saveFilterDonations(value: FilterDonationTemporaryStore) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(value) {
            userDefaults.set(encoded, forKey: "FilterDonationTemporaryStore")
        }
    }
}
