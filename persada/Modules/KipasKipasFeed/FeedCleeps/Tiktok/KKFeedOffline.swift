//
//  KKFeedOffline.swift
//  FeedCleeps
//
//  Created by koanba on 07/02/23.
//

import Foundation

class KKFeedOffline : NSObject {
    
    var id: String?
    
    private let preKey = "KKFeedOfflineKey"


    public static let instance = KKFeedOffline()
    
    let LOG_ID = "====KKFeedOffline "
    
    public let MAX_OFFLINE_DATA = 10
        
    func getAll(id: String) -> [Feed] {
        self.id = id
        do {
            if let feedList: FeedList = try DataCache.instance.readCodable(forKey: self.getKey()) {
                return feedList.feeds
            }
        } catch {
            
        }
        return []
    }
    

    public func remove(id:String, feedId: FeedId) {
        self.id = id
        
        if(feedId.id != ""){
            let feeds = self.getAll(id: id)
            if(self.isExist(feeds: feeds, feedId: feedId.id!)){
                let feedIdRemoves = feeds.filter { $0.id != feedId.id }
                
                let feedList = FeedList(feeds: feedIdRemoves)
                
                do {
                    try DataCache.instance.write(codable: feedList, forKey: self.getKey())
                    print(LOG_ID, id, "remove",  "total: ", feedIdRemoves.count)
                    
                } catch {
                    print(LOG_ID, id, "remove", "Write error \(error.localizedDescription)")
                }
            }
            
        }
    }

    func isExist(feeds: [Feed], feedId: String) -> Bool{
        return feeds.contains(where: { $0.id == feedId })
    }
    
    func add(id: String, feed: Feed) {
        self.id = id
        
        let feedIds = self.getAll(id: id)

        if(!self.isExist(feeds: feedIds, feedId: feed.id!)){
            var feedIdUniques = feedIds.filter { $0.id != feed.id }
            feedIdUniques.append(feed)

            let feeds = FeedList(feeds: feedIdUniques)
            
            do {
                try DataCache.instance.write(codable: feeds, forKey: self.getKey())
                print(LOG_ID, id, "ADD", feed.id ?? "", "total: ", feedIdUniques.count)

            } catch {
                print(LOG_ID, id, "add", "Write error \(error.localizedDescription)")
            }
        }
    }
    
    public func clean(id:String) {
        self.id = id
        if(id != ""){
            do {
                try DataCache.instance.clean(byKey: self.getKey())
                print(LOG_ID, id, "clean")
            } catch {
                print(LOG_ID, id, "clean", "error \(error.localizedDescription)")
            }
            
        }
    }

    private func getKey() -> String {
        return self.preKey + self.id!
    }
}
