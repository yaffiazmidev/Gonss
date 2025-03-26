//
//  Injection.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 18/12/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation


final class Injection: NSObject {

    func provideFeedUseCase(endpoint: String, token: String? = nil) -> FeedUseCase {
        let repo = makeFeedRepository(endpoint: endpoint, token: token)
        return FeedInteractorRx(repository: repo)
    }
    
    func makeFeedRepository(endpoint: String, token: String? = nil) -> FeedRepository {
        return FeedRepositoryImpl.sharedInstance(
            RxFeedNetworkModel(
                network: Network<FeedArray>(endpoint: endpoint, token: token),
                networkDefault: Network<DefaultResponse>(endpoint: endpoint, token: token),
                networkDelete: Network<DeleteResponse>(endpoint: endpoint, token: token)), token)
    }
}
