//
//  PostFeedParam.swift
//  KipasKipas
//
//  Created by PT.Koanba on 13/08/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import KipasKipasShared

struct PostFeedParam: Codable {
    var post: PostFeed
    var typePost: String
}

struct PostFeed: Codable {
    var postDescription: String
    var responseMedias: [ResponseMedia]? 
    var itemMedias: [KKMediaItem]?
    var product: ProductParam?
    let channel: ChannelParam?
    var type: String
    let floatingLink: String?
    let floatingLinkLabel: String?

    enum CodingKeys: String, CodingKey {
        case postDescription = "description"
        case responseMedias = "medias"
        case channel, product, type
        case floatingLink, floatingLinkLabel
    }
}

struct ProductParam: Codable {
    let id: String
    let measurement: ProductMeasurement
    let description : String
    let name: String
    let price: Double
    let stock: Int
}

struct ChannelParam: Codable {
    let id: String?
}
