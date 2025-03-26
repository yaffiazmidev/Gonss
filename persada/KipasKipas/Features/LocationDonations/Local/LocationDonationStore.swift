//
//  LocationDonationStore.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 07/08/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

typealias CachedLocationDonation = (locations: [LocalLocationDonationItem], timestamp: Date)

protocol LocationDonationStore {
    typealias InsertItemCompletions = (Swift.Result<Void, Error>) -> Void
    typealias DeletionCompletion = (Swift.Result<Void, Error>) -> Void
    typealias RetrievalCompletion = (Swift.Result<CachedLocationDonation?, Error>) -> Void
    
    func insert(_ locations: [LocalLocationDonationItem], timesStamp: Date, completion: @escaping InsertItemCompletions)
    func deleteCachedLocations(completion: @escaping DeletionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}

struct LocalLocationDonationItem: Hashable {
    let id: String
    let name: String
    let code: String
    
    init(id: String, name: String, code: String) {
        self.id = id
        self.name = name
        self.code = code
    }
}
