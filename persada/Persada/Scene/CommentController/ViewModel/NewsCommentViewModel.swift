//
//  PostViewModel.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 07/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import IGListKit

final class NewsCommentViewModel : ListDiffable {

    let postID : String
    let newsHeader : NewsHeaderViewModel
    let newsAuthor : NewsAuthorViewModel
    var comments : [CommentViewModel]
    let emptyComment: EmptyCommentViewModel
    
    internal init(postID: String, newsHeader: NewsHeaderViewModel, newsAuthor: NewsAuthorViewModel, comments: [CommentViewModel], emptyComment: EmptyCommentViewModel) {
        self.postID = postID
        self.newsHeader = newsHeader
        self.newsAuthor = newsAuthor
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
