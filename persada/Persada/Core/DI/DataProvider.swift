//
//  DataProvider.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 18/12/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

protocol DataProvider {
	static func makeFeedRepository() -> FeedRepository
}

public final class DataProviderImpl: DataProvider {
	
	static func makeFeedRepository() -> FeedRepository {
		return FeedRepositoryImpl.sharedInstance(LocalDataSource(configuration: Realm.Configuration()), RxFeedNetworkModel(network: Network<Feed>()))
	}
}

