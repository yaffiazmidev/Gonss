//
//  CommentInteractor.swift
//  Persada
//
//  Created by NOOR on 25/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import Foundation
import Combine

typealias CommentInteractable = CommentBusinessLogic & CommentDataStore

protocol CommentBusinessLogic {
	
	func doRequest(_ request: CommentModel.Request)
	func setPage(page: Int)
}

protocol CommentDataStore {
	var dataSource: CommentModel.DataSource { get set }
	var page: Int { get set }
}

final class CommentInteractor: Interactable, CommentDataStore {
	
	var page: Int = 0
	var dataSource: CommentModel.DataSource
	private var subscriptions = [AnyCancellable]()
	private var headerSubscriptions = [AnyCancellable]()
	var presenter: CommentPresentationLogic
	private let network: FeedNetworkModel = FeedNetworkModel()
	private let profileNetwork = ProfileNetworkModel()
	init(viewController: CommentDisplayLogic?, dataSource: CommentModel.DataSource) {
		self.dataSource = dataSource
		self.presenter = CommentPresenter(viewController)
	}
}


// MARK: - CommentBusinessLogic
extension CommentInteractor: CommentBusinessLogic {

	func setPage(page: Int) {
		self.page = page
	}

	func doRequest(_ request: CommentModel.Request) {
		DispatchQueue.global(qos: .userInitiated).async {
			
			switch request {
			case .fetchComment(let id, let isPagination):
				self.fetchComment(id, isPagination)
			case .like(_, let id, let status, let index):
				self.dataSource.index = index
				self.dataSource.statusLike = status
				self.requestLike(postId: self.dataSource.postId ?? "" , id: id, status: status)
			case .addComment(let id, let value):
				self.addComment(id: id, value: value)
			case .fetchHeaderComment(let id):
				self.fetchHeaderComment(id)
			case .mention(let word):
				self.mention(word)
			}
		}
	}
}


// MARK: - Private Zone
private extension CommentInteractor {
	
	func mention(_ word: String) {
		
		profileNetwork.profileUsername(.profileUsername(text: word)).sink(receiveCompletion: { (completion) in
			switch completion {
			case .failure(let error):
                print(error.localizedDescription)
			case .finished: break
			}
		}) { [weak self] (model: ProfileResult) in
			guard let self = self else { return }
			
			self.presenter.presentResponse(.mention(model))
		}.store(in: &subscriptions)
	}
	
	func fetchComment(_ id: String, _ isPagination: Bool) {

		network.fetchComment(.comments(id: id, page: page)).sink(receiveCompletion: { (completion) in
			switch completion {
			case .failure(let error): print(error.localizedDescription)
                self.presenter.presentResponse(.comment(CommentResult(code: "", message: "", data: CommentData())))
			case .finished: break
			}
		}) { [weak self] (model: CommentResult) in
			guard let self = self else { return }
			if isPagination {
				self.presenter.presentResponse(.paginationComment(model))
			} else {
				self.presenter.presentResponse(.comment(model))
			}
		}.store(in: &subscriptions)
	}
	
	func fetchHeaderComment(_ id: String) {
		network.PostDetail(.postDetail(id: id)).sink(receiveCompletion: { (completion) in
			switch completion {
			case .failure(let error):
				print(error.localizedDescription)
				self.presenter.presentResponse(.errorHeader(error))
			case .finished: break
			}
		}) { [weak self] (model: PostDetailResult) in
			guard let self = self else { return }
			
			self.presenter.presentResponse(.header(model))
		}.store(in: &headerSubscriptions)
	}
	
	func requestLike(postId: String, id: String, status: String) {

		network.requestLike(.commentLike(id: postId, commentId: id, status: status)) { [weak self] (result) in

			guard let self = self else {
				return
			}

			switch result {
			case .success(_):
				fallthrough
			default:
				self.presenter.presentResponse(.like(result))
			}
		}
	}
	
	func addComment(id: String, value: String) {
		guard let feedId: String = dataSource.dataHeader.id else {return}
		network.addComment(.addComment(id: id, value: value)) { [weak self] (result) in

			guard let self = self else {
				return
			}

			switch result {
			case .success(_):
				fallthrough
			default:
				self.dataSource.dataHeader.comments? += 1
				self.presenter.presentResponse(.addComment(result, feedId: feedId))
			}
		}
	}
}
