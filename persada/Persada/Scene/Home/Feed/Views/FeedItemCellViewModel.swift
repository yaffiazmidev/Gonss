//
//  FeedItemCellViewModel.swift
//  KipasKipas
//
//  Created by movan on 13/11/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import Combine

final class FeedItemCellViewModel: NSObject {
	
	var network: FeedNetworkModel?
	private var subscriptions: Set<AnyCancellable> = Set<AnyCancellable>()
	var handler: ((FeedItemCellViewModelChange) -> Void)?
	
	init(network: FeedNetworkModel) {
		self.network = network
	}
	
	func like(id: String, status: String) {
		network?.like(.likeFeed(id: id, status: status)).sink(receiveCompletion: { (completion) in
			switch completion {
			case .failure(let error): print(error.localizedDescription)
			case .finished: break
			}
		}, receiveValue: { [weak self] (model: DefaultResponse) in
			guard let self = self else { return }
			
			if model.code == "1000" && status == "like" {
				self.emit(.likePost(status: "like"))
			} else if ( model.code == "1000" && status == "unlike") {
				self.emit(.likePost(status: "unlike"))
			}
		}).store(in: &subscriptions)
	}
	
	func emit(_ change: FeedItemCellViewModelChange) {
		handler?(change)
	}
}

enum FeedItemCellViewModelChange {
	case likePost(status: String)
}
