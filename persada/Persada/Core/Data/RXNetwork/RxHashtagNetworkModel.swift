//
//  RxHashtagNetworkModel.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 09/04/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift

public final class RxHashtagNetworkModel {
	private let network: Network<FeedArray>
	
	init(network: Network<FeedArray>) {
		self.network = network
	}
	
    func getHashtagList(hashtag: String, page: Int, size: Int) -> Observable<FeedArray> {
        let hashtagEndpoint = HashtagEndpoint.getHashtagList(hashtag: hashtag, page: page, size: size)
		return network.getItemsWithURLParam(hashtagEndpoint.path, parameters: hashtagEndpoint.parameter)
	}
	
    func getHashtagPostList(hashtag: String, page: Int, size: Int = 10) -> Observable<FeedArray> {
		let hashtagEndpoint = HashtagEndpoint.getHashtagPostList(hashtag: hashtag, page: page, size: size)
		return network.getItemsWithURLParam(hashtagEndpoint.path, parameters: hashtagEndpoint.parameter)
	}
}
