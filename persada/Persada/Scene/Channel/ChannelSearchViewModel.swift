//
//  ChannelSearchViewModel.swift
//  Persada
//
//  Created by Muhammad Noor on 18/05/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

class ChannelSearchViewModel {
	
	// MARK: - Public Property
	
	let networkModel: ChannelNetworkModel?
	var changeHandler: ((ChannelSearchViewModelChange) -> Void)?
	var type: String = ""
	var text: String = ""
	var currentPage: Int = 0
	
	// MARK: - Private Property
	
	private var cellFollowViewModels = [ChannelCellViewModel]()
	private var cellNotFollowViewModels = [ChannelCellViewModel]()
	private var contents = [Feed]()
	
	// MARK: - Private Method
	
	func fetchSearchAccounts() {
		networkModel?.searchChannel(.searchChannel(type: type, value: text, page: currentPage), { [weak self] (result) in
			
			guard let self = self else {
				return
			}
			
			switch result {
			
			case .failure(let error):
				DispatchQueue.main.async { [unowned self] in
					self.emit(.didEncounterError(error))
				}
			case .success(let response):
				
				self.contents = response.data?.content ?? []
			}
		})
	}
	
	// MARK: - Public Method
	
	init(networkModel: ChannelNetworkModel) {
		self.networkModel = networkModel
	}
	
	func getFollowNumberOfRows(section: Int) -> Int {
		return cellFollowViewModels.count
	}
	
	func getNotFollowNumberOfRows(section: Int) -> Int {
		return cellNotFollowViewModels.count
	}
	
	func getFollowCellViewModel(at index: Int) -> ChannelCellViewModel? {
		
		guard index < cellFollowViewModels.count else {
			return nil
		}
		
		return cellFollowViewModels[index]
	}
	
	func getNotFollowCellViewModel(at index: Int) -> ChannelCellViewModel? {
		
		guard index < cellNotFollowViewModels.count else {
			return nil
		}
		
		return cellNotFollowViewModels[index]
	}
	
	func emit(_ change: ChannelSearchViewModelChange) {
		changeHandler?(change)
	}
}

enum ChannelSearchViewModelChange {
	case didUpdateChannelsFollow(values: [ChannelCellViewModel])
	case didUpdateChannelsNotFollow(values: [ChannelCellViewModel])
	case didEncounterError(ErrorMessage?)
}
