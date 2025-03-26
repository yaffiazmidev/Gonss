//
//  CommentHeaderMultipleViewModel.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 05/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import IGListKit

final class LikeAndCommentViewModel : ListDiffable {
	
	var totalLikes : Int
	var totalComment : Int
	var isLiked : Bool
	
	init(totalLikes: Int, totalComment: Int, isLiked: Bool) {
		self.totalLikes = totalLikes
		self.totalComment = totalComment
		self.isLiked = isLiked
	}
	
	func diffIdentifier() -> NSObjectProtocol {
		return "action" as NSObjectProtocol
	}
	
	func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
		guard let object = object as? LikeAndCommentViewModel else { return false }
		return totalLikes == object.totalLikes
	}

}

