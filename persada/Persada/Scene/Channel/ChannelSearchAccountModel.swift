//
//  ChannelSearchAccountModel.swift
//  KipasKipas
//
//  Created by movan on 04/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation

enum ChannelSearchAccountModel {
  
  enum Request {
		case searchAccount
	}
	
	enum Response {
		case accounts(data: SearchArray)
        case failedSearchAccounts(message: String)
	}
	
	enum ViewModel {
		case accounts(viewModel: [SearchAccount])
        case failedSeachAccounts(message: String)
	}
	
	enum Route {
		case dismissChannelSearchTopScene
		case showProfile(id: String)
	}
	
	struct DataSource: DataSourceable {
		var page: Int?
		var text: String?
		var data: [SearchAccount]?
	}

}
