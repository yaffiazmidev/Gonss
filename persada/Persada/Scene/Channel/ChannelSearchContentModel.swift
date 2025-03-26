//
//  ChannelSearchContentModel.swift
//  KipasKipas
//
//  Created by movan on 05/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation

enum ChannelSearchContentModel {
	
	enum Request {
		case searchChannel(text: String)
        case followChannel(id: String)
	}
	
	enum Response {
		case channelList(data: ChannelsAccount)
        case statusFollow(data: DefaultResponse)
	}
	
	enum ViewModel {
		case channelList(viewModel: [ChannelData])
        case statusFollow(viewModel: DefaultResponse)
	}
	
	enum Route {
		case dismissChannelSearchContentScene
		case detailChannel(id: String, name: String)
	}
	
	struct DataSource: DataSourceable {
		var page: Int?
		var data: [ChannelData]?
	}
}
