//
//  DetailTransactionInteractor.swift
//  KipasKipas
//
//  Created by movan on 13/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import Combine

typealias DetailTransactionInteractable = DetailTransactionBusinessLogic & DetailTransactionDataStore

protocol DetailTransactionBusinessLogic {
	
	func doRequest(_ request: DetailTransactionModel.Request)
}

protocol DetailTransactionDataStore {
	var dataSource: DetailTransactionModel.DataSource { get set }
}

final class DetailTransactionInteractor: Interactable, DetailTransactionDataStore {
	
	var dataSource: DetailTransactionModel.DataSource
	private var subscriptions: AnyCancellable?
	private var subscriptionsShipment: AnyCancellable?
    private var subscriptionsProduct: AnyCancellable?
    private var subscriptionsComplete: AnyCancellable?
	private var presenter: DetailTransactionPresentationLogic
	private let network = OrderNetworkModel()
	private let shipmentNetwork = ShipmentNetworkModel()
	
	init(viewController: DetailTransactionDisplayLogic?, dataSource: DetailTransactionModel.DataSource) {
		self.dataSource = dataSource
		self.presenter = DetailTransactionPresenter(viewController)
	}
}


// MARK: - DetailTransactionBusinessLogic
extension DetailTransactionInteractor: DetailTransactionBusinessLogic {
	
	func doRequest(_ request: DetailTransactionModel.Request) {
		DispatchQueue.global(qos: .userInitiated).async {
			
			switch request {
				
			case .requestOrderDetail(let id):
				self.requestOrderDetail(id)
			case let .processOrder(id, type):
				self.processOrder(id, type)
			case let .requestPickUP(service, id):
				self.requestPickUp(service, id)
			case .showBarcode(let id):
				self.requestShowBarcoder(id)
			case .fetchTrackingShipment(let id):
				self.fetchTrackingShipment(id)
            case .productById(let id):
                self.getProductById(id)
            case .completeOrder(let id):
                self.completeOrder(id)
			}
		}
	}
}


// MARK: - Private Zone
private extension DetailTransactionInteractor {
	
	func requestOrderDetail(_ id: String) {
		
		subscriptions = network.requestOrderDetail(.detailTransaction(id: id)).sink { (completion) in
			switch completion {
			case .failure(let error): print(error.localizedDescription)
			case .finished: break
			}
		} receiveValue: { [weak self] (model: TransactionProductResult) in
			guard let self = self else { return }
			
			self.presenter.presentResponse(.products(result: model))
		}
	}
	
	func processOrder(_ id: String,_ type: ProcessOrder) {
		
		subscriptions = network.processOrder(.processOrder(id: id, type: type)).sink { (complete) in
			switch complete {
			case .failure(let error): print(error.localizedDescription)
			case .finished: break
			}
		} receiveValue: { [weak self] (model: DefaultResponse) in
			guard let self = self else { return }
			
			self.presenter.presentResponse(.processOrder(result: model))
		}

	}
	
	func requestPickUp(_ service: String, _ id: String) {
				
		subscriptions = shipmentNetwork.requestPickUp(.requestPickUp(serviceName: service, id: id)).sink { (completion) in
			switch completion {
			case .failure(let error): print(error.localizedDescription)
			case .finished: break
			}
		} receiveValue: { [weak self] (model) in
			guard let self = self else { return }
			
			self.presenter.presentResponse(.pickUp(result: model))
		}
	}
	
	func requestShowBarcoder(_ id: String) {
		subscriptions = network.showBarcode(.showBarcode(awbNumber: id)).sink { (completion) in
			switch completion {
			case .failure(let error): print(error.localizedDescription)
			case .finished: break
			}
		} receiveValue: { [weak self] (model) in
			self?.presenter.presentResponse(.barcode(result: model))
		}
	}
	
	func fetchTrackingShipment(_ id: String) {
		
		subscriptionsShipment = shipmentNetwork.requestTracking(.tracking(id: id))
			.sink(receiveCompletion: { (completion) in
				switch completion {
				case .failure(let error):
					print(error.localizedDescription)
				case .finished:
					print("finished tracking shipmen")
				}
			}) { [weak self] (model: TrackingShipmentResult) in
				guard let self = self else { return }
				
				self.presenter.presentResponse(.trackingShipment(result: model))
		}
	}
    
    func getProductById(_ id: String) {
        let network = ProductNetworkModel()
        
        subscriptionsProduct = network.getProductByID(.getProductById(id: id))
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .failure(let error):
                    print(error.localizedDescription)
                case .finished:
                    print("finished tracking shipmen")
                }
            }) { [weak self] (model: ProductDetailResult) in
							guard let self = self else { return }
							
                self.presenter.presentResponse(.productById(result: model))
        }
    }
    
    func completeOrder(_ id: String) {
        let network = OrderNetworkModel()
        
        subscriptionsComplete = network.completeOrder(.completeOrder(id: id))
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .failure(let error):
                    print(error.localizedDescription)
                case .finished:
                    print("finished tracking shipmen")
                }
            }) { [weak self] (model: DefaultResponse) in
							guard let self = self else { return }
							
                self.presenter.presentResponse(.completeOrder(result: model))
        }
    }
}
