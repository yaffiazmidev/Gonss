//
//  CommentEntity.swift
//  KipasKipas
//
//  Created by DENAZMI on 08/08/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

class CommentEntity {
    var id: String
    var accountId: String
    var username: String
    var messages: String
    var replys: [CommentEntityReply]
    var isOpened = false
    var likes: Int
    var photoUrl: String
    var createAt: Int
    var isLike: Bool
    var isReported: Bool
    var accountType: String
    var urlBadge: String
    var isShowBadge: Bool
    var isVerified: Bool
    
    init(
        id: String,
        accountId: String,
        username: String,
        messages: String,
        replys: [CommentEntityReply],
        isOpened: Bool = false,
        likes: Int,
        photoUrl: String,
        createAt: Int,
        isLike: Bool,
        isReported: Bool,
        accountType: String,
        urlBadge: String,
        isShowBadge: Bool,
        isVerified: Bool
    ) {
        self.id = id
        self.accountId = accountId
        self.username = username
        self.messages = messages
        self.replys = replys
        self.isOpened = replys.count <= 2
        self.likes = likes
        self.photoUrl = photoUrl
        self.createAt = createAt
        self.isLike = isLike
        self.isReported = isReported
        self.accountType = accountType
        self.urlBadge = urlBadge
        self.isShowBadge = isShowBadge
        self.isVerified = isVerified
    }
}

class CommentEntityReply {
    var id: String
    var accountId: String
    var username: String
    var messages: String
    var likes: Int
    var photoUrl: String
    var createAt: Int
    var isLike: Bool
    var isReported: Bool
    var accountType: String
    var urlBadge: String
    var isShowBadge: Bool
    var isVerified: Bool
    
    init(
        id: String,
        accountId: String,
        username: String,
        messages: String,
        likes: Int,
        photoUrl: String,
        createAt: Int,
        isLike: Bool,
        isReported: Bool,
        accountType: String,
        urlBadge: String,
        isShowBadge: Bool,
        isVerified: Bool
    ) {
        self.id = id
        self.accountId = accountId
        self.username = username
        self.messages = messages
        self.likes = likes
        self.photoUrl = photoUrl
        self.createAt = createAt
        self.isLike = isLike
        self.isReported = isReported
        self.accountType = accountType
        self.urlBadge = urlBadge
        self.isShowBadge = isShowBadge
        self.isVerified = isVerified
    }
}
