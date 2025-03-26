//
//  SelebCellViewModel.swift
//  Persada
//
//  Created by Muhammad Noor on 05/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

struct SelebCellViewModel {
	
	var imagePostUrl: String?
	var imageUserUrl: String?
	var videoUserUrl: String?
	var likes: Int?
	var date: Int?
	var comments: Int?
	var title: String?
	var username: String?
	var id: String?
	var postId: String?
	var isFollow: Bool?
	var isLike: Bool?
	var type: String?
	var accountId: String?
	var totalMedia: Int?
	var media: [Medias]?
	
	init?(value: Feed?) {
		
		guard let id: String = value?.id,
			let imageUserUrl: String = value?.account?.photo,
			let username: String = value?.account?.username,
			let isFollow: Bool = value?.isFollow,
			let isLike: Bool = value?.isLike,
			let type: String = value?.typePost,
			let accountId: String = value?.account?.id,
			let date: Int = value?.createAt else {
				return  nil
		}
		
		if value?.post == nil {
			
		} else {
			if value?.post?.medias == nil {
				self.media = []
			} else {
				self.media = value?.post?.medias ?? []
			}
			
			if value?.likes == nil {
				self.likes = 0
			} else {
				self.likes = value?.likes ?? 0
			}
			
			if value?.comments == nil {
				self.comments = 0
			} else {
				self.comments = value?.comments ?? 0
			}
			
			if value?.post?.postDescription == nil {
				self.title = ""
			} else {
				self.title = value?.post?.postDescription ?? ""
			}
			
			if value?.post?.medias?.first?.type == "image" {
				self.videoUserUrl = ""
			} else {
				self.videoUserUrl = value?.post?.medias?.first?.url
			}
			
			if value?.post?.medias?.first?.type == "video" {
				self.imagePostUrl = ""
			} else {
				self.imagePostUrl = value?.post?.medias?.first?.thumbnail?.medium
			}
			
			if value?.post?.medias?.first == nil {
				self.totalMedia = 0
			} else {
				self.totalMedia = value?.post?.medias?.count
			}
			
			if (value?.typePost == "story") {
				self.title = ""
				
				if value?.post?.id == nil {
					self.postId = ""
				} else {
					self.postId = value?.stories?.first?.id ?? ""
				}
				
				if value?.stories?.first?.media?.first?.type == "image" {
					self.videoUserUrl = ""
				} else {
					self.videoUserUrl = value?.stories?.first?.media?.first?.url
				}
				
				if value?.stories?.first?.media?.first?.type == "video" {
					self.imagePostUrl = ""
				} else {
					self.imagePostUrl = value?.stories?.first?.media?.first?.url
				}
			}
		}
		
		self.id = id
		self.imageUserUrl = imageUserUrl
		self.username = username
		self.date = date
		self.isFollow = isFollow
		self.isLike = isLike
		self.type = type
		self.accountId = accountId
	}
}
