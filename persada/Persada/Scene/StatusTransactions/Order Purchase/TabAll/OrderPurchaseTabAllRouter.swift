//
//  OrderPurchaseTabAllRouter.swift
//  KipasKipas
//
//  Created by NOOR on 26/01/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import UIKit
import KipasKipasShared

protocol OrderPurchaseTabAllRouting {
	
	func routeTo(_ route: OrderPurchaseTabAllModel.Route)
}

final class OrderPurchaseTabAllRouter: Routeable {
	
	private weak var viewController: UIViewController?
	
	init(_ viewController: UIViewController?) {
		self.viewController = viewController
	}
}


// MARK: - OrderPurchaseTabAllRouting
extension OrderPurchaseTabAllRouter: OrderPurchaseTabAllRouting {
	
	func routeTo(_ route: OrderPurchaseTabAllModel.Route) {
		DispatchQueue.main.async {
			switch route {
			
			case .dismiss:
				self.dismiss()
			case .detailTransaction(let data):
				self.detailTransaction(data)
			case .browser(let url):
				self.browser(url)
			case .trackingShipment(let id):
				self.trackingShipment(id)
            case .virtualAccount(let bankName, let bankNumber, let time):
                self.virtualAccount(bankName: bankName, bankNumber: bankNumber, time: time)
            case .addReview(let orderId, let productName, let productPhotoUrl, let completion):
                self.addReview(orderId: orderId, productName: productName, productPhotoUrl: productPhotoUrl, completion: completion)
            }
		}
	}
}


// MARK: - Private Zone
private extension OrderPurchaseTabAllRouter {
	
	func dismiss() {
		viewController?.dismiss(animated: true)
	}
	
	func detailTransaction(_ data: OrderCellViewModel) {
		var dataSource = DetailTransactionModel.DataSource()
		dataSource.id = data.id
		dataSource.data = nil
		dataSource.dataTransaction = data
		let detailController = DetailTransactionPurchaseController(mainView: DetailTransactionPurchaseView.loadViewFromNib(), dataSource: dataSource)
		
		viewController?.navigationController?.pushViewController(detailController, animated: true)
	}
	
	func trackingShipment(_ id: String) {
		var datasource = TrackingShipmentModel.DataSource()
		datasource.id = id
		datasource.data = nil
		let trackingController = TrackingShipmentController(mainView: TrackingShipmentView(), dataSource: datasource)

		viewController?.navigationController?.pushViewController(trackingController, animated: false)
	}
	
	func browser(_ url: String) {
		let browserController = BrowserController(url: url, type: .general)
		
		viewController?.navigationController?.pushViewController(browserController, animated: false)
	}
    
    func virtualAccount(bankName : String, bankNumber : String, time : Int) {
        var dataSource = VirtualAccountNumberModel.DataSource()
        dataSource.bankName = bankName
        dataSource.bankNumber = bankNumber
        dataSource.time = time
        let virtualAccountController = VirtualAccountNumberController(mainView: VirtualAccountNumberView(), dataSource: dataSource)
        
        
        viewController?.navigationController?.pushViewController(virtualAccountController, animated: true)
    }
    
    func addReview(orderId: String, productName: String, productPhotoUrl: String, completion: (() -> Void)? = nil){
        let view = ReviewAddView()
        let vc = ReviewAddController(orderId: orderId, productName: productName, productPhotoUrl: productPhotoUrl, view: view)
       
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .overFullScreen
        nav.navigationBar.isHidden  = true
        viewController?.present(nav, animated: false)
        vc.onReviewCreated = completion
    }
}
