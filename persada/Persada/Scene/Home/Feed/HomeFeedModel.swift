//
//  NewSelebModel.swift
//  Persada
//
//  Created by Muhammad Noor on 17/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import Foundation
import Combine
import KipasKipasShared

enum FeedModel {

	enum Request {
        case uploadMedia(_ item: KKMediaItem)
		case story(page: Int)
		case like(id: String, status: String, index: Int)
		case unlike(id: String, status: String, index: Int)
		case follow(id: String, index: Int)
		case postStory(with: ParameterPostStory)
		case detail(username: String)
        case publicStory(page: Int)
	}

	enum Response {
		case detail(ProfileResult)
		case media(ResultData<ResponseMedia>)
		case stories(StoryResult)
        case publicStories(PublicStoryResult)
		case like(DefaultResponse)
		case unlike(DefaultResponse)
		case follow(ResultData<DefaultResponse>)
		case postStory(ResultData<DefaultResponse>)
		case paginationSeleb(data: FeedArray)
        case failedToRefreshToken
	}

	enum ViewModel {
		case detail(viewModel: Profile)
		case media(viewModel: ResponseMedia)
		case story(viewModel: [StoriesItem])
		case like(viewModel: DefaultResponse)
		case unlike(viewModel: DefaultResponse)
		case follow(viewModel: DefaultResponse)
		case postStory(viewModel: DefaultResponse)
		case paginationSeleb(data: [Feed])
		case emptyProfile
        case failedToRefreshToken
	}

	enum Route {
		case selectedComment(id: String, item: Feed, row: Int)
        case detailStory(id: String, accountId: String, type: String, post: [StoriesItem], imageURL: String, index: Int, inter: NewSelebInteractable)
		case showProfile(id: String, type: String)
		case showNews
		case showFollowing
		case report
		case gallery(value: NewSelebInteractable)
		case shared(text: String)
		case emptyProfile
		case hashtag(hashtag: String)
	}

	class DataSource: DataSourceable {
		var page: Int?
		var id: String?
		var isLoading: Bool? = false
		var statusLike: String?
		var isPaginating = false
		var isDonePaginating = false
		var index: Int?
		var headerComment: CommentHeaderCellViewModel?
		var story: Story?
		var imagesURL: [String]?
		var comments: Int?
		var productId: String?
		var accountId: String?
		var typeAccount: String?
		var postStories: [Stories]?
		var imageProfileURL: String?
		var mediaPath: String?
		var media: [ResponseMedia]? = []
		
		@Published var dataSeleb: [Feed]?
		var dataStory: [StoriesItem]?
		
		func setLoadingToggle() {
			isLoading?.toggle()
		}
	}
}
