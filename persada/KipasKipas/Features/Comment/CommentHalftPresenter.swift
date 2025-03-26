//
//  CommentHalftPresenter.swift
//  KipasKipas
//
//  Created by DENAZMI on 08/08/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

protocol ICommentHalftPresenter {
    func presentComments(with response: RemoteCommentEntity?)
    func presentCommentsNextPage(with response: RemoteCommentEntity?)
    func presentSuccessSendComment(with response: RemoteCommentEntity?)
    func presentSuccessDeleteComment(id: String)
    func presentSuccessDeleteSubcomment(commentId: String, id: String)
    func presentProfileWithUsername(profile: Profile)
    func presentEmptyProfile()
    func presentFollowing(with response: RemoteFollowingItem?)
}

class CommentHalftPresenter: ICommentHalftPresenter {
    
    weak var controller: ICommentHalftController!
    
    init(controller: ICommentHalftController) {
        self.controller = controller
    }
    
    func presentComments(with response: RemoteCommentEntity?) {
        let comments: [CommentEntity] = response?.data?.content?.toModels() ?? []
        let commentsFiltered = comments.filter( { !$0.isReported })
        controller.displayComments(commentsFiltered)
    }
    
    func presentCommentsNextPage(with response: RemoteCommentEntity?) {
        let comments: [CommentEntity] = response?.data?.content?.toModels() ?? []
        let commentsFiltered = comments.filter( { !$0.isReported })
        controller.displayCommentsNextPage(commentsFiltered)
    }
    
    func presentSuccessSendComment(with response: RemoteCommentEntity?) {
        guard let comment = response?.data?.content?.toModels().first else { return }
        
        controller.displayNewComment(comment)
    }
    
    func presentSuccessDeleteComment(id: String) {
        controller.displaySuccessDeleteComment(id: id)
    }
    
    func presentSuccessDeleteSubcomment(commentId: String, id: String) {
        controller.displaySuccessDeleteSubcomment(commentId: commentId, id: id)
    }
    
    func presentProfileWithUsername(profile: Profile) {
        
        guard let accountId = profile.id, let accountType = profile.accountType else { return }
        
        controller.displayProfile(id: accountId, type: accountType)
    }
    
    func presentEmptyProfile() {
        controller.displayNotFoundProfile()
    }
    
    func presentFollowing(with response: RemoteFollowingItem?) {
        controller.displayFollowings(items: response?.data?.content ?? [])
    }
}

private extension Array where Element == RemoteCommentContent {
    func toModels() -> [CommentEntity] {
        return map { CommentEntity(
            id: $0.id ?? "",
            accountId: $0.account?.id ?? "",
            username: $0.account?.username ?? "",
            messages: $0.value ?? "",
            replys: $0.commentSubs?.toModels().filter( { !$0.isReported }) ?? [],
            isOpened: $0.comments ?? 0 <= 2,
            likes: $0.like ?? 0,
            photoUrl: $0.account?.photo ?? "",
            createAt: $0.createAt ?? 0,
            isLike: $0.isLike ?? false,
            isReported: $0.isReported ?? false,
            accountType: $0.account?.accountType ?? "",
            urlBadge: $0.account?.urlBadge ?? "",
            isShowBadge: $0.account?.isShowBadge == true, 
            isVerified: $0.account?.isVerified ?? false
        )
        }
    }
}

private extension Array where Element == RemoteCommentSubcomment {
    func toModels() -> [CommentEntityReply] {
        return map { CommentEntityReply(
            id: $0.id ?? "",
            accountId: $0.account?.id ?? "",
            username: $0.account?.username ?? "",
            messages: $0.value ?? "",
            likes: $0.like ?? 0,
            photoUrl: $0.account?.photo ?? "",
            createAt: $0.createAt ?? 0,
            isLike: $0.isLike ?? false,
            isReported: $0.isReported ?? false,
            accountType: $0.account?.accountType ?? "",
            urlBadge: $0.account?.urlBadge ?? "",
            isShowBadge: $0.account?.isShowBadge == true,
            isVerified: $0.account?.isVerified ?? false
        )
        }
    }
}
