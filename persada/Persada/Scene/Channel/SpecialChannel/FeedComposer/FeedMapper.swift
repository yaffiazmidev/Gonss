//
//  FeedMapper.swift
//  KipasKipas
//
//  Created by PT.Koanba on 07/07/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import FeedCleeps

class FeedItemMapper {
    
    static func map(feed: FeedCleeps.Feed) -> KipasKipas.Feed {
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(feed)
        
        
        let jsonDecoder = JSONDecoder()
        let feed = try! jsonDecoder.decode(KipasKipas.Feed.self, from: jsonData)
        
        return feed
    }
    
    
    static func map(feed: KipasKipas.Feed) -> FeedCleeps.Feed {
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(feed)
        
        
        let jsonDecoder = JSONDecoder()
        let feedCleeps = try! jsonDecoder.decode(FeedCleeps.Feed.self, from: jsonData)
        
        return feedCleeps
    }
}
