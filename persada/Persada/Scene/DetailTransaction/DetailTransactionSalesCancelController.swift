//
//  DetailTransactionSalesCancelController.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 10/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//


import UIKit


final class DetailTransactionSalesCancelController: UIViewController, Displayable, DetailTransactionDisplayLogic {
	
	private let mainView: DetailTransactionSalesCancelView
	private var interactor: DetailTransactionInteractable!
	private var router: DetailTransactionRouting!
	private let sections: [String] = [.get(.invoice) , .get(.pesanan), .get(.catatan), .get(.diKirimKe)]
	
	init(mainView: DetailTransactionSalesCancelView, dataSource: DetailTransactionModel.DataSource) {
		self.mainView = mainView
		
		super.init(nibName: nil, bundle: nil)
		interactor = DetailTransactionInteractor(viewController: self, dataSource: dataSource)
		router = DetailTransactionRouter(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		handleRefreshNotifications()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		bindNavigationBar(interactor.dataSource.title)
		tabBarController?.tabBar.isHidden = true
		navigationController?.hideKeyboardWhenTappedAround()
		navigationController?.navigationBar.backgroundColor = UIColor.white
		navigationController?.interactivePopGestureRecognizer?.isEnabled = true
		navigationController?.interactivePopGestureRecognizer?.delegate = self
		navigationController?.setNavigationBarHidden(false, animated: false)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		navigationController?.navigationBar.backgroundColor = nil
	}
	
	override func loadView() {
		view = mainView
		mainView.delegate = self
		mainView.tableView.backgroundColor = .white
		mainView.tableView.delegate = self
		mainView.tableView.dataSource = self
		mainView.refreshControl.addTarget(self, action: #selector(handleRefreshNotifications), for: .valueChanged)
		
		guard let terms = self.interactor.dataSource.termsCondition else {
			return
		}
		
		mainView.showHiddenPriceTerms(isHidden: terms.showPriceTerm, terms.title, terms.subtitle)
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
	}

	@objc func handleRefreshNotifications() {
		let id = interactor.dataSource.id ?? ""
		interactor.doRequest(.requestOrderDetail(id: id))
	}
	
	// MARK: - DetailTransactionSalesDisplayLogic
	func displayViewModel(_ viewModel: DetailTransactionModel.ViewModel) {
		DispatchQueue.main.async {
			switch viewModel {
				
			case .detail(let viewModel):
				self.displayDetailNotification(viewModel)
			case .processOrder(let viewModel):
				self.displayProcessOrder(viewModel)
			case .pickUp(let viewModel):
				self.displayPickUp(viewModel)
			case .barcode(let viewModel):
				self.displayBarcode(viewModel)
			case.trackingShipment(_):
				break
			case .productById(let viewModel):
				self.router.routeTo(.product(data: viewModel.data!))
			case .completeOrder(_):
				break
			}
		}
	}
}


// MARK: - DetailTransactionSalesViewDelegate
extension DetailTransactionSalesCancelController: DetailTransactionSalesCancelViewDelegate, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate {
	
	func hideDialog() {
		mainView.sendSubviewToBack(mainView.barcodeView)
		mainView.viewBackground.isHidden = true
		mainView.barcodeView.isHidden = true
		mainView.viewBackground.alpha = 0.0
		mainView.barcodeView.alpha = 0.0
	}
	
	func showDialog() {
		mainView.bringSubviewToFront(mainView.barcodeView)
		
		guard let validData = self.interactor.dataSource.dataImage, let awbNumber = interactor.dataSource.data?.orderShipment?.awbNumber else {
			return
		}
		
		mainView.setup(validData, awbNumber)
		mainView.viewBackground.isHidden = false
		mainView.barcodeView.isHidden = false
		mainView.viewBackground.alpha = 0.75
		mainView.barcodeView.alpha = 1.0
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		self.sections.count
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
			return self.sections[section]
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let width = UIScreen.main.bounds.width
		
		let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: Int(width), height: 20))
			returnedView.backgroundColor = .white

		let label = UILabel(frame: .zero)
		label.font = UIFont.Roboto(.bold, size: 13)
		label.text = self.sections[section]
		label.textColor = .black
		returnedView.addSubview(label)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.anchor(top: returnedView.topAnchor, left: returnedView.safeAreaLayoutGuide.leftAnchor, bottom: returnedView.bottomAnchor, right: returnedView.safeAreaLayoutGuide.rightAnchor, paddingLeft: 16, paddingRight: 16)

		return returnedView
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let section = indexPath.section

		guard let item = self.interactor.dataSource.data, let itemTransaction = self.interactor.dataSource.dataTransaction else {
			let cell = UITableViewCell()
			cell.backgroundColor = .white
			return cell
		}
		
		switch section {
		case 1:
			let cell = tableView.dequeueReusableCustomCell(with: DetailTransactionHeaderItemCell.self, indexPath: indexPath)
			
			cell.configure(
				imageURL: item.orderDetail?.urlProductPhoto ?? "",
				title: item.orderDetail?.productName ?? "" ,
				price: String(item.orderDetail?.productPrice ?? 0).toMoney(),
				quantity: String(item.orderDetail?.quantity ?? 0))
			
			return cell
		case 0, 2, 3:
			let cell = tableView.dequeueReusableCustomCell(with: AreasItemCell.self, indexPath: indexPath)
			
            let address = "\(item.orderShipment?.destinationReceiverName ?? "") - \(item.orderShipment?.destinationPhoneNumber ?? "")\n\(item.orderShipment?.destinationLabel ?? ""), \(item.orderShipment?.destinationDetail ?? ""), \(item.orderShipment?.destinationSubDistrict ?? ""), \(item.orderShipment?.destinationCity ?? ""), \(item.orderShipment?.destinationProvince ?? ""), \(item.orderShipment?.destinationPostalCode ?? "")"
			let noInvoice = itemTransaction.noInvoice
			let note = item.orderShipment?.notes ?? ""
			
			cell.nameLabel.textColor = .contentGrey
			if section == 0 {
				cell.item = noInvoice
			} else if (section == 2) {
				cell.item = note
			} else {
				cell.item = address
                cell.nameLabel.setLineSpacing(lineSpacing: 2)
			}

			return cell
		default:
			return UITableViewCell()
		}
	}
	
}


// MARK: - Private Zone
private extension DetailTransactionSalesCancelController {
	
	func displayDetailNotification(_ viewModel: TransactionProduct) {
		self.interactor.dataSource.data = viewModel
		mainView.tableView.refreshControl?.endRefreshing()
		mainView.tableView.reloadData()
	}
	
	func displayProcessOrder(_ viewModel: DefaultResponse) {
		self.router.routeTo(.dismiss)
	}
	
	func displayPickUp(_ viewModel: RequestPickUpResponse) {
		self.router.routeTo(.dismiss)
	}
	
	func displayBarcode(_ viewModel: Data) {
		self.interactor.dataSource.dataImage = viewModel
		self.showDialog()
	}
}
