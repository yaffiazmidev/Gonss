//
//  CommentPresenter.swift
//  Persada
//
//  Created by NOOR on 25/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import Foundation
import RxSwift
import RxCocoa

protocol CommentPresentationLogic {
	func presentResponse(_ response: CommentModel.Response)
}

final class CommentPresenter: Presentable {
	private weak var viewController: CommentDisplayLogic?
	private let usecase: FeedUseCase
	private let disposeBag: DisposeBag = DisposeBag()

	let deleted = BehaviorRelay<Bool>(value: false)
	
	let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
	
	private let _errorMessage = BehaviorRelay<String?>(value: nil)
	var errorMessage: Driver<String?> {
		return _errorMessage.asDriver()
	}

	
	init(_ viewController: CommentDisplayLogic?) {
		self.viewController = viewController
		self.usecase = Injection.init().provideFeedUseCase()
	}

	func updateFeedLike(feed: Feed) {
		usecase.likeFeedRemote(feed: feed)
			.subscribeOn(self.concurrentBackground)
			.observeOn(MainScheduler.instance)
			.subscribe{ result in
				print(result)
			} onError: { err in
				self._errorMessage.accept(err.localizedDescription)
			} onCompleted: {
			}.disposed(by: disposeBag)
	}
	
	func deleteFeedById(id: String) {
		deleted.accept(false)
		usecase.deleteFeedById(id: id)
			.subscribeOn(self.concurrentBackground)
			.observeOn(MainScheduler.instance)
			.subscribe{ result in
				if (result.code == "1000") {
					self.deleted.accept(true)
				}
			} onError: { err in
				self._errorMessage.accept(err.localizedDescription)
			} onCompleted: {
			}.disposed(by: disposeBag)
	}
	
	func deleteComment(id: String, feedID : String){
		FeedNetworkModel().deleteComment(.deleteComment(id: id)) { (completion) in
			switch completion {
			case .failure(let error):
				print(error?.localizedDescription ?? "Error not caught")
			case .success(let response):
				print("success delete comment \(response)")
				self.viewController?.displayViewModel(.deleteComment(viewModel: response))
			}
		}
	}
}


// MARK: - CommentPresentationLogic
extension CommentPresenter: CommentPresentationLogic {
	
	func presentResponse(_ response: CommentModel.Response) {
		
		switch response {

		case .comment(let data):
			presentComment(data)
		case .like(let result):
			changeStatusLike(result)
		case .addComment(let data, let feedId):
			addComment(data, feedId: feedId)
		case .header(let data):
			presentHeaderComment(data)
		case .paginationComment(let data):
			presentPaginationComment(data)
		case .mention(let data):
			self.presentingMention(data)
		case .errorHeader(let error):
			self.errorHeader(error)
		}
	}
}



// MARK: - Private Zone
private extension CommentPresenter {
	
	func errorHeader(_ error: Error) {
		viewController?.displayViewModel(.errorHeader(error: error))
	}
	func presentingMention(_ result: ProfileResult) {

		guard let validData = result.data else {
			return
		}
		
		viewController?.displayViewModel(.mention(viewModel: validData))
	}
	
	func presentHeaderComment(_ result: PostDetailResult) {
		guard let validData = result.data else { return }

		viewController?.displayViewModel(.header(viewModel: validData))
	}
	
	func presentPaginationComment(_ result: CommentResult) {
		
		guard let validData = result.data?.content else { return }
		
		viewController?.displayViewModel(.paginationComment(viewModel: validData))
	}
	
	func presentComment(_ result: CommentResult) {
		
		guard let validData = result.data?.content else {
            if result.code?.isEmpty == true {
                viewController?.displayViewModel(.comment(viewModel: []))
            }
            return
        }
		
		viewController?.displayViewModel(.comment(viewModel: validData))
	}
	
	func changeStatusLike(_ data: ResultData<DefaultResponse>) {
		switch data {
		case .failure(let error):
			print(error?.statusMessage ?? "")
		case .success(let result):
			viewController?.displayViewModel(.like(viewModel: result))
		}
	}
	
	func addComment(_ data: ResultData<DefaultResponse>, feedId: String) {
		switch data {
		case .failure(let error):
			print(error?.statusMessage ?? "")
		case .success(let result):
            self.viewController?.displayViewModel(.addComment(viewModel: result))
        }
	}
	
	


}
