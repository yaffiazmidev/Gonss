//
//  FollowersPresenter.swift
//  KipasKipas
//
//  Created by movan on 31/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation

protocol FollowersPresentationLogic {
	func presentResponse(_ response: FollowersModel.Response)
}

final class FollowersPresenter: Presentable {
	private weak var viewController: FollowersDisplayLogic?
	
	init(_ viewController: FollowersDisplayLogic?) {
		self.viewController = viewController
	}
}


// MARK: - FollowersPresentationLogic
extension FollowersPresenter: FollowersPresentationLogic {
	
	func presentResponse(_ response: FollowersModel.Response) {
		
		switch response {
			
		case .paginationFollowers(let result):
			presentPaginationFollowers(result)
		case .followers(let result):
			presentFollowers(result)
	 case .searchAccount(let result):
			presentSearchAccount(result)
	 case .follow(let result):
			presentFollow(result)
		case .unfollow(let result):
			presentUnfollow(result)
		}
	}
}


// MARK: - Private Zone
private extension FollowersPresenter {
	
	func presentPaginationFollowers(_ result: FollowerResult) {
		
		guard let validData = result.data?.content else {
			return
		}
	
        if validData.count != 0 {
            viewController?.displayViewModel(.paginationFollowers(viewModel: validData))
        }
	}
	
	func presentFollowers(_ result: FollowerResult) {
		
		guard let validData = result.data?.content else {
			return
		}
		
		viewController?.displayViewModel(.followers(viewModel: validData))
	}
	
	func presentSearchAccount(_ result: FollowerResult) {
		
		guard let validData = result.data?.content else {
			return
		}
		
		viewController?.displayViewModel(.account(viewModel: validData))
	}
	
	func presentFollow(_ result: DefaultResponse) {
		viewController?.displayViewModel(.follow(viewModel: result))
	}
	
	func presentUnfollow(_ result: DefaultResponse) {
		viewController?.displayViewModel(.unfollow(viewModel: result))
	}
}
