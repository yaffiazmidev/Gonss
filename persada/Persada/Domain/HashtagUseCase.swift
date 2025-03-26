//
//  HashtagUseCase.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 09/04/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift

protocol HashtagUseCase {
    func getHashtagList(hashtag: String, page: Int, size: Int) -> Observable<FeedArray>
    func getHashtagPostList(hashtag: String, page: Int, size: Int) -> Observable<FeedArray>
}

class HashtagInteractorRx : HashtagUseCase {
	
	private let repository : HashtagRepository
	
	required init(repository : HashtagRepository) {
		self.repository = repository
	}
	
    func getHashtagList(hashtag: String, page: Int, size: Int) -> Observable<FeedArray> {
        return repository.getHashtagList(hashtag: hashtag, page: page, size: size)
	}
	
    func getHashtagPostList(hashtag: String, page: Int, size: Int = 10) -> Observable<FeedArray> {
        return repository.getHashtagPostList(hashtag: hashtag, page: page, size: size)
	}
}
