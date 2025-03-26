//
//  DetailTransactionRouter.swift
//  KipasKipas
//
//  Created by movan on 13/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import Combine
import KipasKipasShared

protocol DetailTransactionRouting {
	
	func routeTo(_ route: DetailTransactionModel.Route)
}

final class DetailTransactionRouter: Routeable {
	
	private weak var viewController: UIViewController?
	
	init(_ viewController: UIViewController?) {
		self.viewController = viewController
	}
}


// MARK: - DetailTransactionRouting
extension DetailTransactionRouter: DetailTransactionRouting {
	
	func routeTo(_ route: DetailTransactionModel.Route) {
		DispatchQueue.main.async {
			switch route {
				
			case .dismiss:
				self.dismiss()
			case .dismissWith(let action):
				self.dismissWith(action)
			case .detailSeller(let id):
				self.showProfile(id: id)
			case .trackingShipment(let id):
				self.trackingShipment(id)
			case .virtualAccount(let bankName, let bankNumber, let time):
				self.virtualAccount(bankName: bankName, bankNumber: bankNumber, time: time)
			case .browser(let id, let isDownloadAble):
				self.browser(id, isDownloadAble)
			case .complaint(id: let id):
				self.complaint(id)
			case .cancelSalesOrder(let id):
				self.cancelSalesOrder(id)
			case .product(let data):
				self.seeProduct(data)
			case .pengembalianDana(let nominal):
				self.pengembalianDana(nominal: nominal)
			case .checkMySaldo(let id):
				self.checkMySaldo(id)
            case .addReview(let orderId, let productName, let productPhotoUrl, let completion):
                self.addReview(orderId: orderId, productName: productName, productPhotoUrl: productPhotoUrl, completion: completion)
            }
		}
	}
}


// MARK: - Private Zone
private extension DetailTransactionRouter {
	
	func dismiss() {
		viewController?.tabBarController?.tabBar.isHidden = false
		viewController?.navigationController?.popViewController(animated: false)
	}
	
	func dismissWith(_ action: () -> Void) {
		action()
		viewController?.tabBarController?.tabBar.isHidden = false
		viewController?.navigationController?.popViewController(animated: false)
	}
	
	func showProfile(id: String) {
		let controller =  AnotherUserProfileViewController(mainView: AnotherUserProfileView(), dataSource: NewUserProfileModel.DataSource())
		controller.setProfile(id: id, type: "")
        controller.bindNavigationBar("", true)
        
        viewController?.navigationController?.pushViewController(controller, animated: true)
	}
	
	func trackingShipment(_ id: String) {
		var datasource = TrackingShipmentModel.DataSource()
		datasource.id = id
		datasource.data = nil
		let trackingController = TrackingShipmentController(mainView: TrackingShipmentView(), dataSource: datasource)

		viewController?.navigationController?.pushViewController(trackingController, animated: true)
	}
	
	func virtualAccount(bankName : String, bankNumber : String, time : Int) {
		var dataSource = VirtualAccountNumberModel.DataSource()
		dataSource.bankName = bankName
		dataSource.bankNumber = bankNumber
		dataSource.time = time
		let virtualAccountController = VirtualAccountNumberController(mainView: VirtualAccountNumberView(), dataSource: dataSource)
		
		
		viewController?.navigationController?.pushViewController(virtualAccountController, animated: true)
	}

    func browser(_ url: String, _ isDownloadAble: Bool) {
		let browserController = BrowserController(url: url, type: .general)
        browserController.isInvoice = isDownloadAble
		
		viewController?.navigationController?.pushViewController(browserController, animated: true)
	}
	
	func seeProduct(_ shop: Product) {
        let detailController = ProductDetailFactory.createProductDetailController(dataSource: shop, isPreview: false)
		
		detailController.hidesBottomBarWhenPushed = true
		viewController?.navigationController?.pushViewController(detailController, animated: true)
	}
	
	func complaint(_ id : String) {
		let dataSource = ComplaintModel.DataSource()
		dataSource.id = id
		let complaintController = ComplaintController(mainView: ComplaintView(), dataSource: dataSource)
		
		viewController?.navigationController?.pushViewController(complaintController, animated: true)
	}
	
	func cancelSalesOrder(_ id: String) {
		let dataSource = CancelSalesOrderModel.DataSource()
		dataSource.id = id
		let controller = CancelSalesOrderController(mainView: CancelSalesOrderView(), dataSource: dataSource)
		
		viewController?.navigationController?.pushViewController(controller, animated: true)
	}
    
    func pengembalianDana(nominal : Int) {
        let controller = ComplaintConfirmController()
        controller.fromRefund = true
        controller.nominal = nominal
        viewController?.navigationController?.pushViewController(controller, animated: true)
    }
	
	func checkMySaldo(_ id: String) {
        let storeController = MyProductFactory.createMyProductController()
		viewController?.navigationController?.pushViewController(storeController, animated: false)
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
