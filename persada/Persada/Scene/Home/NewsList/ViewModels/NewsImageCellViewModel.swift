//
//  NewsImageCellViewModel.swift
//  KipasKipas
//
//  Created by movan on 02/12/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

struct NewsImageCellViewModel: Hashable, Equatable {
	
	static func == (lhs: NewsImageCellViewModel, rhs: NewsImageCellViewModel) -> Bool {
		return lhs.identifier == rhs.identifier
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(identifier)
	}
	
	let identifier: UUID = UUID()
	let imageNewsUrl: String?
	let source: String?
	let title: String?
	let likes: Int?
	let link: String?
	let comment: Int?
	let postId: String?
	let accountId: String?
	let id: String?
	let published: Int?
	let isLike: Bool?
    let newsDetail: NewsDetail?
	
	init?(value: NewsDetail?) {
		
		guard let source: String = value?.postNews?.siteReference,
			let title: String = value?.postNews?.title,
			let likes: Int = value?.likes,
			let link: String = value?.postNews?.siteReference,
			let comment: Int = value?.comments,
			let id: String = value?.id,
			let postId: String = value?.postNews?.id,
			let accountId: String = value?.account?.id,
			let isLike: Bool = value?.isLike,
			let published: Int = value?.createAt else {
				return nil
		}
		
		if value?.postNews?.medias?.first?.thumbnail?.medium == nil {
			imageNewsUrl = value?.postNews?.medias?.first?.url
		} else {
			imageNewsUrl = value?.postNews?.medias?.first?.thumbnail?.small
		}
		
		self.id = id
		self.postId = postId
		self.accountId = accountId
		self.title = title
		self.likes = likes
		self.link = link
		self.comment = comment
		self.published = published
		self.source = source
		self.isLike = isLike
        self.newsDetail = value
	}
}

struct NewsViewModelCategory: Hashable {
    var id: String
    var news: [NewsCellViewModel]
    
    init(id: String, news: [NewsCellViewModel]) {
        self.id = id
        self.news = news
    }
}
