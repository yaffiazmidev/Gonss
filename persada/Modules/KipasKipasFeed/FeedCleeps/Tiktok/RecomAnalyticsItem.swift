//
//  RecomAnalyticsItem.swift
//  FeedCleeps
//
//  Created by DENAZMI on 19/10/22.
//

import Foundation

struct RecomAnalyticsItem {
    let uid: String
    let feedId: String
    let viewDate: String
    let typePost: String
    let createAt: String
    let viewType: String
    let hashtags: String
    let channelCode: String
    let viewDuration: String
    let totalDuration: String
    
    init(uid: String?, feedId: String?, typePost: String?, createAt: Int?, viewType: String?, hashtags: String?, channelCode: String?, viewDuration: Double, totalDuration: Double) {
        self.uid = uid ?? ""
        self.feedId = feedId ?? ""
        self.viewDate = "\(Date().millisecondsSince1970)"
        self.typePost = typePost ?? ""
        self.createAt = "\(createAt ?? 0)"
        self.viewType = viewType ?? ""
        self.hashtags = hashtags ?? ""
        self.channelCode = channelCode ?? ""
        self.viewDuration = "\(Int(viewDuration))"
        self.totalDuration = viewType == "SINGLE_IMAGE" ? "0" : "\(Int(totalDuration))"
    }
    
    var param: [String: Any] {
        return [
            "user_id"       : uid,          "feed_id"       : feedId,
            "view_duration" : viewDuration, "total_duration": totalDuration,
            "view_date"     : viewDate,     "view_type"     : viewType,
            "type_post"     : typePost,     "hashtag"       : hashtags,
            "create_at"     : createAt,     "channel_code"  : channelCode,
            "platform"      : "ios"
        ]
    }
}
