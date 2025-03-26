//
//  FollowingsPresenter.swift
//  KipasKipas
//
//  Created by movan on 31/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation

protocol FollowingsPresentationLogic {
	func presentResponse(_ response: FollowingsModel.Response)
}

final class FollowingsPresenter: Presentable {
	private weak var viewController: FollowingsDisplayLogic?
	
	init(_ viewController: FollowingsDisplayLogic?) {
		self.viewController = viewController
	}
}


// MARK: - FollowingsPresentationLogic
extension FollowingsPresenter: FollowingsPresentationLogic {
	
	func presentResponse(_ response: FollowingsModel.Response) {
		
		switch response {
			
		case .paginationFollowings(let result):
			 presentPaginationFollowings(result)
		 case .followings(let result):
			 presentFollowings(result)
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
private extension FollowingsPresenter {
	
	func presentPaginationFollowings(_ result: FollowerResult) {
		
		guard let validData = result.data?.content else {
			return
		}
		
        if validData.count != 0 {
            viewController?.displayViewModel(.paginationFollowings(viewModel: validData))
        }
	}
	
	func presentFollowings(_ result: FollowerResult) {
		
		guard let validData = result.data?.content else {
			return
		}
		
		viewController?.displayViewModel(.followings(viewModel: validData))
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
