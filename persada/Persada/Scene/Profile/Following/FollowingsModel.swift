//
//  FollowingsModel.swift
//  KipasKipas
//
//  Created by movan on 31/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import Combine

enum FollowingsModel {
	
	enum Request {
		case fetchFollowings(id: String, isPagination: Bool)
		case unfollow(id: String)
		case follow(id: String)
		case searchAccount(id: String, text: String)
	}
	
	enum Response {
		case followings(result: FollowerResult)
		case paginationFollowings(result: FollowerResult)
		case unfollow(result: DefaultResponse)
		case follow(result: DefaultResponse)
		case searchAccount(result: FollowerResult)
		
	}
	
	enum ViewModel {
		case paginationFollowings(viewModel: [Follower])
		case followings(viewModel: [Follower])
		case follow(viewModel: DefaultResponse)
		case unfollow(viewModel: DefaultResponse)
		case account(viewModel: [Follower])
	}
	
	enum Route {
		case detail(id: String)
		case dismiss(id: String, showNavBar: Bool)
	}
	
	class DataSource: DataSourceable {
		var id: String?
		var index: Int?
		var showNavBar: Bool?
		@Published var text: String = ""
		@Published var data: [Follower]?
	}
}
