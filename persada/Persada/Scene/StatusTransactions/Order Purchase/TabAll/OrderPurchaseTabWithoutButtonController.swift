//
//  OrderPurchaseTabWithoutButtonController.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 04/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import Combine

final class OrderPurchaseTabWithoutButtonController: UIViewController, OrderPurchaseTabAllDisplayLogic, UITableViewDelegate, UITableViewDataSource {
	
	private let mainView: OrderPurchaseTabWithoutButtonView
	private var interactor: OrderPurchaseTabAllInteractable!
	private var router: OrderPurchaseTabAllRouting!
	private var endpoint: OrderPurchaseTabAllModel.Request!
	
	init(mainView: OrderPurchaseTabWithoutButtonView, dataSource: OrderPurchaseTabAllModel.DataSource, endpoint: OrderPurchaseTabAllModel.Request) {
		self.mainView = mainView
		self.endpoint = endpoint
		super.init(nibName: nil, bundle: nil)
		interactor = OrderPurchaseTabAllInteractor(viewController: self, dataSource: dataSource)
		router = OrderPurchaseTabAllRouter(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		interactor.doRequest(self.endpoint)
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
	}
	
	override func loadView() {
		view = mainView
		mainView.tableView.delegate = self
		mainView.tableView.dataSource = self
	}
	
	func displayViewModel(_ viewModel: OrderPurchaseTabAllModel.ViewModel) {
		DispatchQueue.main.async {
			switch viewModel {
				
			case .orderPurchase(let viewModel):
				self.displayOrderPurchaseTabAll(viewModel)
			}
		}
	}
	
	func displayOrderPurchaseTabAll(_ viewModel: [OrderCellViewModel]) {
		self.interactor.dataSource.data = viewModel
		mainView.tableView.reloadData()
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return interactor.dataSource.data.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: String.get(.cellID), for: indexPath) as! OrderTransactionWithoutButtonCell
		let object = interactor.dataSource.data[indexPath.row]
		
		if object.orderStatus == "NEW" && object.paymentStatus == "WAIT" && object.shipmentStatus == "" {
			cell.setUpCell(item: object, buttonText: "Bayar Sekarang")
		} else if ( object.orderStatus == "PROCESS" && object.paymentStatus == "PAID" && object.shipmentStatus == "DELIVERED") {
			cell.setUpCell(item: object, buttonText: "Konfirmasi Pesanan")
		} else {
			cell.setUpCell(item: object, buttonText: "")
		}
		
		if endpoint == OrderPurchaseTabAllModel.Request.getOrderPurchaseTabCancel {
			cell.statusLabel.textColor = .redError
		}
		
		cell.handleTransaction = { [weak self] (_,_,_) in
			if object.orderStatus == "NEW" && object.paymentStatus == "WAIT" && object.shipmentStatus == "" {
				self?.router.routeTo(.browser(url: object.urlPaymentPage))
			} else if ( object.orderStatus == "PROCESS" && object.paymentStatus == "PAID" && object.shipmentStatus == "DELIVERED") {
				print("Konfirmasi Pesanan") // should show dialog but ...
			} else { }
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let object = interactor.dataSource.data[indexPath.row]

		self.router.routeTo(.detailTransaction(data: object))
	}
}
