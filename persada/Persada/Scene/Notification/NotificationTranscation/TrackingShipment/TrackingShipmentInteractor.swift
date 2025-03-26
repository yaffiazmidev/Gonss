//
//  TrackingShipmentInteractor.swift
//  KipasKipas
//
//  Created by movan on 18/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import Combine

typealias TrackingShipmentInteractable = TrackingShipmentBusinessLogic & TrackingShipmentDataStore

protocol TrackingShipmentBusinessLogic {
	
	func doRequest(_ request: TrackingShipmentModel.Request)
}

protocol TrackingShipmentDataStore {
	var dataSource: TrackingShipmentModel.DataSource { get set }
}

final class TrackingShipmentInteractor: Interactable, TrackingShipmentDataStore {
	
	var dataSource: TrackingShipmentModel.DataSource
	private var subscriptions = Set<AnyCancellable>()
	private var presenter: TrackingShipmentPresentationLogic
	
	init(viewController: TrackingShipmentDisplayLogic?, dataSource: TrackingShipmentModel.DataSource) {
		self.dataSource = dataSource
		self.presenter = TrackingShipmentPresenter(viewController)
	}
}


// MARK: - TrackingShipmentBusinessLogic
extension TrackingShipmentInteractor: TrackingShipmentBusinessLogic {
	
	func doRequest(_ request: TrackingShipmentModel.Request) {
		DispatchQueue.global(qos: .userInitiated).async {
			
			switch request {
				
			case .fetchTracking(let id):
				self.fetchTrackingShipment(id)
			}
		}
	}
}


// MARK: - Private Zone
private extension TrackingShipmentInteractor {
	
	func fetchTrackingShipment(_ id: String) {
		let network = ShipmentNetworkModel()
		
		network.requestTracking(.tracking(id: id))
			.sink(receiveCompletion: { (completion) in
				switch completion {
				case .failure(let error):
					print(error.localizedDescription)
				case .finished:
					print("finished tracking shipmen")
				}
			}) { (model: TrackingShipmentResult) in
				self.presenter.presentResponse(.trackingShipment(result: model))
		}.store(in: &subscriptions)
	}
}
