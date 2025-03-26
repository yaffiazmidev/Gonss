//
//  NewsDetailViewModel.swift
//  Persada
//
//  Created by Muhammad Noor on 06/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

final class NewsDetailViewModel {
	
	// MARK: - Private Property
	
	private var networkModel: FeedNetworkModel?
	@Published var newsDetail: NewsDetail?
	
	// MARK: - Public Property
	
	var changeHandler: ((NewsDetailViewModelChange) -> Void)?
	// MARK: - Private Method
	
	func fetchDetailNews(id: String) {
        let endpoint = AUTH.isLogin() ? FeedEndpoint.newsDetail(id: id) : FeedEndpoint.newsDetailPublic(id: id)
        networkModel?.fetchDetailNews(endpoint, { [weak self] (result) in
            guard let self = self else { return}
            
            switch result {
            case .failure(let error):
                DispatchQueue.main.async { [unowned self] in
                    self.emit(.didEncounterError(error))
                }
            case .success(let response):
                guard let data = response.data else {
                    self.emit(.didEncounterError(ErrorMessage(statusCode: 404, statusMessage: "Data not found", statusData: "Not found")))
                    return
                }
                
                self.newsDetail = data
                self.emit(.didUpdateNewsDetail)
            }
        })
		
	}
    
    
    func fetchDetailNewsUnivLink(id: String) {
        let endpoint = AUTH.isLogin() ? FeedEndpoint.newsDetailUnivLink(id: id) : FeedEndpoint.newsDetailPublicUnivLink(id: id)
        networkModel?.fetchDetailNews(endpoint, { [weak self] (result) in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                DispatchQueue.main.async { [unowned self] in
                    self.emit(.didEncounterError(error))
                }
            case .success(let response):
                guard let data = response.data else {
                    self.emit(.didEncounterError(ErrorMessage(statusCode: 404, statusMessage: "Data not found", statusData: "Not found")))
                    return
                }
                self.newsDetail = data
                self.emit(.didUpdateNewsDetail)
            }
        })
        
    }
	
	// MARK: - Public Method
	
    init(networkModel: FeedNetworkModel, id: String, newsDetail : NewsDetail? = nil, _ isUnivLink: Bool = false) {
		self.networkModel = networkModel
		
        self.newsDetail = newsDetail
        if self.newsDetail != nil {
            self.emit(.didUpdateNewsDetail)
        } else {
            guard isUnivLink else {
                self.fetchDetailNews(id: id)
                return
            }
            
            self.fetchDetailNewsUnivLink(id: id)
        }
	}
	
	func requestLike() {

		networkModel?.requestLike(.likeFeed(id: newsDetail?.id ?? "", status: "like"), { [weak self] (result) in
			guard let self = self else { return}
			
			switch result {
			case .failure(let error):
				DispatchQueue.main.async { [unowned self] in
					self.emit(.didEncounterError(error))
				}
			case .success(let response):
				if response.code == "1000" {
					self.emit(.didLikeNews)
				}
			}
		})
	}
	
	func requestUnlike() {

		networkModel?.requestLike(.likeFeed(id: newsDetail?.id ?? "", status: "unlike"), { [weak self] (result) in
			guard let self = self else { return}
			
			switch result {
			case .failure(let error):
				DispatchQueue.main.async { [unowned self] in
					self.emit(.didEncounterError(error))
				}
			case .success(let response):
				if response.code == "1000" {
					self.emit(.didUnlikeNews)
				}
			}
		})
	}
	
	func getCellViewModel() -> NewsDetail? {
		return newsDetail
	}
	
	func emit(_ change: NewsDetailViewModelChange) {
		changeHandler?(change)
	}
}

enum NewsDetailViewModelChange {
	
	case didUpdateNewsDetail
	case didEncounterError(ErrorMessage?)
	case didLikeNews
	case didUnlikeNews
}
