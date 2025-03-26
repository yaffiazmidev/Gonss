//
//  ChannelSearchTopModel.swift
//  Persada
//
//  Created by NOOR on 24/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import Foundation

enum ChannelSearchTopModel {
	
	enum Request {
		case searchFeed
        case searchAccount
	}
	
	enum Response {
		case topFeedResponse(data: FeedArray)
        case topAccountResponse(data: SearchArray)
	}
	
	enum ViewModel {
		case topFeeds(viewModel: [Feed])
        case topAccounts(viewModel: [SearchAccount])
	}
	
	enum Route {
        case dismissChannelSearchTopScene
        case showFeed(index: Int, feeds: [Feed], requestedPage: Int, searchText: String, onClickLike: ((Feed) -> Void)?)
        case showProfile(id: String, isSeleb: Bool)
	}
	
	struct DataSource: DataSourceable {
		var page: Int?
		var text: String?
		var feeds: [Feed]?
        var accounts: [SearchAccount]?
	}
}
