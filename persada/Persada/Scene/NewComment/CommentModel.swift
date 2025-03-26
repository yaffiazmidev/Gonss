//
//  CommentModel.swift
//  Persada
//
//  Created by NOOR on 25/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import Foundation

enum CommentModel {
	
	enum Request {
		case fetchComment(id: String, isPagination: Bool)
		case like(postId: String, id: String, status: String, index: Int)
		case addComment(id: String, value: String)
		case fetchHeaderComment(id: String)
		case mention(word: String)
	}
	
	enum Response {
		case mention(ProfileResult)
		case header(PostDetailResult)
		case comment(CommentResult)
		case paginationComment(CommentResult)
		case like(ResultData<DefaultResponse>)
		case addComment(ResultData<DefaultResponse>, feedId: String)
		case errorHeader(Error)
	}
	
	enum ViewModel {
		case mention(viewModel: Profile)
		case header(viewModel: Feed)
		case comment(viewModel: [Comment])
		case paginationComment(viewModel: [Comment])
		case like(viewModel: DefaultResponse)
		case addComment(viewModel: DefaultResponse)
		case errorHeader(error: Error)
		case deleteComment(viewModel : DefaultResponse)
	}
	
	enum Route {
		case dismissComment
		case subcomment(postId: String, id: String, dataSource: CommentHeaderCellViewModel)
		case showProfile(id: String, type: String)
		case shared(text: String)
		case hashtag(hashtag: String)
	}
	
	class DataSource: DataSourceable {
		var id: String?
		var postId: String?
		var statusLike: String?
		var index: Int?
		var row: Int?
		@Published var dataHeader: Feed!
		@Published var data: [Comment] = []
		var headerItems: CommentHeaderCellViewModel?
	}
}
