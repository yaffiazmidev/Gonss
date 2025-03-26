//
//  FeedSeenFailedCache.swift
//  FeedCleeps
//
//  Created by koanba on 25/01/23.
//

import Foundation

public class FeedSeenFailedCache : NSObject {
    
    var id: String?
    
    private static let preKey = "FeedSeenFailedCacheKey"
    
    public static let instance = FeedSeenFailedCache()
        

    func getAll(id: String) -> [String] {
        self.id = id
        let feedIdAnys: [Any] = DataCache.instance.readArray(forKey: self.getKey()) ?? []
        let feedIds: [String] = feedIdAnys.compactMap { String(describing: $0) }

        return feedIds
    }

    public func remove(id:String, feedId: FeedId) {
        self.id = id
        let feedIds = self.getAll(id: id)
        let feedIdRemoves = feedIds.filter {$0 != feedId.id}
        
        DataCache.instance.write(array: feedIdRemoves, forKey: self.getKey())
    }

    func add(id: String, feedId: FeedId) {
        self.id = id
        var feedIds = self.getAll(id: id)
        
        var feedIdUniques = feedIds.filter {$0 != feedId.id}
        
        feedIdUniques.append(feedId.id ?? "")
        
        DataCache.instance.write(array: feedIdUniques, forKey: self.getKey())
    }
    
    private func getKey() -> String {
        return FeedSeenFailedCache.preKey + self.id!
    }
}

