//
//  FollowingsInteractor.swift
//  KipasKipas
//
//  Created by movan on 31/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import Combine
import RxSwift

typealias FollowingsInteractable = FollowingsBusinessLogic & FollowingsDataStore

protocol FollowingsBusinessLogic {
	
	func doRequest(_ request: FollowingsModel.Request)
}

protocol FollowingsDataStore {
	var dataSource: FollowingsModel.DataSource { get set }
	var page: Int { get set }
}

final class FollowingsInteractor: Interactable, FollowingsDataStore {
	
	var page: Int = 0
	var dataSource: FollowingsModel.DataSource
	private var subscriptions: Set<AnyCancellable> = []
	private var presenter: FollowingsPresentationLogic
	private let network = ProfileNetworkModel()
	private let profileNetwork = ProfileNetworkModel()
    let profileUserCase: ProfileUseCase
    let disposeBag = DisposeBag()
    let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
	
	init(viewController: FollowingsDisplayLogic?, dataSource: FollowingsModel.DataSource) {
		self.dataSource = dataSource
		self.presenter = FollowingsPresenter(viewController)
        self.profileUserCase = Injection.init().provideProfileUseCase()
	}
}


// MARK: - FollowingsBusinessLogic
extension FollowingsInteractor: FollowingsBusinessLogic {
	
	func doRequest(_ request: FollowingsModel.Request) {
		DispatchQueue.global(qos: .userInitiated).async {
			
			switch request {
				
			case let .fetchFollowings(id, isPagination):
				self.fetchFollowings(id, isPagination)
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
private extension FollowingsInteractor {
	
	func fetchFollowings(_ id: String, _ isPagination: Bool) {
		
		profileNetwork.fetchFollowings(.listFollowings(id: id, page: page))
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
					self.presenter.presentResponse(.paginationFollowings(result: model))
				} else {
					self.presenter.presentResponse(.followings(result: model))
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
	
	func searchAccount(_ id: String, _ text: String) {
        let request = ProfileEndpoint.searchFollowing(id: id, name: text, page: 0)
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
