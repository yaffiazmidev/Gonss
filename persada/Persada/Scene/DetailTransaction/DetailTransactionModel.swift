//
//  DetailTransactionModel.swift
//  KipasKipas
//
//  Created by movan on 13/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation

enum DetailTransactionModel {
	
	enum Request {
		case requestOrderDetail(id: String)
		case processOrder(id: String, type: ProcessOrder)
		case requestPickUP(service: String, id: String)
		case showBarcode(id: String)
		case fetchTrackingShipment(id: String)
        case productById(id: String)
        case completeOrder(id: String)
	}
	
	enum Response {
		case products(result: TransactionProductResult)
		case processOrder(result: DefaultResponse)
		case pickUp(result: RequestPickUpResponse)
		case barcode(result: Data)
		case trackingShipment(result: TrackingShipmentResult)
        case productById(result: ProductDetailResult)
        case completeOrder(result: DefaultResponse)
	}
	
	enum ViewModel {
		case detail(viewModel: TransactionProduct)
		case processOrder(viewModel: DefaultResponse)
		case pickUp(viewModel: RequestPickUpResponse)
		case barcode(viewModel: Data)
		case trackingShipment(viewModel: TrackingShipmentResult)
        case productById(viewModel: ProductDetailResult)
        case completeOrder(viewModel: DefaultResponse)
	}
	
	enum Route {
		case detailSeller(id: String)
		case trackingShipment(id: String)
		case dismiss
		case dismissWith(action: () -> Void)
		case virtualAccount(bankName : String, bankNumber : String, time : Int)
        case browser(url: String, isDownloadAble: Bool)
		case complaint(id: String)
		case cancelSalesOrder(id: String)
		case product(data: Product)
        case pengembalianDana(nominal : Int)
        case checkMySaldo(id: String)
        case addReview(orderId: String, productName: String, productPhotoUrl: String, completion: (() -> Void)?)
	}
	
	struct DataSource: DataSourceable {
		var id: String?
		var dataImage: Data?
		var data: TransactionProduct?
		var dataTransaction: OrderCellViewModel?
		var termsCondition: ProcessTermsCondition?
		var title: String?
        var statusTuple: (String, String, String)?
	}
}

struct ProcessTermsCondition {
	var title: String = ""
	var subtitle: String = ""
	var showPriceTerm: Bool = false
}

public enum ProcessOrder: String {
	case process
	case complete
}
