//
//  ChannelContentsViewModel.swift
//  Persada
//
//  Created by Muhammad Noor on 08/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import Combine
import RxSwift

class ChannelContentsViewModel {
	
	// MARK: - Private Property
	private var cellViewModels = [SelebCellViewModel]()
	private var channels = [Feed]()
	private var total = 0
	private var isFetchInProgress = false
	
	// MARK: - Public Property
	
	var changeHandler: ((ChannelDetailViewModelChange) -> Void)?
	let networkModel: ChannelNetworkModel!
	var currentPage: Int = 0
	var channelId: String = ""
	var postId: String = ""
	var statusLike: String = ""
    var isFollow: Bool = false
	private var subscriptions = Set<AnyCancellable>()
    
    private let channelNetwork: IChannelContentsWorker
	
	var totalCount: Int {
		return total
	}
	
	var currentCount: Int {
		return cellViewModels.count - 1
	}
	
	// MARK: - Public Method
	
	init(networkModel: ChannelNetworkModel) {
		self.networkModel = networkModel
        self.channelNetwork = ChannelContentsWorker(network: DIContainer.shared.apiDataTransferService)
	}
	
	func getNumberOfRows(section: Int) -> Int {
		return cellViewModels.count
	}
	
	func getCellViewModel(at index: Int) -> SelebCellViewModel? {
		
		guard index < cellViewModels.count else {
			return nil
		}
		
		return cellViewModels[index]
	}
	
	func emit(_ change: ChannelDetailViewModelChange) {
		changeHandler?(change)
	}
	
    func fetchChannel() {
        channelNetwork.getChannel(with: channelId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                self.isFollow = response.data?.isFollow ?? false
                self.emit(.didGetChannel)
            }
        }
    }
    
    func followChannel() {
        channelNetwork.followChannel(with: channelId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(_):
                self.isFollow = true
                self.emit(.didFollowChannel)
            }
        }
    }
	
	func unfollowChannel() {
        channelNetwork.unfollowChannel(with: channelId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(_):
                self.isFollow = false
                self.emit(.didUnFollowChannel)
            }
        }
	}
	
	func fetchChannelDetail() {
		
		guard !self.isFetchInProgress else {
			return
		}
		
		self.isFetchInProgress = true
		
		networkModel.fetchChannelDetail(.channelDetail(id: channelId, page: currentPage)) { [weak self] (resuls) in
			
			guard let self = self else {
				return
			}
			
			switch resuls {
				
			case.failure(let error):
				DispatchQueue.main.async { [unowned self] in
					self.emit(.didEncounterError(error))
				}
				
			case.success(let response):
				
				DispatchQueue.main.async { [weak self] in
					
					guard let self = self else { return }
					
					self.currentPage += 1
					self.isFetchInProgress = false
					
					if let reponse = response.data?.content {
						self.total = response.data?.numberOfElements ?? 0
						
						let resultSeleb = reponse.map{ (seleb) -> SelebCellViewModel in
							return SelebCellViewModel(value: seleb)!
						}
						DispatchQueue.global(qos: .background).async {
							self.cellViewModels.append(contentsOf: resultSeleb)
						}
						
						if response.data?.number ?? 0 > 0 {
							let indexPathsToReload = self.calculateIndexPathsToReload(from: self.cellViewModels)
							self.emit(.didUpdateContentChannel(newIndexPathsToReload: indexPathsToReload))
						} else {
							self.emit(.didUpdateContentChannel(newIndexPathsToReload: .none))
						}
					}
				}
			}
		}
	}
	
	func requestChannelDetail(page: Int) -> Observable<[Feed]> {
		return Observable.create { observer in
			self.networkModel.fetchChannelDetail(.channelDetail(id: self.channelId, page: self.currentPage)) { [weak self] result in
				
				guard let self = self else { return }
				
				switch result {
				case .failure(let error): observer.onError(error!)
				case .success(let response):
					guard let feed = response.data?.content else {
						return
					}
					
					feed.forEach { value in
						self.cellViewModels.append(SelebCellViewModel(value: value)!)
					}
					observer.onNext(feed)
				}
			}
			return Disposables.create()
		}
	}
	
	private func calculateIndexPathsToReload(from newModerators: [SelebCellViewModel]) -> [IndexPath] {
		let startIndex = cellViewModels.count - newModerators.count
		let endIndex = startIndex + newModerators.count
		return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
	}
}

enum ChannelDetailViewModelChange {
	case didUpdateContentChannel(newIndexPathsToReload: [IndexPath]?)
	case didEncounterError(ErrorMessage?)
	case didFollowChannel
	case didUnFollowChannel
    case didGetChannel
}
