//
//  PostViewModel.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 07/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import IGListKit

final class PostViewModel : ListDiffable {

	let postID : String
	let user : UserViewModel
	let media : MediaViewModel
	let caption : CaptionViewModel
	let action : LikeAndCommentViewModel
	var comments : [CommentViewModel]
    let emptyComment: EmptyCommentViewModel
	
    internal init(postID: String, user: UserViewModel, media: MediaViewModel, caption: CaptionViewModel,  action: LikeAndCommentViewModel, comments: [CommentViewModel], emptyComment: EmptyCommentViewModel) {
		self.postID = postID
		self.user = user
		self.media = media
		self.caption = caption
		self.action = action
		self.comments = comments
        self.emptyComment = emptyComment
	}
	
	func diffIdentifier() -> NSObjectProtocol {
		return postID as NSObjectProtocol
	}
	
	func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
		guard let object = object as? PostViewModel else { return false }
		return postID == object.postID
	}
	
	
}
