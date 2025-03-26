//
//  FollowersModel.swift
//  KipasKipas
//
//  Created by movan on 31/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import Combine

enum FollowersModel {
	
	enum Request {
		case fetchFollowers(id: String, isPagination: Bool)
		case unfollow(id: String)
		case follow(id: String)
		case searchAccount(id: String, text: String)
	}
	
	enum Response {
		case followers(result: FollowerResult)
		case paginationFollowers(result: FollowerResult)
		case unfollow(result: DefaultResponse)
		case follow(result: DefaultResponse)
		case searchAccount(result: FollowerResult)
		
	}
	
	enum ViewModel {
		case paginationFollowers(viewModel: [Follower])
		case followers(viewModel: [Follower])
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
