//
//  NewsViewModel.swift
//  Persada
//
//  Created by Muhammad Noor on 05/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import Combine
import RxSwift
import RxCocoa

protocol NewsViewModelInputs {
	var fetchTrendingNewsTrigger: PassthroughSubject<Void, Never> { get }
	var fetchCategoryNewsTrigger: PassthroughSubject<Void, Never> { get }
	var fetchNewsTrigger: PassthroughSubject<Void, Never> { get }
	var fetchNewsWithSelectedCategoryTrigger: PassthroughSubject<String, Never> { get }
}

protocol NewsViewModelOutputs {
	var cellHeaderViewModels: AnyPublisher<[NewsImageCellViewModel], Never> { get }
	var cellCategoryViewModels: AnyPublisher<[NewsCategoryData], Never> { get }
	var cellViewModels: AnyPublisher<[NewsCellViewModel], Never> { get }
	var cellSelectedCategory: AnyPublisher<String, Never> { get }
}

protocol NewsViewModelType {
	var input: NewsViewModelInputs { get }
	var output: NewsViewModelOutputs { get }
}

final class NewsViewModel: NewsViewModelType, NewsViewModelOutputs {
	
	// @Publish
	
	@Published var _cellViewModels: [NewsCellViewModel] = []
	@Published var _cellHeaderViewModels: [NewsImageCellViewModel] = []
	@Published var _cellCategoryViewModels: [NewsCategoryData] = []
	@Published var _cellSelectedCategoryViewModel: String = ""
    let categoryId = BehaviorRelay<String>(value: "")
	
	// MARK: - NewsViewModelInputs
	
	let fetchTrendingNewsTrigger = PassthroughSubject<Void, Never>()
	let fetchCategoryNewsTrigger = PassthroughSubject<Void, Never>()
	let fetchNewsTrigger = PassthroughSubject<Void, Never>()
	let fetchNewsWithSelectedCategoryTrigger = PassthroughSubject<String, Never>()
	
	// MARK: - NewsViewModelType
	
	var input: NewsViewModelInputs { return self }
	var output: NewsViewModelOutputs { return self }
	
	// MARK: - Private Property

	private var subscriptions: Set<AnyCancellable> = Set<AnyCancellable>()
	var currentPage: Int = 0
	var totalPages : Int = 0
	private var hasNextPage: Bool = true
	
	// MARK: - Public Property
	
	let networkNewsModel: NewsNetworkModel?
	let networkModel: FeedNetworkModel?
	let networkFollowModel: ProfileNetworkModel?
	
	var cellHeaderViewModels: AnyPublisher<[NewsImageCellViewModel], Never> {
		return $_cellHeaderViewModels.eraseToAnyPublisher()
	}
	
	var cellCategoryViewModels: AnyPublisher<[NewsCategoryData], Never> {
		return $_cellCategoryViewModels.eraseToAnyPublisher()
	}
	
	var cellViewModels: AnyPublisher<[NewsCellViewModel], Never> {
		return $_cellViewModels.eraseToAnyPublisher()
	}
	
	var cellSelectedCategory: AnyPublisher<String, Never> {
		return $_cellSelectedCategoryViewModel.eraseToAnyPublisher()
	}
	
	// MARK: - Public Method
	
	init(networkNewsModel: NewsNetworkModel, networkModel: FeedNetworkModel, networkFollowModel: ProfileNetworkModel) {
		self.networkModel = networkModel
		self.networkFollowModel = networkFollowModel
		self.networkNewsModel = networkNewsModel
		
		self.fetchTrendingNewsTrigger.sink { [weak self] in
			guard let self = self else { return }
			self.requestTrendingNews()
		}.store(in: &subscriptions)
		
		self.fetchCategoryNewsTrigger.sink { [weak self] in
			guard let self = self else { return }
			self.requestCategoryNews()
		}.store(in: &subscriptions)
		
		self.fetchNewsTrigger.sink { [weak self] in
			guard let self = self else { return }
			self.requestNews(id: self._cellSelectedCategoryViewModel)
		}.store(in: &subscriptions)
		
		self.fetchNewsWithSelectedCategoryTrigger.sink { [weak self] (id) in
			guard let self = self else { return }
			self._cellSelectedCategoryViewModel = id
			self.requestNews(id: id)
		}.store(in: &subscriptions)
	}
	
