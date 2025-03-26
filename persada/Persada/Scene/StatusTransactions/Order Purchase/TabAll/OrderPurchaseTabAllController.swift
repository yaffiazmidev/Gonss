//
//  OrderPurchaseTabButtonController.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 04/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import Combine

protocol OrderPurchaseTabAllDisplayLogic where Self: UIViewController {

	func displayViewModel(_ viewModel: OrderPurchaseTabAllModel.ViewModel)
}

final class OrderPurchaseTabAllController: UIViewController, OrderPurchaseTabAllDisplayLogic, UITableViewDelegate, UITableViewDataSource {
	
	let mainView: OrderPurchaseTabAllView
	var interactor: OrderPurchaseTabAllInteractable!
	private var router: OrderPurchaseTabAllRouting!
	private var endpoint: OrderPurchaseTabAllModel.Request!
	
    var refreshControl = UIRefreshControl()
	private var page: Int = 0
	private var lastPage: Int = 0
    
	init(mainView: OrderPurchaseTabAllView, dataSource: OrderPurchaseTabAllModel.DataSource, endpoint: OrderPurchaseTabAllModel.Request) {
		self.mainView = mainView
		self.endpoint = endpoint
		super.init(nibName: nil, bundle: nil)
		interactor = OrderPurchaseTabAllInteractor(viewController: self, dataSource: dataSource)
		router = OrderPurchaseTabAllRouter(self)
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            self.interactor.doRequest(self.endpoint)
//        }
    }
	
	override func viewDidLoad() {
		super.viewDidLoad()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)

