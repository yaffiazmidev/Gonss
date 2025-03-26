//
//  ProfileFeedInteractor.swift
//  KipasKipasFeed
//
//  Created by DENAZMI on 01/11/23.
//

import UIKit
import KipasKipasNetworking

protocol IProfileFeedInteractor: AnyObject {
    var page: Int { get set }
    var totalPages: Int { get set }
    var userId: String { get set }
    var feeds: [FeedItem] { get set }
    var selectedFeedId: String { get set }
    var feedType: FeedType { get set }
    
    func requestFeeds()
    func updateLike(id: String, isLike: Bool)
}

class ProfileFeedInteractor: IProfileFeedInteractor {
    
    private let presenter: IProfileFeedPresenter
    private let network: DataTransferService
    
    var page: Int = 0
    var totalPages: Int = 0
    var userId: String = ""
    var feeds: [FeedItem] = []
    var selectedFeedId: String = ""
    var feedType: FeedType = .profile
    
    init(presenter: IProfileFeedPresenter, network: DataTransferService) {
        self.presenter = presenter
        self.network = network
    }
    
    func requestFeeds() {
        
        if !feeds.isEmpty {
            presenter.presentFeeds(items: feeds)
        }
        
        let endpoint: Endpoint<RemoteFeedItem?> = Endpoint(
            path: "profile/post/\(userId)",
            method: .get,
            queryParameters: [
                "page": page,
                "size": 10,
                "sort": "createAt,desc",
                //"isVodAvailable": "true"
            ]
        )
        
        network.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            
            if case .success(let response) = result {
                totalPages = (response?.data?.totalPages ?? 0) - 1
            }
            
            self.presenter.presentFeeds(with: result, feedType: feedType)
        }
    }
    
    func updateLike(id: String, isLike: Bool) {
        let endpoint: Endpoint<DefaultResponse?> = Endpoint(
            path: "likes/feed/\(id)",
            method: .patch,
            queryParameters: ["status": isLike ? "like" : "unlike"]
        )
        
        network.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            
            self.presenter.presentUpdateLike(with: result)
        }
    }
}
