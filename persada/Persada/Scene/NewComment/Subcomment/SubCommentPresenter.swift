//
//  SubcommentPresenter.swift
//  Persada
//
//  Created by NOOR on 25/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import Foundation
import RxSwift
import RxCocoa

protocol SubcommentPresentationLogic {
	func presentResponse(_ response: SubcommentModel.Response)
}

final class SubcommentPresenter: Presentable {

	private var usecase: FeedUseCase = Injection.init().provideFeedUseCase()
	private let disposeBag: DisposeBag = DisposeBag()
	private weak var viewController: SubcommentDisplayLogic?
	let _loadingState = BehaviorRelay<Bool>(value: false)
	let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
	var loadingState: Driver<Bool> {
		return _loadingState.asDriver()
	}
	private let _errorMessage = BehaviorRelay<String?>(value: nil)
	var errorMessage: Driver<String?> {
		return _errorMessage.asDriver()
	}

	init(_ viewController: SubcommentDisplayLogic?) {
		self.viewController = viewController
	}
}


// MARK: - SubcommentPresentationLogic
extension SubcommentPresenter: SubcommentPresentationLogic {
	
	func presentResponse(_ response: SubcommentModel.Response) {

		switch response {

		case .subcomment(let data):
			presentSubcomment(data)
		case .paginationSubcomment(let data):
			presentPaginationSubcomment(data)
		case .like(let result):
			changeStatusLike(result)
		case .addSubcomment(let data):
			addSubcomment(data)
			case .deleteComment(let result, let feedId):
				deleteComment(result, feedId: feedId)
			case .deleteSubComment(let res):
				deleteSubComment(res)
		}
	}
}


// MARK: - Private Zone
private extension SubcommentPresenter {
	
	func presentPaginationSubcomment(_ result: SubcommentResult) {
		
		guard let validData = result.data?.commentSubs else {
			return
		}
		
		viewController?.displayViewModel(.headerData(viewModel: result))
		viewController?.displayViewModel(.subcomment(viewModel: validData))
	}
	
	func presentSubcomment(_ result: SubcommentResult) {
		
		guard let validData = result.data?.commentSubs else {
			return
		}
		
		viewController?.displayViewModel(.headerData(viewModel: result))
		viewController?.displayViewModel(.paginationSubcomment(viewModel: validData))
	}
	
	func changeStatusLike(_ data: ResultData<DefaultResponse>) {

		switch data {
		case .failure(let error):
			print(error?.statusMessage ?? "")
		case .success(let result):
			viewController?.displayViewModel(.like(viewModel: result))
		}
	}
	
	func addSubcomment(_ data: ResultData<DefaultResponse>) {
        DispatchQueue.main.async {
            switch data {
            case .failure(let error):
                print(error?.statusMessage ?? "")
            case .success(let result):
                self.viewController?.displayViewModel(.addSubcomment(result))
                guard let controller = self.viewController as? SubcommentController else { return }
                controller.loadingState = false
            }
        }
	}

	func deleteComment(_ result: ResultData<DefaultResponse>, feedId: String) {
		switch result {
			case .failure(let error):
				viewController?.displayViewModel(.errorMessage(error))
			case .success(let result):
                self.viewController?.displayViewModel(.deleteComment(result))
		}
	}

	func deleteSubComment(_ result: ResultData<DefaultResponse>) {
		self.viewController?.displayViewModel(.deleteSubComment(result))
	}
}
