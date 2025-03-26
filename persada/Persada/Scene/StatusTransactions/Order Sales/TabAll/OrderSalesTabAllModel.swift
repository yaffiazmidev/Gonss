//
//  OrderSalesTabAllModel.swift
//  KipasKipas
//
//  Created by NOOR on 21/01/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import Foundation
import Combine

enum OrderSalesTabAllModel {
	
	enum Request: Endpointable, Equatable {
		case getOrderSalesTabNew(page: Int)
		case getOrderSalesTabProcess(page: Int)
		case getOrderSalesTabShipping(page: Int)
		case getOrderSalesTabComplete(page: Int)
		case getOrderSalesTabCancel(page: Int)
		case requestPickUp(service: String, id: String)
	}
	
	enum Response {
		case orderSales(result: StatusOrderResult)
		case pickUp(result: RequestPickUpResponse)
	}
	
	enum ViewModel {
		case orderSales(viewModel: [OrderCellViewModel], lastPage: Int)
		case pickUp(viewModel: RequestPickUpResponse)
	}
	
	enum Route {
		case detailTransaction(data: OrderCellViewModel, showPriceTerms: ProcessTermsCondition, title: String)
		case trackingShipment(id: String)
		case browser(url: String)
		case dismiss
	}
	
	class DataSource: DataSourceable {
		@Published var data: [OrderCellViewModel] = []
		var terms: ProcessTermsCondition?
		var title: String?
		var totalOrder = CurrentValueSubject<Int, Never>(0)
	}
}
