//
//  TransactionEndpoint.swift
//  KipasKipas
//
//  Created by NOOR on 19/01/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

enum TransactionEndpoint {
	case getOrderSalesTabAll
	case getOrderSalesTabNew(page: Int)
	case getOrderSalesTabProcess(page: Int)
	case getOrderSalesTabShipping(page: Int)
	case getOrderSalesTabComplete(page: Int)
	case getOrderSalesTabCancel(page: Int)
	case getOrderPurchaseTabAll(page: Int)
	case getOrderPurchaseTabProcess(page: Int)
	case getOrderPurchaseTabWaiting(page: Int)
	case getOrderPurchaseTabShipping(page: Int)
	case getOrderPurchaseTabUnpaid(page: Int)
	case getOrderPurchaseTabComplete(page: Int)
	case getOrderPurchaseTabCancel(page: Int)
	case complaint
	case cancelSalesOrder
	case reasonDeclineOrder
	case processOrder(id: String, type: ProcessOrder)
	case orderDetail(id: String)
	case showBarcode(awbNumber: String)
	case getHistoryWithdrawal
	case orderProduct
    case completeOrder(id: String)
}

extension TransactionEndpoint: EndpointType {
	var baseUrl: URL {
		return URL(string: APIConstants.baseURL)!
	}
	
	var path: String {
		switch self {
		case .getOrderPurchaseTabAll:
			return "/orders/purchase/transaction/all"
		case .getOrderPurchaseTabProcess:
			return "/orders/purchase/transaction/process"
		case .getOrderPurchaseTabWaiting:
			return "/orders/purchase/transaction/waiting"
		case .getOrderPurchaseTabShipping:
			return "/orders/purchase/transaction/shipping"
		case .getOrderPurchaseTabUnpaid:
			return "/orders/purchase/transaction/unpaid"
		case .getOrderPurchaseTabComplete:
			return "/orders/purchase/transaction/complete"
		case .getOrderPurchaseTabCancel:
			return "/orders/purchase/transaction/cancel"
		case .getOrderSalesTabNew:
			return "/orders/sales/transaction/new"
		case .getOrderSalesTabProcess:
			return "/orders/sales/transaction/process"
		case .getOrderSalesTabShipping:
			return "/orders/sales/transaction/shipping"
		case .getOrderSalesTabComplete:
			return "/orders/sales/transaction/complete"
		case .getOrderSalesTabCancel:
			return "/orders/sales/transaction/cancel"
		case .getOrderSalesTabAll:
			return "/orders/sales/transaction/all"
		case .complaint:
			return "/orders/complaint"
		case .cancelSalesOrder:
			return "/reports"
		case .reasonDeclineOrder:
			return "/reports/reason/DECLINE_ORDER"
		case let .processOrder(id, type):
			return "/orders/\(id)/\(type.rawValue)"
		case .orderDetail(let id):
			return "/orders/\(id)"
		case .showBarcode(let awbNumber):
			return "/orders/barcode/\(awbNumber)"
		case .getHistoryWithdrawal:
			return "/balance/history"
		case .orderProduct:
			return "/orders"
        case .completeOrder(let id):
            return "/orders/\(id)/complete"
		}
	}
	
	var method: HTTPMethod {
		switch self {
        case .processOrder(_,_), .completeOrder(_):
			return .patch
		case .complaint, .cancelSalesOrder, .orderProduct:
			return .post
		default:
			return .get
		}
	}
	
	var header: [String : Any] {
		return [
			"Authorization" : "Bearer \(getToken() ?? "")",
			"Content-Type" : "application/json",
		]
	}
	
	var parameter: [String : Any] {
		switch self {
		case .processOrder, .showBarcode, .orderDetail, .orderProduct:
			return [:]
		case .getOrderSalesTabCancel(let page), .getOrderSalesTabComplete(let page), .getOrderSalesTabShipping(let page), .getOrderSalesTabProcess(let page), .getOrderSalesTabNew(let page),
				.getOrderPurchaseTabCancel(let page), .getOrderPurchaseTabAll(let page), .getOrderPurchaseTabUnpaid(let page), .getOrderPurchaseTabProcess(let page), .getOrderPurchaseTabWaiting(let page), .getOrderPurchaseTabComplete(let page), .getOrderPurchaseTabShipping(let page):
			return [
				"sort" : "createAt,desc",
				"page" : "\(page)"
			]
		default:
			return [ "sort" : "createAt,desc"]
		}
		
	}
}
