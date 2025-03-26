//
//  PostPresenter.swift
//  Persada
//
//  Created by NOOR on 30/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import Foundation

protocol PostPresentationLogic {
//	func presentResponse(_ response: [ResponseMedia])
    func showFeed(_ response: DefaultResponse)
    func showError(_ error: ErrorMessage)
}

final class PostPresenter: Presentable {
	private weak var viewController: PostDisplayLogic?
	
	init(_ viewController: PostDisplayLogic?) {
		self.viewController = viewController
	}
}


// MARK: - PostPresentationLogic
//extension PostPresenter: PostPresentationLogic {
	
//	func presentResponse(_ response: PostModel.Response) {
//
//		switch response {
//		case .media(let result):
//			presentingMedia(result)
//		case .responsePost(let result):
//			presentingPostSocial(result)
//		}
//	}
//}


// MARK: - Private Zone
extension PostPresenter: PostPresentationLogic {

    func showError(_ error: ErrorMessage) {
        viewController?.displayViewModel(.error(error))
    }

    func showFeed(_ response: DefaultResponse) {
        viewController?.displayViewModel(.post(viewModel: response))
    }
	
	func presentingPostSocial(_ data: ResultData<DefaultResponse>) {
		
		switch data {
		case .failure(let error):
			viewController?.displayViewModel(.error(error))
		case .success(let response):
			viewController?.displayViewModel(.post(viewModel: response))
		}
	}
	
	func presentingMedia(_ data: ResultData<[ResponseMedia]>) {
		
		switch data {
		case .failure(let error):
			viewController?.displayViewModel(.error(error))
		case .success(let response):
            break
//			viewController?.displayViewModel(.media(viewModel: response))
		}
	}
}
