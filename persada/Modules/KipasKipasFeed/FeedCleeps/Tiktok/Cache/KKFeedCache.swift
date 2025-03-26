//
//  KKFeedCache.swift
//  KKTUIPlayerApp
//
//  Created by koanba on 05/10/23.
//

import Foundation

public class KKFeedCache {
    
    let LOG_ID = "** KKFeedCache"
    
    public static let instance: KKFeedCache = KKFeedCache()

    var cacheFeeds = [String]()
    
    init() {
        self.initCache()
    }
    
    public func clear(){
        DataCache.instance.clean(byKey: self.getKey())
        removeCacheFeeds()
    }
    func addSeen(feedId: String, channelCode: String){
        print(self.LOG_ID, "addSeen", feedId)
        self.cacheFeeds.append(feedId)
        
        DataCache.instance.write(array: self.cacheFeeds, forKey: self.getKey())
    }
    
    func initCache() -> Int {
        self.cacheFeeds = DataCache.instance.readArray(forKey: self.getKey()) as? [String] ?? []
        //print(self.LOG_ID, "initCache: ", self.cacheFeeds.count, "data")
        return self.cacheFeeds.count
    }
    
    func getUniqueFeeds(feeds: [FeedItem]) -> [FeedItem] {
        
        var uniqueFeeds = [FeedItem]()
        
        feeds.forEach { feed in
            if let feedId = feed.id {
                if(self.isUniqueFeed(id: feedId)){
                    uniqueFeeds.append(feed)
                }
            }
        }
        
        return uniqueFeeds
        
    }
    
    func isUniqueFeed(id: String) -> Bool {
        return !self.cacheFeeds.contains(id)
    }
    
    func getKey() -> String {
        return "SEEN_FEED"
    }
    
    func seenFeed(by id: String?) {
        guard let feedId = id, !feedId.isEmpty else { return }
        var feeds = UserDefaults.standard.value(forKey: "SEEN_FEED_BY_ID") as? [String] ?? []
        
        guard !feeds.contains(feedId) else { return }
        feeds.append(feedId)
        
        UserDefaults.standard.setValue(feeds, forKey: "SEEN_FEED_BY_ID")
    }
    
    func isAlreadySeen(id: String?) -> Bool {
        guard let feedId = id, !feedId.isEmpty else { return false }
        if let feeds = UserDefaults.standard.value(forKey: "SEEN_FEED_BY_ID") as? [String] {
            return feeds.contains(feedId)
        }
        
        return false
    }
    
    func getFeeds() -> [String] {
//        return []
        if let feeds = UserDefaults.standard.value(forKey: "SEEN_FEED_BY_ID") as? [String] {
            return feeds
        }
        
        return []
    }
    
    func removeCacheFeeds() {
        UserDefaults.standard.removeObject(forKey: "SEEN_FEED_BY_ID")
    }
}
