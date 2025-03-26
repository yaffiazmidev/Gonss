//
//  CancelSalesOrderModel.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 03/02/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import Foundation
import Combine

enum CancelSalesOrderModel {
	
	enum Request {
		case reasonDecline
		case cancelSalesOrder(reason: CancelSalesOrderInput)
	}
	
	enum Response {
		case reasons(result: DeclineOrderResult)
		case cancelOrder(result: DefaultResponse)
	}
	
	enum ViewModel {
		case reasons(viewModel: [DeclineOrder])
		case cancelOrder(viewModel: DefaultResponse)
	}
	
	enum Route {
		case dismiss
	}
	
	class DataSource: DataSourceable {
		var id: String = ""
		var data: CancelSalesOrderInput?
		@Published var dataReasons: [DeclineOrder]? = []
	}
}

struct CancelSalesOrderInput: Codable {
	var type, targetReportedId: String
	internal var reasonReport: DeclineOrder
}
