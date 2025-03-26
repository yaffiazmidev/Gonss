//
//  SubcommentModel.swift
//  Persada
//
//  Created by NOOR on 25/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import Foundation
import Combine

enum SubcommentModel {
	
	enum Request {
		case fetchSubcomment(id: String, page: Int, isPagination: Bool)
		case like(postId: String, id: String, status: String, index: Int)
		case addSubcomment(id: String, commentId: String, value: String)
		case deleteComment
		case deleteSubComment(subCommentId: String)
	}
	
	enum Response {
		case subcomment(SubcommentResult)
		case paginationSubcomment(SubcommentResult)
		case like(ResultData<DefaultResponse>)
		case addSubcomment(ResultData<DefaultResponse>)
		case deleteSubComment(ResultData<DefaultResponse>)
		case deleteComment(ResultData<DefaultResponse>, feedId: String)
	}
	
	enum ViewModel {
		case headerData(viewModel: SubcommentResult)
		case paginationSubcomment(viewModel: [Subcomment])
		case subcomment(viewModel: [Subcomment])
		case like(viewModel: DefaultResponse)
		case addSubcomment(DefaultResponse)
		case deleteComment(DefaultResponse)
		case deleteSubComment(ResultData<DefaultResponse>)
		case errorMessage(ErrorMessage?)
	}
	
	enum Route {
		case dismissSubcomment
	}
	
    class DataSource: DataSourceable {
		var page: Int?
		var id: String?
		var postId: String?
		var statusLike: String?
		var index: Int?
		var feed: Feed?
		var headerComment: CommentHeaderCellViewModel?
		@Published var data: [Subcomment] = []
	}
    
    class SubcommentDataSource {
        var id: String?
        var postId: String?
        var commentHeader: SubcommentHeader?
        var subcomments: [Subcomment] = []
        
        init(id: String? = nil, postId: String? = nil, commentHeader: SubcommentModel.SubcommentHeader? = nil, subcomments: [Subcomment] = []) {
            self.id = id
            self.postId = postId
            self.commentHeader = commentHeader
            self.subcomments = subcomments
        }
    }
    
    class SubcommentHeader {
        var userId: String?
        var userType: String?
        var description: String?
        var date: Int?
        var username: String?
        var imageUrl: String?
        
        init(userId: String? = nil, userType: String? = nil, description: String? = nil, date: Int? = nil, username: String? = nil, imageUrl: String? = nil) {
            self.userId = userId
            self.userType = userType
            self.description = description
            self.date = date
            self.username = username
            self.imageUrl = imageUrl
        }
    }
}