        mainView.tableView.addSubview(refreshControl)
        refresh()
	}
    
    @objc
    func refresh(){
			page = 0
			lastPage = 0
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
				
			case let .orderPurchase(viewModel, lastPage):
				self.displayOrderPurchaseTabAll(viewModel, lastPage)
            case .completeOrder:
				self.completedOrder()
			}
		}
	}
	
	func displayOrderPurchaseTabAll(_ viewModel: [OrderCellViewModel], _ lastPage: Int) {
		if page == 0 {
			interactor.dataSource.data = viewModel
		} else {
			interactor.dataSource.data = interactor.dataSource.data + viewModel
		}
		self.lastPage = lastPage
		
		mainView.emptyView.isHidden = !interactor.dataSource.data.isEmpty
		mainView.tableView.reloadData()
		refreshControl.endRefreshing()
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return interactor.dataSource.data.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "OrderTransactionPurchaseWithButtonCell", for: indexPath) as! OrderTransactionPurchaseWithButtonCell
		let object = interactor.dataSource.data[indexPath.row]

		if object.orderStatus == "NEW" && object.paymentStatus == "WAIT" && object.shipmentStatus == "" {
			cell.setUpCell(item: object, buttonText: "Bayar Sekarang")
		} else if ( object.orderStatus == "PROCESS" && object.paymentStatus == "PAID" && object.shipmentStatus == "DELIVERED") {
			cell.setUpCell(item: object, buttonText: "Konfirmasi Pesanan")
		} else if object.orderStatus == "COMPLETE" && object.paymentStatus == "SETTLED" && object.shipmentStatus == "DELIVERED" && object.reviewStatus == "WAIT" {
            cell.setUpCell(item: object, buttonText: .get(.addReview))
        }else if object.orderStatus == "COMPLETE" && object.paymentStatus == "SETTLED" && object.shipmentStatus == "DELIVERED" && object.reviewStatus == "COMPLETE" {
            cell.setUpCell(item: object, buttonText: .get(.hasReview))
        } else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "OrderTransactionPurchaseWithoutButtonCell", for: indexPath) as! OrderTransactionPurchaseWithoutButtonCell
			cell.setUpCell(item: object, buttonText: "")
			cell.handleTransaction = { [weak self] (_,_,_) in
				if object.orderStatus == "NEW" && object.paymentStatus == "WAIT" && object.shipmentStatus == "" {
                    self?.router.routeTo(.virtualAccount(bankName: object.virtualAccount?.bank ?? "", bankNumber: object.virtualAccount?.vaNumber ?? "", time: object.expireTimePayment))
				} else if ( object.orderStatus == "PROCESS" && object.paymentStatus == "PAID" && object.shipmentStatus == "DELIVERED") {
                    self?.showDialog(id: object.id)
				} 
			}
			return cell
		}
		
		cell.handleTransaction = { [weak self] (_,_,_) in
			if object.orderStatus == "NEW" && object.paymentStatus == "WAIT" && object.shipmentStatus == "" {
                if let vaNumber = object.virtualAccount?.vaNumber {
                    self?.router.routeTo(.virtualAccount(bankName: object.virtualAccount?.bank ?? "", bankNumber: vaNumber, time: object.expireTimePayment))
                } else {
                    self?.router.routeTo(.browser(url: object.urlPaymentPage))
                }
            }else if object.orderStatus == "COMPLETE" && object.paymentStatus == "SETTLED" && object.shipmentStatus == "DELIVERED" && object.reviewStatus == "WAIT" {
                self?.router.routeTo(.addReview(orderId: object.id, productName: object.productName, productPhotoUrl: object.urlProductPhoto){
                    self?.refresh()
                })
            } else if ( object.orderStatus == "PROCESS" && object.paymentStatus == "PAID" && object.shipmentStatus == "DELIVERED") {
                self?.showDialog(id: object.id)
			}
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
			if endpoint == .getOrderPurchaseTabAll(page: 0) && page <= lastPage - 1 {
				page = page + 1
				interactor.doRequest(.getOrderPurchaseTabAll(page: page))
				return
			} else if endpoint == .getOrderPurchaseTabProcess(page: 0) && page <= lastPage - 1 {
				page = page + 1
				interactor.doRequest(.getOrderPurchaseTabProcess(page: page))
				return
			} else if endpoint == .getOrderPurchaseTabWaiting(page: 0) && page <= lastPage - 1 {
				page = page + 1
				interactor.doRequest(.getOrderPurchaseTabWaiting(page: page))
				return
			} else if endpoint == .getOrderPurchaseTabComplete(page: 0) && page <= lastPage - 1 {
				page = page + 1
				interactor.doRequest(.getOrderPurchaseTabComplete(page: page))
				return
			} else if endpoint == .getOrderPurchaseTabUnpaid(page: 0) && page <= lastPage - 1 {
				page = page + 1
				interactor.doRequest(.getOrderPurchaseTabUnpaid(page: page))
				return
			} else if endpoint == .getOrderPurchaseTabShipping(page: 0) && page <= lastPage - 1 {
				page = page + 1
				interactor.doRequest(.getOrderPurchaseTabShipping(page: page))
				return
			} else if endpoint == .getOrderPurchaseTabCancel(page: 0) && page <= lastPage - 1 {
				page = page + 1
				interactor.doRequest(.getOrderPurchaseTabCancel(page: page))
				return
			}
		}
	}
	
	func showDialog(id: String){
		let dialog = ConfirmOrderDialogView.loadViewFromNib()
        dialog.frame = UIScreen.main.bounds
		
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            window.addSubview(dialog)
        } else {
            self.view.addSubview(dialog)
        }
		
		dialog.handleCancel = {
            self.dismissDialog(dialog: dialog)
		}
		
		dialog.handleDone = {
			self.interactor.doRequest(.completeOrder(id: id))
			self.dismissDialog(dialog: dialog)
		}
	}
	
	func dismissDialog(dialog : ConfirmOrderDialogView){
		dialog.removeFromSuperview()
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let object = interactor.dataSource.data[indexPath.row]

		self.router.routeTo(.detailTransaction(data: object))
	}
	
	func completedOrder(){
		self.showToast(message: .get(.orderComplete))
		self.interactor.doRequest(self.endpoint)
		self.refresh()
		
		guard let controllers = self.navigationController?.viewControllers else { return }
		
		for item in controllers {
			if let statusController = item as? StatusTransactionController {
				for itemController in statusController.viewControllerList {
					if let orderController = itemController as? OrderPurchaseController {
						orderController.swipeMenuView.jump(to: 4, animated: true)
						if let controller = orderController.viewControllers[4] as? OrderPurchaseTabAllController {
							controller.refresh()
						}
					}
				}
			}
		}
	}
}
