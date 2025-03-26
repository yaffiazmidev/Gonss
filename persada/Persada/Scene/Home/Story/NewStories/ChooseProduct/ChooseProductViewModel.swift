//
//  ChooseProductViewModel.swift
//  Persada
//
//  Created by movan on 20/07/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//


import Foundation
import Combine

enum ChooseProductViewModelState {
	case loading
	case finishedLoading
	case error(Error)
}

final class ChooseProductViewModel {
	@Published var searchText: String = ""
	@Published private(set) var chooseProductViewModels: [ChooseProductCellViewModel] = []
	@Published private(set) var state: ChooseProductViewModelState = .loading
	
	private let playersService: ProductNetworkModel
	private var subscriptions = Set<AnyCancellable>()
	
	init(playersService: ProductNetworkModel = ProductNetworkModel()) {
		self.playersService = playersService
		
		$searchText
			.sink { [weak self] in self?.fetchPlayers(with: $0) }
			.store(in: &subscriptions)
	}
	
	func fetchPlayers(with searchTerm: String?) {
		state = .loading
		
		let searchTermCompletionHandler: (Subscribers.Completion<Error>) -> Void = { [weak self] completion in
			switch completion {
			case .failure(let error): self?.state = .error(error)
			case .finished: self?.state = .finishedLoading
			}
		}
		
		let searchTermValueHandler: (ProductResult) -> Void = { [weak self] result in
			self?.chooseProductViewModels.append(contentsOf: result.data?.content?.compactMap({ (product) -> ChooseProductCellViewModel in
				return ChooseProductCellViewModel(product: product)
			}) ?? [])
			
		}
		
		playersService
			.searchMyProducts(.searchMyProducts(text: searchTerm ?? ""))
			.sink(receiveCompletion: searchTermCompletionHandler, receiveValue: searchTermValueHandler)
			.store(in: &subscriptions)
	}
}

