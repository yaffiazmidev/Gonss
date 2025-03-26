//
//  ChooseChannelModel.swift
//  Persada
//
//  Created by movan on 03/07/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation

enum ChooseChannelModel {

	enum Request {
		case fetchChannel(text: String, page: Int)
	}

	enum Response {
		case channels(results: ChannelResult)
	}

	enum ViewModel {
		case channels(viewModel: [Channel])
	}

	enum Route {
		case dismiss
	}

	class DataSource: DataSourceable {
		var page = 0
		@Published var channelName: String = ""
		@Published var data: [Channel] = []
		@Published var searching: Bool = false
	}
}
