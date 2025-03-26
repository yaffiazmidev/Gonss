//
//  FeedCleepsLoader.swift
//  KipasKipas
//
//  Created by PT.Koanba on 10/06/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

public struct PagedFeedCleepsLoaderRequest: Equatable {
    public var page: Int
    public var isTrending: Bool
    public var size: Int
    public var categoryId: String
    public var isVodAvailable: Bool?
    public var provinceId: String?
    public var longitude: Double?
    public var latitude: Double?
    
    public init(
        page: Int,
        isTrending: Bool = false,
        size: Int = 10,
        categoryId: String,
        isVodAvailable: Bool?,
        provinceId: String? = nil,
        longitude: Double? = nil,
        latitude: Double? = nil
    ) {
        self.page = page
        self.isTrending = isTrending
        self.size = size
        self.categoryId = categoryId
        self.isVodAvailable = isVodAvailable
        self.provinceId = provinceId
        self.longitude = longitude
        self.latitude = latitude
    }
}


public struct SeenFeedCleepsRequest: Equatable {
    public var feedID: String
    
    public init(feedID: String) {
        self.feedID = feedID
    }
}

public struct SeenResponse: Codable {
    public var message: String
    public var code: String
}

public protocol FeedCleepsLoader {
    typealias Result = Swift.Result<FeedArray, Error>
    typealias SeenResult = Swift.Result<SeenResponse, Error>
    
    func load(request: PagedFeedCleepsLoaderRequest, completion: @escaping (Result) -> Void)
    func seen(request: SeenFeedCleepsRequest, completion: @escaping (SeenResult) -> Void)
}

