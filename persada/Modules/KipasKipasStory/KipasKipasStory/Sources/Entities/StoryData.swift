//
//  StoryData.swift
//  KipasKipasStory
//
//  Created by Rahmat Trinanda Pramudya Amar on 07/06/24.
//

import Foundation

public struct StoryData: Codable {
    public var myFeedStory: StoryFeed?
    public var feedStoryAnotherAccounts: StoryPaging<[StoryFeed]>?
    
    public init(myFeedStory: StoryFeed, feedStoryAnotherAccounts: StoryPaging<[StoryFeed]>) {
        self.myFeedStory = myFeedStory
        self.feedStoryAnotherAccounts = feedStoryAnotherAccounts
    }
}

public extension StoryData {
    func myStories() -> [StoryFeed] {
        guard let story = myFeedStory else { return [] }
        return [story]
    }
    
    func friendsStories() -> [StoryFeed] {
        return feedStoryAnotherAccounts?.content.compactMap { $0 } ?? []
    }
}
