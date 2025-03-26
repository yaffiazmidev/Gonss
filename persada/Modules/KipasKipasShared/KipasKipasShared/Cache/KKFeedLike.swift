//
//  KKFeedLike.swift
//  FeedCleeps
//
//  Created by koanba on 11/10/23.
//

import Foundation

public class KKFeedLike {
    
    private let LOG_ID = "** KKFeedLike"
    
    public static let instance: KKFeedLike = KKFeedLike()

    private var feeds : [(feedId: String, isLike: Bool, countLike: Int)] = []
    
    private init() {}
        
    public func add(feedId: String, isLike: Bool, countLike: Int){
        if(feedId != ""){
            feeds.removeAll(where: { $0.feedId == feedId })
            feeds.append((feedId: feedId, isLike: isLike, countLike: countLike))
        }
    }
    
    public func isExist(feedId: String) -> (feedId: String, isLike: Bool, countLike: Int)? {
        if(feedId != "") {
            if let isExist = feeds.first(where: { $0.feedId == feedId }){
                return isExist
            }
        }
        
        //print(self.LOG_ID, "feedId ", feedId, " NOT EXIST")
        return nil
    }
    
    /// For reseting local data, call this function when credentials/account changed.
    public func reset() {
        feeds.removeAll()
    }
}

public class KKFeedFollow {
    
    let LOG_ID = "** KKFeedFollow"
    
    public static let instance: KKFeedFollow = KKFeedFollow()

    var account : [(accountId: String, isFollow: Bool)] = []
    
    public init() {
    }
        
    public func add(accountId: String, isFollow: Bool) {
        guard !accountId.isEmpty else { return }
        
        account.removeAll(where: { $0.accountId == accountId })
        account.append((accountId: accountId, isFollow: isFollow))
    }
    
    public func isExist(accountId: String) -> (accountId: String, isFollow: Bool)? {
        guard !accountId.isEmpty else { return nil }
        
        if let isExist = account.first(where: { $0.accountId == accountId }) {
            return isExist
        }
        
        //print(self.LOG_ID, "accountId ", accountId, " NOT EXIST")
        return nil
    }
    
}
