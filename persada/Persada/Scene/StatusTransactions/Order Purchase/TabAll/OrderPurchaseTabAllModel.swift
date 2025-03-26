//
//  OrderPurchaseTabAllModel.swift
//  KipasKipas
//
//  Created by NOOR on 26/01/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import Foundation
import Combine

enum OrderPurchaseTabAllModel {
	
	enum Request: Endpointable, Equatable {
		case getOrderPurchaseTabAll(page: Int)
		case getOrderPurchaseTabProcess(page: Int)
		case getOrderPurchaseTabWaiting(page: Int)
		case getOrderPurchaseTabShipping(page: Int)
		case getOrderPurchaseTabUnpaid(page: Int)
		case getOrderPurchaseTabComplete(page: Int)
		case getOrderPurchaseTabCancel(page: Int)
        case completeOrder(id: String)
	}
	
	enum Response {
		case orderPurchase(result: StatusOrderResult)
        case completeOrder(result: DefaultResponse)
	}
	
	enum ViewModel {
		case orderPurchase(viewModel: [OrderCellViewModel], lastPage: Int)
        case completeOrder(viewModel: DefaultResponse)
	}
	
	enum Route {
		case detailTransaction(data: OrderCellViewModel)
		case trackingShipment(id: String)
		case browser(url: String)
		case dismiss
        case virtualAccount(bankName : String, bankNumber : String, time : Int)
        case addReview(orderId: String, productName: String, productPhotoUrl: String, completion: (() -> Void)?)
	}
	
	class DataSource: DataSourceable {
		@Published var data: [OrderCellViewModel] = []
		var totalOrder = CurrentValueSubject<Int, Never>(0)
	}
}
