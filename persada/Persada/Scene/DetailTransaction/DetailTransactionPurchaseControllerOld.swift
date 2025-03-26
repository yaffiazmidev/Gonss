//
//  DetailNotificationTransactionController.swift
//  KipasKipas
//
//  Created by movan on 13/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

//import UIKit
//import SkeletonView
//
//final class DetailTransactionPurchaseControllerOld: UIViewController, Displayable, DetailTransactionDisplayLogic {
//
//	private let mainView: DetailTransactionPurchaseView
//	private var interactor: DetailTransactionInteractable!
//	private var router: DetailTransactionRouting!
//	private let sections: [String] = ["Pesanan", "Shop", "Catatan", "Dikirim Ke", "Durasi Pengiriman", "Status Pengiriman", "Metode Pembayaran" , "", ""]
//
//	init(mainView: DetailTransactionPurchaseView, dataSource: DetailTransactionModel.DataSource) {
//		self.mainView = mainView
//
//		super.init(nibName: nil, bundle: nil)
//		interactor = DetailTransactionInteractor(viewController: self, dataSource: dataSource)
//		router = DetailTransactionRouter(self)
//	}
//
//	override func viewDidLoad() {
//		super.viewDidLoad()
//
//		handleRefreshNotifications()
//	}
//
//	override func viewWillAppear(_ animated: Bool) {
//		super.viewWillAppear(animated)
//
//		bindNavigationBar(.get(.detailTransaction))
//		tabBarController?.tabBar.isHidden = true
//		navigationController?.hideKeyboardWhenTappedAround()
//		navigationController?.navigationBar.backgroundColor = UIColor.white
//		navigationController?.interactivePopGestureRecognizer?.isEnabled = true
//		navigationController?.interactivePopGestureRecognizer?.delegate = self
//		navigationController?.setNavigationBarHidden(false, animated: false)
//	}
//
//	override func viewWillDisappear(_ animated: Bool) {
//		super.viewWillDisappear(animated)
//
//		navigationController?.navigationBar.backgroundColor = nil
//	}
//
//	override func loadView() {
//		view = mainView
//		mainView.delegate = self
//		mainView.tableView.backgroundColor = .white
//		mainView.tableView.delegate = self
//		mainView.tableView.dataSource = self
//		mainView.refreshControl.addTarget(self, action: #selector(handleRefreshNotifications), for: .valueChanged)
//	}
//
//	@available(*, unavailable)
//	required init?(coder: NSCoder) {
//		fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
//	}
//
//	@objc func handleRefreshNotifications() {
//		let id = interactor.dataSource.id ?? ""
//		interactor.doRequest(.requestOrderDetail(id: id))
//	}
//
//	// MARK: - DetailNotificationTransactionDisplayLogic
//	func displayViewModel(_ viewModel: DetailTransactionModel.ViewModel) {
//		DispatchQueue.main.async {
//			switch viewModel {
//
//			case .detail(let viewModel):
//				self.displayDetailNotification(viewModel)
//			case .processOrder(let viewModel):
//				self.displayCompletePurchase(viewModel)
//			case .pickUp(_), .barcode(_):
//				break
//			}
//		}
//	}
//}
//
//
//// MARK: - DetailTransactionPurchaseViewDelegate
//extension DetailTransactionPurchaseControllerOld: UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate, DetailTransactionPurchaseViewDelegate {
//
//	func hideDialog() {
//		mainView.sendSubviewToBack(mainView.viewDialogPopup)
//		mainView.viewPopupBackground.isHidden = true
//		mainView.viewDialogPopup.isHidden = true
//		mainView.viewPopupBackground.alpha = 0.0
//		mainView.viewDialogPopup.alpha = 0.0
//	}
//
//	func showDialog() {
//		mainView.bringSubviewToFront(mainView.viewDialogPopup)
//		mainView.viewPopupBackground.isHidden = false
//		mainView.viewDialogPopup.isHidden = false
//		mainView.viewPopupBackground.alpha = 0.75
//		mainView.viewDialogPopup.alpha = 1.0
//	}
//
//	func whenHandleConfirmation() {
//		let validId = interactor.dataSource.dataTransaction?.id ?? ""
//		interactor.doRequest(.processOrder(id: validId, type: .complete))
//	}
//
//	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		return 1
//	}
//
//	func numberOfSections(in tableView: UITableView) -> Int {
//		self.sections.count
//	}
//
//	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//			return self.sections[section]
//	}
//
//	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//		let width = UIScreen.main.bounds.width
//		var height = 0
//		switch section {
//		case 7, 8:
//			height = 0
//		default:
//			height = 20
//		}
//
//		let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: Int(width), height: height))
//			returnedView.backgroundColor = .white
//
//		let label = UILabel(frame: .zero)
//		label.font = UIFont.AirBnbCereal(.book, size: 13)
//		label.text = self.sections[section]
//		label.textColor = .black
//		returnedView.addSubview(label)
//		label.translatesAutoresizingMaskIntoConstraints = false
//		label.anchor(top: returnedView.topAnchor, left: returnedView.safeAreaLayoutGuide.leftAnchor, bottom: returnedView.bottomAnchor, right: returnedView.safeAreaLayoutGuide.rightAnchor, paddingLeft: 16, paddingRight: 16)
//
//		return returnedView
//	}
//
//	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//		switch section {
//		case 7, 8:
//			return 0
//		default:
//			return 20
//		}
//	}
//
//	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//		let section = indexPath.section
//
//		guard let item = self.interactor.dataSource.data else {
//			let cell = UITableViewCell()
//			cell.backgroundColor = .white
//			return cell
//		}
//
//
//
//		switch section {
//		case 0:
//			let cell = tableView.dequeueReusableCustomCell(with: DetailTransactionHeaderItemCell.self, indexPath: indexPath)
//			cell.selectionStyle = .none
//			cell.backgroundColor = .white
//
//			cell.configure(
//				imageURL: item.orderDetail?.urlProductPhoto ?? "",
//				title: item.orderDetail?.productName ?? "" ,
//				price: String(item.orderDetail?.productPrice?.toMoney() ?? ""),
//				quantity: String(item.orderDetail?.quantity ?? 0))
//
//			return cell
//		case 1:
//			let cell = tableView.dequeueReusableCustomCell(with: DetailItemUsernameTableViewCell.self, indexPath: indexPath)
//
//			cell.selectionStyle = .none
//			cell.backgroundColor = .white
//
//			guard let name = item.orderDetail?.sellerName, let id = item.orderDetail?.sellerAccountId else {
//				return cell
//			}
//			cell.configure(name, true)
//
//			cell.handler = {
//				self.router.routeTo(.detailSeller(id: id))
//			}
//
//			return cell
//		case 2:
//			let cell = tableView.dequeueReusableCustomCell(with: AreasItemCell.self, indexPath: indexPath)
//			cell.selectionStyle = .none
//			cell.backgroundColor = .white
//
//			cell.item = item.orderShipment?.notes ?? ""
//
//			return cell
//
//		case 3:
//			let cell = tableView.dequeueReusableCustomCell(with: AreasItemCell.self, indexPath: indexPath)
//			cell.selectionStyle = .none
//			cell.backgroundColor = .white
//
//			let address = "\(item.orderShipment?.destinationLabel ?? ""), \(item.orderShipment?.destinationDetail ?? ""), Kecamatan \(item.orderShipment?.destinationSubDistrict ?? ""), Kota \(item.orderShipment?.destinationCity ?? ""), Provinsi \(item.orderShipment?.destinationProvince ?? ""), KODE POS: \(item.orderShipment?.destinationPostalCode ?? "")"
//			cell.item = address
//
//			return cell
//		case 4:
//			let cell = tableView.dequeueReusableCustomCell(with: DetailLabelTappedItemCell.self, indexPath: indexPath)
//			cell.selectionStyle = .none
//			cell.backgroundColor = .white
//
//			let courier = item.orderShipment?.courier ?? ""
//			let duration = "\(item.orderShipment?.duration ?? "") hari kerja"
//			let cost = String("Rp \(item.orderShipment?.cost ?? 0)")
//			cell.customLabel.configure(texts: [courier,duration, "", cost], colors: [.black, .black, .black, .black])
//
//			return cell
//		case 5:
//			let cell = tableView.dequeueReusableCustomCell(with: DetailLabelTappedItemCell.self, indexPath: indexPath)
//			cell.selectionStyle = .none
//			cell.backgroundColor = .white
//
//			let time = Date(timeIntervalSince1970: TimeInterval((item.orderDetail?.createAt ?? 1000)/1000 )).timeAgoDisplay()
//
//			cell.customLabel.configure(texts: ["Pesanan Dibatalkan", "Pesanan kamu telah dibatalkan oleh penjual", time, ">"], colors: [.black, .black, .secondary, .black])
//			cell.handler = { [weak self] in
//				guard let self = self else { return }
//				if let itemTransaction = self.interactor.dataSource.dataTransaction {
//					self.router.routeTo(.trackingShipment(id: itemTransaction.id))
//				}
//			}
//
//			return cell
//		case 6:
//			let cell = tableView.dequeueReusableCustomCell(with: DetailImageTappedItemCell.self, indexPath: indexPath)
//			cell.selectionStyle = .none
//			cell.backgroundColor = .white
//
//			cell.customLabel.configure(texts: "", colors: .black, imageURL: "", type: item.type ?? "")
//
//			return cell
//		case 7:
//			let cell = tableView.dequeueReusableCustomCell(with: DetailTotalTableViewCell.self, indexPath: indexPath)
//			cell.selectionStyle = .none
//			cell.backgroundColor = .white
//
//			guard let quantity = item.orderDetail?.quantity, let price = item.orderDetail?.productPrice, let cost = item.orderShipment?.cost, let total = item.amount else {
//				return cell
//			}
//
//			cell.configure(quantity, price, cost, total)
//
//			return cell
//		case 8:
//			let cell = tableView.dequeueReusableCustomCell(with: DetailTransactionButtonItemCell.self, indexPath: indexPath)
//
//			cell.selectionStyle = .none
//			cell.backgroundColor = .white
//			guard let itemTransaction = self.interactor.dataSource.dataTransaction else {
//				let cell = UITableViewCell()
//				cell.backgroundColor = .white
//				return cell
//			}
//			// Buyer
//			switch (itemTransaction.orderStatus, itemTransaction.paymentStatus, itemTransaction.shipmentStatus) {
//			case ("NEW", "WAIT", ""):
//				cell.configure(firstText: "Bayar Sekarang", secondText: "Lihat Produk")
//			case ("NEW", "PAID", ""):
//				cell.configure(firstText: "", secondText: "")
//			case ("NEW", "FAILED", ""):
//				cell.configure(firstText: "Beli Lagi", secondText: "Beli Lagi")
//			case ("PROCESS", "PAID", "PACKAGING"):
//				cell.configure(firstText: "Cek Status Pesanan", secondText: "Lihat Produk")
//			case ("PROCESS", "PAID", "SHIPPING"):
//				cell.configure(firstText: "Lacak Pengiriman", secondText: "Lihat Produk")
//			case ("PROCESS", "PAID", "DELIVERED"):
//				cell.configure(firstText: "Konfirmasi Pesanan", secondText: "Ajukan Komplain")
//				cell.secondaryButton.setup(color: .whiteSmoke, textColor: .gray, font: .AirBnbCereal(.book, size: 14))
//			case ("COMPLETE", "SETTLED", "DELIVERED"):
//				cell.configure(firstText: "", secondText: "")
//			default:
//				cell.configure(firstText: "", secondText: "")
//			}
//
//			cell.handler = { [weak self] in
//
//				switch (itemTransaction.orderStatus, itemTransaction.paymentStatus, itemTransaction.shipmentStatus) {
//				case ("NEW", "WAIT", ""):
//					self?.router.routeTo(.virtualAccount(id: itemTransaction.id))
//				case ("NEW", "PAID", ""):
//					break
//				case ("PROCESS", "PAID", "PACKAGING"):
//					self?.router.routeTo(.trackingShipment(id: itemTransaction.id))
//				case ("PROCESS", "PAID", "SHIPPING"):
//					self?.router.routeTo(.trackingShipment(id: itemTransaction.id))
//				case ("PROCESS", "PAID", "DELIVERED"):
//					self?.showDialog()
//				case ("COMPLETE", "SETTLED", "DELIVERED"):
//					cell.configure(firstText: "", secondText: "")
//				default:
//					break
//				}
//			}
//
//			cell.secondaryHandler = { [weak self] in
//				guard let self = self else { return }
//				switch (itemTransaction.orderStatus, itemTransaction.paymentStatus, itemTransaction.shipmentStatus) {
//				case ("PROCESS", "PAID", "DELIVERED"):
//					self.router.routeTo(.complaint(id: itemTransaction.id))
//				default:
//					break
//				}
//			}
//
//			return cell
//		default:
//			return UITableViewCell()
//		}
//	}
//
//	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//		switch indexPath.section {
//		case 4, 5, 7, 0:
//			return 120
//		case 8:
//			return 110
//		default:
//			return 100
//		}
//	}
//
//	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//	}
//
//}
//
//
//// MARK: - Private Zone
//private extension DetailTransactionPurchaseController {
//
//	func displayDetailNotification(_ viewModel: TransactionProduct) {
//		self.interactor.dataSource.data = viewModel
//		mainView.tableView.refreshControl?.endRefreshing()
//		mainView.stopSkeletonAnimation()
//		mainView.tableView.reloadData()
//	}
//
//	func displayCompletePurchase(_ viewModel: DefaultResponse) {
//		self.hideDialog()
//		mainView.tableView.refreshControl?.endRefreshing()
//		mainView.stopSkeletonAnimation()
//		mainView.tableView.reloadData()
//	}
//}
