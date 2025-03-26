//
//  DetailTransactionPurchaseController.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 05/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

final class DetailTransactionPurchaseController : UIViewController, Displayable, DetailTransactionDisplayLogic, UIGestureRecognizerDelegate {
	
	private let mainView: DetailTransactionPurchaseView
	private var interactor: DetailTransactionInteractable!
	private var router: DetailTransactionRouting!
	
	init(mainView: DetailTransactionPurchaseView, dataSource: DetailTransactionModel.DataSource) {
        self.mainView = mainView
		
		super.init(nibName: nil, bundle: nil)
		interactor = DetailTransactionInteractor(viewController: self, dataSource: dataSource)
		router = DetailTransactionRouter(self)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let id = interactor.dataSource.id ?? ""
		interactor.doRequest(.requestOrderDetail(id: id))
		interactor.doRequest(.fetchTrackingShipment(id: id))
	}
	
	override func loadView() {
		view = mainView
		mainView.initView()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		bindNavigationBar(.get(.detailTransaction))
		tabBarController?.tabBar.isHidden = true
		navigationController?.hideKeyboardWhenTappedAround()
		navigationController?.navigationBar.backgroundColor = UIColor.white
		navigationController?.interactivePopGestureRecognizer?.isEnabled = true
		navigationController?.interactivePopGestureRecognizer?.delegate = self
		navigationController?.setNavigationBarHidden(false, animated: false)
	}
	
	func displayViewModel(_ viewModel: DetailTransactionModel.ViewModel) {
		DispatchQueue.main.async {
			switch viewModel {
			
			case .detail(let viewModel):
				self.displayDetailNotification(viewModel)
			case .processOrder(let viewModel):
				self.displayCompletePurchase(viewModel)
			case.trackingShipment(let viewModel):
				self.displayTracking(viewModel)
			case .pickUp(_), .barcode(_):
				break
            case .productById(let viewModel):
                self.router.routeTo(.product(data: viewModel.data!))
            case .completeOrder(_):
                self.showToast(message: .get(.orderComplete))
                let id = self.interactor.dataSource.id ?? ""
                self.interactor.doRequest(.requestOrderDetail(id: id))
			}
		}
	}
	
	func displayDetailNotification(_ viewModel: TransactionProduct) {
		self.interactor.dataSource.data = viewModel
		if let itemTransaction = self.interactor.dataSource.data {
            mainView.setButton(orderStatus: itemTransaction.status ?? "", paymentStatus: itemTransaction.payment?.status ?? "", shipmentStatus: itemTransaction.orderShipment?.status ?? "", reviewStatus: itemTransaction.reviewStatus ?? "WAIT")
        }
        mainView.setupView(product: viewModel)
        buttonHandler()
	}
	
	func displayCompletePurchase(_ viewModel: DefaultResponse) {
		
	}
	
	func displayTracking(_ viewModel : TrackingShipmentResult){
		let item =  viewModel.data?.first?.historyTracking ?? []
		let date = item.first?.shipmentDate ?? 0
		let notes = item.first?.notes ?? ""
		mainView.setupShipmentStatus(date: date, status: notes)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		navigationController?.navigationBar.backgroundColor = nil
	}
	
	func buttonHandler() {
		mainView.handlerShipmentTap = {
			self.router.routeTo(.trackingShipment(id: self.interactor.dataSource.id ?? ""))
            
		}
		
        guard let itemTransaction = self.interactor.dataSource.data else {
			return
		}
		mainView.handler = {
			
            switch (itemTransaction.status ?? "", itemTransaction.payment?.status ?? "", itemTransaction.orderShipment?.status ?? "", itemTransaction.reviewStatus ?? "WAIT") {
			case ("NEW", "WAIT", "", "WAIT"):
                if let vaNumber = itemTransaction.payment?.paymentAccount?.number {
                    self.router.routeTo(.virtualAccount(bankName: itemTransaction.payment?.paymentAccount?.name ?? "", bankNumber: vaNumber, time: itemTransaction.orderDetail?.expireTimePayment ?? 0))
                } else {
                    self.router.routeTo(.browser(url: itemTransaction.orderDetail?.urlPaymentPage ?? "", isDownloadAble: false))
                }
			case ("NEW", "PAID", "", "WAIT"):
				self.router.routeTo(.trackingShipment(id: itemTransaction.id ?? ""))
			case ("PROCESS", "PAID", "PACKAGING", "WAIT"):
				self.router.routeTo(.trackingShipment(id: itemTransaction.id ?? ""))
			case ("PROCESS", "PAID", "SHIPPING", "WAIT"):
				self.router.routeTo(.trackingShipment(id: itemTransaction.id ?? ""))
			case ("PROCESS", "PAID", "DELIVERED", "WAIT"):
                self.showDialog(id: itemTransaction.id ?? "")
            case ("COMPLETE", "SETTLED", "DELIVERED", "WAIT"):
                self.router.routeTo(.addReview(orderId: itemTransaction.id ?? "", productName: itemTransaction.orderDetail?.productName ?? "", productPhotoUrl: itemTransaction.orderDetail?.urlProductPhoto ?? ""){
                    let id = self.interactor.dataSource.id ?? ""
                    self.interactor.doRequest(.requestOrderDetail(id: id))
                })
            case ("CANCELLED", "RETURN", "", "WAIT"):
                self.router.routeTo(.pengembalianDana(nominal : itemTransaction.amount ?? 0))
			default:
				break
			}
		}
		
		mainView.secondaryHandler = {
			switch (itemTransaction.status ?? "", itemTransaction.payment?.status ?? "", itemTransaction.orderShipment?.status ?? "") {
			case ("PROCESS", "PAID", "DELIVERED"):
				self.router.routeTo(.complaint(id: itemTransaction.id ?? ""))
			default:
                self.interactor.doRequest(.productById(id: itemTransaction.orderDetail?.productId ?? ""))
			}
		}
		
		mainView.handlerButtonLihat = {
			guard let invoiceURL = self.interactor.dataSource.data?.invoiceFileUrl else {
				return
			}
			self.router.routeTo(.browser(url: invoiceURL, isDownloadAble: true))
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
}
