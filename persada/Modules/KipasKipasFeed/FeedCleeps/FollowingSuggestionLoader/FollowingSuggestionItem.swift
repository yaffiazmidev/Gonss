//
//  FollowingSuggestionContent.swift
//  FeedCleeps
//
//  Created by DENAZMI on 03/12/22.
//

import Foundation

public struct FollowingSuggestionItem {
    let content: [FollowingSuggestionContent]?
    let totalPage: Int?
}

public struct FollowingSuggestionContent {
    let account: FollowingSuggestionAccount?
    let feeds: [Feed]?
}

public class FollowingSuggestionAccount {
    let id: String?
    let username: String?
    let name: String?
    let photo: String?
    var isFollow: Bool?
    let isVerified: Bool?
    
    init(id: String?, username: String?, name: String?, photo: String?, isFollow: Bool?, isVerified: Bool?) {
        self.id = id
        self.username = username
        self.name = name
        self.photo = photo
        self.isFollow = isFollow
        self.isVerified = isVerified
    }
}

//public struct FollowingSuggestionFeed {
//    let post: FollowingSuggestionPost?
//
//    "id": "402880e784bcef980184bd13c3ce0069",
//                "typePost": "social",
//                "createdDate": null,
//                ,
//                "stories": null,
//                "createAt": 1669619499982,
//                "likes": 0,
//                "comments": 0,
//                "isLike": false,
//                "isFollow": false,
//                "isReported": false,
//                "totalView": null,
//                "isRecomm": false,
//                "isProductActiveExist": true,
//                "isAllImage": true,
//                "isAllHlsReady": false,
//                "valueBased": null,
//                "typeBased": null,
//                "similarBy": null,
//                "mediaCategory": "MULTIPLE"
//}
//
//public struct FollowingSuggestionPost {
//    let id: String?
//    let medias: [FollowingSuggestionMedia]?
//    let type": "social",
//    let id": "402880e784bcef980184bd13c3dc006a",
//    let comments": null,
//    let description": "",
//    let channel": {
//      "id": "ff80808171e525660171e54216590017",
//      "name": "General",
//      "code": "general",
//      "description": "Channel General",
//      "photo": "https://koanba-storage-test.oss-ap-southeast-5.aliyuncs.com/img/media/1643264469479.png",
//      "isFollow": null,
//      "createAt": 1588714445785
//    },
//    "hashtags": [
//
//    ],
//    "isScheduled": null,
//    "scheduledTime": null,
//    "product": null,
//    "accountId": null,
//    "status": null
//}
//
//public struct FollowingSuggestionMedia {
//    let id: String?
//    let type: String?
//    let url: String?
//    let thumbnail: FollowingSuggestionThumbnail?
//    let metadata: FollowingSuggestionMetadata?
//    let isHlsReady: Bool?
//    let hlsUrl: String?
//}
//
//public struct FollowingSuggestionThumbnail {
//    let large: String?
//    let medium: String?
//    let small: String?
//}
//
//public struct FollowingSuggestionMetadata {
//    let width: String?
//    let height: String?
//    let size: String?
//    let duration: String?
//}
