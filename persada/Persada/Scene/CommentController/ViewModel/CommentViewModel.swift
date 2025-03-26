//
//  CommentViewModel.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 05/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import IGListKit

final class CommentViewModel : ListDiffable {
	
	let commentID : String
    let userID : String
	let userPhoto : String
	let userName : String
	let date : String
	let comment : String
	var isLike : Bool
	var isReported : Bool
	var totalLikes : Int
	var totalComment : Int
    let type : String
    let createAt : Int
	
	init(commentID: String, userPhoto: String, userName: String, date: String, comment: String, isLike: Bool, isReported: Bool, totalLikes: Int, totalComment : Int, userID : String, type: String, createAt : Int) {
		self.commentID = commentID
		self.userPhoto = userPhoto
		self.userName = userName
		self.date = date
		self.comment = comment
		self.isLike = isLike
		self.isReported = isReported
		self.totalLikes = totalLikes
		self.totalComment = totalComment
        self.userID = userID
        self.type = type
        self.createAt = createAt
	}
	
	func diffIdentifier() -> NSObjectProtocol {
		return commentID as NSObjectProtocol
	}
	
    
	func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
		guard let object = object as? CommentViewModel else { return false }
		return commentID == object.commentID
	}
}
