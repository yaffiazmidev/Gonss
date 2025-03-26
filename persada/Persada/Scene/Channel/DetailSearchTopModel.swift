//
//  DetailSearchTopModel.swift
//  KipasKipas
//
//  Created by movan on 04/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation

enum DetailSearchTopModel {
	
	enum Request {
		case searchDetailTop(isPagination: Bool)
	}
	
	enum Response {
		case channels(data: FeedArray)
		case paginationChannels(data: FeedArray)
	}
	
	enum ViewModel {
		case channels(viewModel: [Feed])
		case paginationChannel(viewModel: [Feed])
	}
	
	enum Route {
		case dismissChannelSearchTopScene
	}
	
	struct DataSource: DataSourceable {
		var page: Int?
		var text: String?
		var data: [Feed]?
	}
}
