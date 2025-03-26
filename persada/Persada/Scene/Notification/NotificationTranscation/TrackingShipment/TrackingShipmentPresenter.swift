//
//  TrackingShipmentPresenter.swift
//  KipasKipas
//
//  Created by movan on 18/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation

protocol TrackingShipmentPresentationLogic {
	func presentResponse(_ response: TrackingShipmentModel.Response)
}

final class TrackingShipmentPresenter: Presentable {
	private weak var viewController: TrackingShipmentDisplayLogic?
	
	init(_ viewController: TrackingShipmentDisplayLogic?) {
		self.viewController = viewController
	}
}


// MARK: - TrackingShipmentPresentationLogic
extension TrackingShipmentPresenter: TrackingShipmentPresentationLogic {
	
	func presentResponse(_ response: TrackingShipmentModel.Response) {
		
		switch response {
			
		case .trackingShipment(let result):
			self.presentListTrackingShipment(result)
		}
	}
}


// MARK: - Private Zone
private extension TrackingShipmentPresenter {
	
	func presentListTrackingShipment(_ result: TrackingShipmentResult) {
		
		guard let validData = result.data?.first?.historyTracking else {
			return
		}
		
		viewController?.displayViewModel(.trackingShipment(viewModel: validData))
	}
}
