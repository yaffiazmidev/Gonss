//
//  ProductInteractor.swift
//  Persada
//
//  Created by NOOR on 30/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import Foundation
import Combine

typealias ProductInteractable = ProductBusinessLogic & ProductDataStore

protocol ProductBusinessLogic {
	
	func doRequest(_ request: ProductModel.Request)
	func setPage(data: Int)
}

protocol ProductDataStore {
	var dataSource: ProductModel.DataSource { get set }
}

final class ProductInteractor: Interactable, ProductDataStore {
	
	var page: Int = 0
	var dataSource: ProductModel.DataSource
	var subscriptions = Set<AnyCancellable>()
	var presenter: ProductPresentationLogic
	var network: ProductNetworkModel
	var networkAddress: AddressNetworkModel
	
	init(viewController: ProductDisplayLogic?, dataSource: ProductModel.DataSource) {
		self.dataSource = dataSource
		self.network = ProductNetworkModel()
		self.networkAddress = AddressNetworkModel()
		self.presenter = ProductPresenter(viewController)
	}
}


// MARK: - ProductBusinessLogic
extension ProductInteractor: ProductBusinessLogic {
	func doRequest(_ request: ProductModel.Request) {
		DispatchQueue.global(qos: .background).async {
			switch request {

			case .listProduct(let isPagination):
				self.requestListProduct(isPagination)

			case .listProductById(let isPagination, let id):
				self.requestListProduct(isPagination, id)

			case .searchListProduct(let id, let search):
				self.requestSearchListProduct(id, search)
			}
			
		}
	}
	
	func setPage(data: Int) {
		dataSource.page = data
	}
}


// MARK: - Private Zone
private extension ProductInteractor {
	
	func requestListProduct(_ isPagination: Bool) {
	}

	func requestListProduct(_ isPagination: Bool, _ id: String) {
	}

	func requestSearchListProduct(_ id: String, _ text: String){
	}
}
