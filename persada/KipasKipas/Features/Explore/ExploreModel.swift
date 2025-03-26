//
//  ExploreModel.swift
//  KipasKipas
//
//  Created by DENAZMI on 08/03/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

enum ExploreModel {
    struct Channel {
        let id: String
        let name: String
        let description: String
        let photo: String
        let isFollow: Bool
        let code: String
    }
    
    struct Post {
        let feedId: String
        let id: String
        let url: String
        let height: String
        let size: String
        let width: String
        let type: PostMediaType
    }
    
    struct Content {
        let createAt: Int
        let isReported: Bool
        let isFollow: Bool
        let likes: Int
        let isLike: Bool
        let account: Account
        let typePost: String
        let stories: [String] = []
        let id: String
        let post: Post
        let comments: Int
    }
    
    struct Account {
        let id: String
        let isDisabled: Bool
        let name: String
        let isSeleb: Bool
        let username: String
        let email: String
        let isVerified: Bool
        let isSeller: Bool
        let mobile: String
        let isFollow: Bool
        let photo: String
    }
}
