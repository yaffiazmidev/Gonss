//
//  ChannelDetailInteractor.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 31/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import Foundation
import RxSwift
import RxCocoa

typealias ChannelDetailInteractable = ChannelDetailBusinessLogic & ChannelDetailDataStore

protocol ChannelDetailBusinessLogic {
    
    func doRequest(_ request: ChannelDetailModel.Request)
	func requestChannelPost(_ id: String, page: Int) -> Observable<[Feed]>
	func requestChannelId(id: String, page: Int) -> Observable<[Feed]>
	func requestLike(id: String, status: String) -> Observable<DefaultResponse>
}

protocol ChannelDetailDataStore {
    var dataSource: ChannelDetailModel.DataSource { get }
}

final class ChannelDetailInteractor: Interactable, ChannelDetailDataStore {
    
    var dataSource: ChannelDetailModel.DataSource
	var network: ChannelNetworkModel = ChannelNetworkModel()
	var feedNetwork: FeedNetworkModel = FeedNetworkModel()
    var presenter: ChannelDetailPresentationLogic
    
    init(viewController: ChannelDetailDisplayLogic?, dataSource: ChannelDetailModel.DataSource) {
        self.dataSource = dataSource
        self.presenter = ChannelDetailPresenter(viewController)
    }
}


// MARK: - ChannelDetailBusinessLogic
extension ChannelDetailInteractor: ChannelDetailBusinessLogic {
    
    func doRequest(_ request: ChannelDetailModel.Request) {
        DispatchQueue.global(qos: .userInitiated).async {
        }
    }
}


// MARK: - Private Zone
extension ChannelDetailInteractor {
	
	func requestLike(id: String, status: String) -> Observable<DefaultResponse> {
		return Observable.create { observer in
			self.feedNetwork.requestLike(.likeFeed(id: id, status: status)) { [weak self] result in
				guard let self = self else { return }
				
				switch result {
				case .success(let data): observer.onNext(data)
				case .failure(let error): observer.onError(error!)
				}
				observer.onCompleted()
			}
			return Disposables.create()
		}
		
	}

	func requestChannelId(id: String, page: Int) -> Observable<[Feed]> {
		return Observable.create{ observer in
			self.network.requestChannelFeedById(.channelDetailById(id: id, page: page), { result in
				switch result {
					case .success(let feed): observer.onNext(feed.data!.content!)
					case .failure(let err): observer.onError(err!)
				}
				observer.onCompleted()
			})
			return Disposables.create()
		}
	}


	func requestChannelPost(_ id: String, page: Int) -> Observable<[Feed]> {
		return Observable.create { observer in
			self.network.requestChannelGeneralPost(.channelGeneralPost(id: id, page: page), {
				result in
				switch result {
					case .success(let feed): observer.onNext(feed.data!.content!)
					case .failure(let err): observer.onError(err!)
				}
				observer.onCompleted()
				})
			return Disposables.create()
		}
	}
}
