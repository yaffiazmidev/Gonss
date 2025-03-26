//
//  DetailTransactionSalesController.swift
//  KipasKipas
//
//  Created by movan on 13/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol DetailTransactionDisplayLogic where Self: UIViewController {
	
	func displayViewModel(_ viewModel: DetailTransactionModel.ViewModel)
}

final class DetailTransactionSalesController: UIViewController, Displayable, DetailTransactionDisplayLogic {
	
	private let mainView: DetailTransactionSalesView
	private var interactor: DetailTransactionInteractable!
	private var router: DetailTransactionRouting!
	private let sections: [String] = [.get(.pesanan), .get(.catatan), .get(.dimensi), .get(.berat), .get(.diKirimKe), .get(.pengirim), ""]
	
	init(mainView: DetailTransactionSalesView, dataSource: DetailTransactionModel.DataSource) {
		self.mainView = mainView
		
		super.init(nibName: nil, bundle: nil)
		interactor = DetailTransactionInteractor(viewController: self, dataSource: dataSource)
		router = DetailTransactionRouter(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		handleRefreshNotifications()
        handleTermAndCondition()
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
    
    func handleTermAndCondition() {
        mainView.handleTermAndCondition = { [weak self] url in
            self?.router.routeTo(.browser(url: url, isDownloadAble: false))
        }
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
    
    func decideTitleAndTerms(){
        var terms : ProcessTermsCondition!
        var title : String!
        
        guard let item = self.interactor.dataSource.data else { fatalError() }
        
        switch (item.status ?? "", item.payment?.status ?? "", item.orderShipment?.status ?? "") {
        case ("NEW", "WAIT", ""):
            terms = ProcessTermsCondition(title: .get(.processNewOrderTermsContent), subtitle: .get(.processAdjustTerm), showPriceTerm: true)
            title = .get(.detailTransaction)
        case ("NEW", "PAID", ""):
            terms = ProcessTermsCondition(title: .get(.processNewOrderTermsContent), subtitle: .get(.processAdjustTerm), showPriceTerm: true)
            title = .get(.detailTransaction)
        case ("PROCESS", "PAID", "PACKAGING"):
            terms = ProcessTermsCondition(title: .get(.processNotReadyTermContent), subtitle: .get(.processAdjustTerm), showPriceTerm: true)
            title = .get(.detailCourier)
        case ("PROCESS", "PAID", "SHIPPING"):
            terms = ProcessTermsCondition(title: "", subtitle: "", showPriceTerm: false)
            title = .get(.detailProcessCourier)
        case ("PROCESS", "PAID", "DELIVERED"):
            terms = ProcessTermsCondition(title: "", subtitle: "", showPriceTerm: false)
            title = .get(.detailProcessCourier)
        case ("COMPLETE", "SETTLED", "DELIVERED"):
            terms = ProcessTermsCondition(title: .get(.priceTermsContent), subtitle: .get(.priceAdjustTerms), showPriceTerm: true)
            title = .get(.detailTransactionSalesDone)
        case ("CANCELLED", "EXPIRED", ""):
            terms = ProcessTermsCondition(title: "", subtitle: "", showPriceTerm: false)
            title = .get(.detailTransaction)
        case ("CANCELLED", "RETURN", "CANCELLED"):
            terms = ProcessTermsCondition(title: "", subtitle: "", showPriceTerm: false)
            title = .get(.detailTransaction)
        case ("CANCELLED", "RETURN", ""):
            terms = ProcessTermsCondition(title: " ", subtitle: "", showPriceTerm: false)
            title = .get(.detailTransaction)
        case ("CANCELLED", "", ""):
            terms = ProcessTermsCondition(title: "", subtitle: "", showPriceTerm: false)
            title = .get(.detailTransaction)
        default:
            break
        }
        
        mainView.showHiddenPriceTerms(isHidden: terms.showPriceTerm, terms.title, terms.subtitle)
        bindNavigationBar(title)
    }
}


// MARK: - DetailTransactionSalesViewDelegate
extension DetailTransactionSalesController: DetailTransactionSalesViewDelegate, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate {
	
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
		var height = 0
		switch section {
		case 6:
			height = 0
		default:
			height = 20
		}
		
		let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: Int(width), height: height))
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

		guard let item = self.interactor.dataSource.data else {
			let cell = UITableViewCell()
			cell.backgroundColor = .white
			return cell
		}
		
		switch section {
		case 0:
			let cell = tableView.dequeueReusableCustomCell(with: DetailTransactionHeaderItemCell.self, indexPath: indexPath)
            var price: Double = 0
            if (item.orderDetail?.productType ?? "ORIGINAL") == "ORIGINAL" {
                price = item.orderDetail?.productPrice ?? 0
            } else if (item.orderDetail?.productType ??  "ORIGINAL") == "RESELLER" {
                price = (item.orderDetail?.commission ?? 0) + (item.orderDetail?.modal ?? 0)
            }
			cell.configure(
				imageURL: item.orderDetail?.urlProductPhoto ?? "",
				title: item.orderDetail?.productName ?? "" ,
				price: price.toMoney(),
				quantity: String(item.orderDetail?.quantity ?? 0))
			
			return cell
		case 1:
			let cell = tableView.dequeueReusableCustomCell(with: AreasItemCell.self, indexPath: indexPath)
			
            cell.item = item.orderShipment?.notes?.isEmpty == true ? "-" : item.orderShipment?.notes 

			return cell
		
		case 2, 3:
			let cell = tableView.dequeueReusableCustomCell(with: AreasItemCell.self, indexPath: indexPath)
			
			
			let length = item.orderDetail?.measurement?.length ?? 0.0
			let width = item.orderDetail?.measurement?.width ?? 0.0
			let height = item.orderDetail?.measurement?.height ?? 0.0
			let weight = item.orderDetail?.measurement?.weight ?? 0.0
			
			cell.nameLabel.textColor = .contentGrey
			if section == 2 {
				cell.item = "\(Int(length)) cm x \(Int(width)) cm x \(Int(height)) cm"
			} else {
				cell.item = "\(weight) kg"
			}

			return cell
		case 4:
			let cell = tableView.dequeueReusableCustomCell(with: AreasItemCell.self, indexPath: indexPath)


            let address = "\(item.orderShipment?.destinationReceiverName ?? "") - \(item.orderShipment?.destinationPhoneNumber ?? "")\n\(item.orderShipment?.destinationLabel ?? ""), \(item.orderShipment?.destinationDetail ?? ""), \(item.orderShipment?.destinationSubDistrict ?? ""), \(item.orderShipment?.destinationCity ?? ""), \(item.orderShipment?.destinationProvince ?? ""), \(item.orderShipment?.destinationPostalCode ?? "")"
			cell.item = address
			cell.nameLabel.textColor = .contentGrey
            cell.nameLabel.setLineSpacing(lineSpacing: 2)

			return cell
		case 5:
			let cell = tableView.dequeueReusableCustomCell(with: DetailLabelTappedItemCell.self, indexPath: indexPath)
            
            let courier = item.orderShipment?.courier ?? ""
            var cost = item.orderShipment?.cost?.toMoney() ?? ""
            switch (item.status ?? "", item.payment?.status ?? "", item.orderShipment?.status ?? "" ) {
            case ("COMPLETE", "SETTLED", "DELIVERED"):
                cost = .get(.sudahDiterima)
            default:
                cost = item.orderShipment?.cost?.toMoney() ?? ""
            }
			cell.selectionStyle = .none
			
			cell.customLabel.configure(title: courier, subtitle: cost)
			return cell
		case 6:
			let cell = tableView.dequeueReusableCustomCell(with: DetailTransactionButtonItemCell.self, indexPath: indexPath)
			
			switch (item.status ?? "", item.payment?.status ?? "", item.orderShipment?.status ?? "") {
			case ("NEW", "WAIT", ""):
				cell.configure(firstText: "", secondText: "")
			case ("NEW", "PAID", ""):
				cell.configure(firstText: "Proses Pesanan", secondText: "Tolak Pesanan")
				cell.secondaryButton.setup(color: .whiteSnow, textColor: .grey, font: .Roboto(.bold, size: 14))
			case ("PROCESS", "PAID", "PACKAGING"):
				cell.configure(firstText: "Request Pick Up", secondText: "")
			case ("PROCESS", "PAID", "SHIPPING"):
                cell.configure(firstText: "Print Label Pengiriman", secondText: .get(.showBarcodeSeller))
				cell.secondaryButton.setup(color: .primaryLowTint, textColor: .primary, font: .Roboto(.bold, size: 14))
			case ("PROCESS", "PAID", "DELIVERED"):
                cell.configure(firstText: "Print Label Pengiriman", secondText: .get(.showBarcodeSeller))
                cell.secondaryButton.setup(color: .primaryLowTint, textColor: .primary, font: .Roboto(.bold, size: 14))
			case ("COMPLETE", "SETTLED", "DELIVERED"):
				cell.configure(firstText: "", secondText: "")
			case ("CANCELLED", "EXPIRED", ""):
				cell.configure(firstText: "", secondText: "")
			case ("CANCELLED", "RETURN", "CANCELLED"):
				cell.configure(firstText: "", secondText: "")
			case ("CANCELLED", "RETURN", ""):
				cell.configure(firstText: "", secondText: "")
			default:
				break
			}
			
			cell.handler = { [weak self] in
				// Seller
				switch (item.status ?? "", item.payment?.status ?? "", item.orderShipment?.status ?? "") {
				case ("NEW", "WAIT", ""):
					break
				case ("NEW", "PAID", ""):
					self?.interactor.doRequest(.processOrder(id: item.id ?? "", type: .process))
					cell.mainButton.setup(color: .primaryLowTint, textColor: .primary, font: .Roboto(.bold, size: 14))
					cell.mainButton.isEnabled = false
				case ("PROCESS", "PAID", "PACKAGING"):
                    self?.interactor.doRequest(.requestPickUP(service: item.orderShipment?.courier ?? "" , id: item.id ?? "" ))
					cell.mainButton.setup(color: .primaryLowTint, textColor: .primary, font: .Roboto(.bold, size: 14))
					cell.mainButton.isEnabled = false
				case ("PROCESS", "PAID", "SHIPPING"):
					self?.router.routeTo(.browser(url: item.orderShipment?.shippingLabelFileUrl ?? "", isDownloadAble: true))
				case ("PROCESS", "PAID", "DELIVERED"):
                    self?.router.routeTo(.browser(url: item.orderShipment?.shippingLabelFileUrl ?? "", isDownloadAble: false))
				case ("COMPLETE", "SETTLED", "DELIVERED"):
					cell.configure(firstText: "", secondText: "")
					self?.router.routeTo(.checkMySaldo(id: getIdUser()))
				default:
					break
				}
			}
			
			cell.secondaryHandler = { [weak self] in
				switch (item.status ?? "", item.payment?.status ?? "", item.orderShipment?.status ?? "") {
				case ("NEW", "PAID", ""):
					self?.router.routeTo(.cancelSalesOrder(id: item.id ?? ""))
				case ("PROCESS", "PAID", "SHIPPING"):
					self?.interactor.doRequest(.showBarcode(id: item.id ?? ""))
                case ("PROCESS", "PAID", "DELIVERED"):
                    self?.interactor.doRequest(.showBarcode(id: item.id ?? ""))
				default:
					break
				}
			}
			
			return cell
		default:
			return UITableViewCell()
		}
	}
	
}