	func requestLike() {
//		networkModel?.requestLike(.likeFeed(id: postId, status: statusLike), { [weak self] (result) in
//
//			guard let self = self else {
//				return
//			}
//
//			switch result {
//
//			case .failure(let error):
//				DispatchQueue.main.async { [unowned self] in
//					self.emit(.didEncounterError(error))
//				}
//			case .success(let response):
//				if response.code == "1000" {}
//			}
//		})
	}
	
	func followUser() {
//		networkFollowModel?.followAccount(.followAccount(id: userId), { [weak self] (result) in
//			guard let self = self else {
//				return
//			}
//
//			switch result {
//			case .failure(let error):
//				DispatchQueue.main.async { [unowned self] in
//					self.emit(.didEncounterError(error))
//				}
//			case .success(let response):
//				if response.code == "1000" {
//				}
//			}
//		})
	}
}

extension NewsViewModel: NewsViewModelInputs {
    func requestTrendingNews() {
        categoryId.accept("")
        let request: NewsEndpoint = AUTH.isLogin() ? .newsAllCategory(page: currentPage) : .newsAllCategoryPublic(page: currentPage)
        networkNewsModel?.fetchNews(request: request).subscribe(on: DispatchQueue.global(qos: .background))
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .finished: print("Finished fetch trending news")
                case .failure(let error): print(error.localizedDescription)
                }
            }, receiveValue: { [weak self] (model: NewsArray) in
                guard let self = self else { return }
                guard let resultResponse = model.data else { return }
                
                let validData = resultResponse.content.flatMap{ (value: [NewsDetail]) -> [NewsCellViewModel] in
                    return value.map { NewsCellViewModel(value: $0)! }
                }
                
                self._cellViewModels = validData ?? []
            }).store(in: &subscriptions)
    }
    
    func requestNews(id: String) {
        categoryId.accept(id)
        
        if currentPage <= totalPages {
            let request: NewsEndpoint = AUTH.isLogin() ? .news(id: id, page: self.currentPage) : .newsPublic(id: id, page: self.currentPage)
            networkNewsModel!.fetchNews(request: request).subscribe(on: DispatchQueue.global(qos: .background))
                .sink(receiveCompletion: { (completion) in
                    switch completion {
                    case .failure(let error): print(error.localizedDescription)
                    case .finished: break
                    }
                }, receiveValue: {
                    let validData = $0.data?.content.flatMap{ (value: [NewsDetail]) -> [NewsCellViewModel] in
                        return value.map { NewsCellViewModel(value: $0)! }
                    }
                    
                    self._cellViewModels = validData ?? []
                    self.totalPages = $0.data?.totalPages ?? 0
                }).store(in: &subscriptions)
        }
    }
    
    func requestCategoryNews() {
        let request: NewsEndpoint = AUTH.isLogin() ? .newsCategory : .newsCategoryPublic
        networkNewsModel?.fetchCategory(request: request).subscribe(on: DispatchQueue.global(qos: .background))
            .sink(receiveCompletion: { completion in
            switch completion {
            case .finished: break
            case .failure(let error): print(error.localizedDescription)
            }
        }, receiveValue: { [weak self] (model: NewsCategoryResult) in
            guard let self = self else { return }
            guard let validData = model.data else { return }
            
            self._cellCategoryViewModels = validData
            self._cellSelectedCategoryViewModel = ""
            self.requestNews(id: self._cellSelectedCategoryViewModel)
        }).store(in: &subscriptions)
    }
}
