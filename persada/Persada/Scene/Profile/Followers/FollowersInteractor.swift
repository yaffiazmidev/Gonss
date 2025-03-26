//
//  FollowersInteractor.swift
//  KipasKipas
//
//  Created by movan on 31/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import Combine
import RxSwift

typealias FollowersInteractable = FollowersBusinessLogic & FollowersDataStore

protocol FollowersBusinessLogic {
	
	func doRequest(_ request: FollowersModel.Request)
}

protocol FollowersDataStore {
	var dataSource: FollowersModel.DataSource { get set }
	var page: Int { get set }
}

final class FollowersInteractor: Interactable, FollowersDataStore {
	
	var page: Int = 0
	var dataSource: FollowersModel.DataSource
	private var subscriptions: Set<AnyCancellable> = []
	private var presenter: FollowersPresentationLogic
	let network = ProfileNetworkModel()
    let profileUserCase: ProfileUseCase
    let disposeBag = DisposeBag()
    let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
	
	init(viewController: FollowersDisplayLogic?, dataSource: FollowersModel.DataSource) {
		self.dataSource = dataSource
		self.presenter = FollowersPresenter(viewController)
        self.profileUserCase = Injection.init().provideProfileUseCase()
	}
}


// MARK: - FollowersBusinessLogic
extension FollowersInteractor: FollowersBusinessLogic {
	
	func doRequest(_ request: FollowersModel.Request) {
		DispatchQueue.global(qos: .userInitiated).async {
			
			switch request {
				
			case let .fetchFollowers(id, isPagination):
				self.fetchFollowers(id, isPagination)
			case .follow(let id):
				self.follow(id)
			case let .searchAccount(id, text):
				self.searchAccount(id, text)
			case .unfollow(let id):
				self.unfollow(id)
			}
		}
	}
}


// MARK: - Private Zone
private extension FollowersInteractor {
	
	func fetchFollowers(_ id: String, _ isPagination: Bool) {
		
		network.fetchFollowers(.listFollowers(id: id, page: page))
			.sink(receiveCompletion: { (completion) in
				switch completion {
				case .finished:
					break
				case .failure(let error): print(error.localizedDescription)
				}
			}) { [weak self] (model: FollowerResult) in
				guard let self = self else { return }
				
				if isPagination  {
                    page = page + 1
					self.presenter.presentResponse(.paginationFollowers(result: model))
				} else {
					self.presenter.presentResponse(.followers(result: model))
				}
		}.store(in: &subscriptions)
	}
	
	func follow(_ id: String) {
		
		network.followAccount(.followAccount(id: id))
			.sink(receiveCompletion: { (completion) in
				if case .failure(let error) = completion, let apiError = error as? ErrorMessage {
					print(apiError)
				}
			}) { [weak self] (model: DefaultResponse) in
				guard let self = self else { return }
				
				self.presenter.presentResponse(.follow(result: model))
		}.store(in: &subscriptions)
	}
	
	func unfollow(_ id: String) {
		let network = ProfileNetworkModel()
		
		network.followAccount(.unfollowAccount(id: id))
			.sink(receiveCompletion: { (completion) in
				if case .failure(let error) = completion, let apiError = error as? ErrorMessage {
					print(apiError)
				}
			}) { [weak self] (model: DefaultResponse) in
				guard let self = self else { return }
				
				self.presenter.presentResponse(.unfollow(result: model))
		}.store(in: &subscriptions)
	}
	
	func searchAccount(_ id: String,_ text: String) {
        let request = ProfileEndpoint.searchFollowers(id: id, name: text, page: 0)
        profileUserCase.searchAccount(request: request)
            .subscribeOn(concurrentBackground)
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] result in
                guard let self = self else { return }
                guard let code = result.code, code == "1000" else {
                    print("Not found!")
                    return
                }
                self.presenter.presentResponse(.searchAccount(result: result))
            } onError: { error in
                print(error.localizedDescription)
            } onCompleted: {
            }.disposed(by: disposeBag)
	}
}