// MARK: - Private Zone
private extension DetailTransactionSalesController {
	
	func displayDetailNotification(_ viewModel: TransactionProduct) {
		self.interactor.dataSource.data = viewModel
        decideTitleAndTerms()
		mainView.tableView.refreshControl?.endRefreshing()
		mainView.tableView.reloadData()
        mainView.loadingIndicator.stopAnimating()
	}
	
	func displayProcessOrder(_ viewModel: DefaultResponse) {
		self.router.routeTo(.dismissWith(action: { [weak self] in
			guard let controllers = self?.navigationController?.viewControllers else { return }
			
			for item in controllers {
				if let statusController = item as? StatusTransactionController {
					for itemController in statusController.viewControllerList {
						if let orderController = itemController as? OrderSalesController {
							orderController.swipeMenuView.jump(to: 1, animated: true)
						}
					}
				}
			}
		}))
	}
	
	func displayPickUp(_ viewModel: RequestPickUpResponse) {
		self.router.routeTo(.dismissWith(action: { [weak self] in
			guard let controllers = self?.navigationController?.viewControllers else { return }
			
			for item in controllers {
				if let statusController = item as? StatusTransactionController {
					for itemController in statusController.viewControllerList {
						if let orderController = itemController as? OrderSalesController {
							orderController.swipeMenuView.jump(to: 2, animated: true)
						}
					}
				}
			}
		}))
	}
	
	func displayBarcode(_ viewModel: Data) {
		self.interactor.dataSource.dataImage = viewModel
		self.showDialog()
	}
}
