//
//  SubcommentInteractor.swift
//  Persada
//
//  Created by NOOR on 25/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import Foundation
import Combine

typealias SubcommentInteractable = SubcommentBusinessLogic & SubcommentDataStore

protocol SubcommentBusinessLogic {
	
	func doRequest(_ request: SubcommentModel.Request)
	func setPage(page: Int)
}

protocol SubcommentDataStore {
	var dataSource: SubcommentModel.DataSource { get set }
}

final class SubcommentInteractor: Interactable, SubcommentDataStore {

	let network: FeedNetworkModel = FeedNetworkModel()
	var dataSource: SubcommentModel.DataSource
	private var subcommentsubscriptions = Set<AnyCancellable>()
	var presenter: SubcommentPresentationLogic
	
	init(viewController: SubcommentDisplayLogic?, dataSource: SubcommentModel.DataSource) {
		self.dataSource = dataSource
		self.presenter = SubcommentPresenter(viewController)
	}
}


// MARK: - SubcommentBusinessLogic
extension SubcommentInteractor: SubcommentBusinessLogic {


	func setPage(page: Int) {
		dataSource.page = page
	}

	func doRequest(_ request: SubcommentModel.Request) {
		DispatchQueue.global(qos: .userInitiated).async {
			
			switch request {
			case .fetchSubcomment(let id, let page, let isPagination):
				self.fetchSubcomment(id, page, isPagination)
			case .like(_, let id, let status, let index):
				self.dataSource.index = index
				self.dataSource.statusLike = status
				self.requestLike(postId: self.dataSource.postId ?? "" , id: id, status: status)
			case .addSubcomment(let id, let commentId, let value):
				self.addSubcomment(id: id, commentId: commentId, value: value)
				case .deleteComment:
				self.deleteComment()
				case .deleteSubComment(let id):
					self.deleteSubComment(id: id)
			}
		}
	}
}


// MARK: - Private Zone
private extension SubcommentInteractor {
	
	func fetchSubcomment(_ id: String,_ page: Int, _ isPagination: Bool) {
		
		network.fetchSubcomment(.subcomment(id: id, page: page)).sink(receiveCompletion: { (completion) in
			switch completion {
			case .failure(let error): print(error.localizedDescription)
				fallthrough
			case .finished: break
			}
		}) { [weak self] (model: SubcommentResult) in
			guard let self = self else { return }
			
			if isPagination {
				self.presenter.presentResponse(.subcomment(model))
			} else {
				self.presenter.presentResponse(.paginationSubcomment(model))
			}
		}.store(in: &subcommentsubscriptions)
	}
	
	func requestLike(postId: String, id: String, status: String) {
		
		network.requestLike(.subcommentLike(id: postId, subcommentId: id, status: status)) { [weak self] (result) in

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

	func deleteComment() {
		guard let commentId: String = dataSource.id else {return}
		guard let feedId: String = dataSource.feed?.id else {return}

		network.deleteComment(.deleteComment(id: commentId)) { [weak self] (result) in
			guard let self = self else {
				return
			}

			switch result {
				case .success(_):
					fallthrough
				default:
					self.presenter.presentResponse(.deleteComment(result, feedId: feedId))
			}
		}
	}

	func deleteSubComment(id: String) {
		network.deleteSubComment(.deleteSubComment(id: id)) { [weak self] (result) in

			guard let self = self else {
				return
			}
			switch result {
				case .success(_):
					fallthrough
				default:
					self.presenter.presentResponse(.deleteSubComment(result))
			}

		}
	}
	
	func addSubcomment(id: String, commentId: String, value: String) {
		
		network.addSubcomment(.addSubcomment(id: id, commentId: commentId, value: value)) { [weak self] (result) in

			guard let self = self else {
				return
			}

			switch result {
			case .success(_):
				fallthrough
			default:
				self.presenter.presentResponse(.addSubcomment(result))
			}
		}
	}
}
