//
//  HashtagRepository.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 09/04/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift

protocol HashtagRepository {
    func getHashtagList(hashtag: String, page: Int, size: Int) -> Observable<FeedArray>
    func getHashtagPostList(hashtag: String, page: Int, size: Int) -> Observable<FeedArray>
}

class HashtagRepositoryImpl : HashtagRepository {

	fileprivate let remote : RxHashtagNetworkModel
	
	typealias HashtagInstance = ( RxHashtagNetworkModel) -> HashtagRepository
	
	private init( remote: RxHashtagNetworkModel) {
			self.remote = remote
	}
	
	static let sharedInstance: HashtagInstance = { remote in
		return HashtagRepositoryImpl(remote: remote)
	}
	
    func getHashtagList(hashtag: String, page: Int, size: Int) -> Observable<FeedArray> {
        return remote.getHashtagList(hashtag: hashtag, page: page, size: size)
	}
	
    func getHashtagPostList(hashtag: String, page: Int, size: Int = 10) -> Observable<FeedArray> {
		return remote.getHashtagPostList(hashtag: hashtag, page: page, size: size)
	}
	
}
