//
//  OrderSalesTabAllController.swift
//  KipasKipas
//
//  Created by NOOR on 21/01/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import UIKit
import Combine

protocol OrderSalesTabAllDisplayLogic where Self: UIViewController {
	
	func displayViewModel(_ viewModel: OrderSalesTabAllModel.ViewModel)
}

enum SectionOrderSales {
	case tabAll
}

final class OrderSalesTabAllController: UIViewController, DisplayableByEndpoint, OrderSalesTabAllDisplayLogic {
	
	private let mainView: OrderSalesTabAllView
	var interactor: OrderSalesTabAllInteractable!
	private var router: OrderSalesTabAllRouting!
	private lazy var dataSource: UITableViewDiffableDataSource<SectionOrderSales, AnyHashable>! = nil
	private var endpoint: OrderSalesTabAllModel.Request
	
	private var page: Int = 0
	private var lastPage: Int = 0
	var refreshControl = UIRefreshControl()
	
	init(mainView: OrderSalesTabAllView, dataSource: OrderSalesTabAllModel.DataSource, endpoint: OrderSalesTabAllModel.Request) {
		self.mainView = mainView
		self.endpoint = endpoint
		super.init(nibName: nil, bundle: nil)
		interactor = OrderSalesTabAllInteractor(viewController: self, dataSource: dataSource)
		router = OrderSalesTabAllRouter(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()

		interactor.doRequest(self.endpoint)
		bindDataSource()
		refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
		mainView.tableView.addSubview(refreshControl)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		refresh()
		navigationController?.hideKeyboardWhenTappedAround()
		navigationController?.navigationBar.backgroundColor = UIColor.white
		navigationController?.interactivePopGestureRecognizer?.isEnabled = true
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.navigationBar.backgroundColor = nil
	}
	
	private func bindDataSource() {
		dataSource = UITableViewDiffableDataSource<SectionOrderSales, AnyHashable>(tableView: mainView.tableView) {
			(tableView, index, object) -> UITableViewCell? in
			
			switch object {
			case let object as OrderCellViewModel:
				
				if object.orderStatus == "PROCESS" && object.paymentStatus == "PAID" && object.shipmentStatus == "PACKAGING" {
					let cell = tableView.dequeueReusableCell(withIdentifier: OrderTransactionWithButtonCell.className, for: index) as! OrderTransactionWithButtonCell
					
					cell.setUpCell(item: object, buttonText: .get(.requestPickUp))
					cell.statusLabel.text = object.noInvoice
					cell.statusLabel.textColor = .secondary
					
					cell.handleTransaction = { [weak self] (courier ,orderId, b) in
                        guard let self = self else { return }
						self.interactor.doRequest(.requestPickUp(service: courier, id: orderId))
						cell.buttonAction.setup(color: .primaryLowTint, textColor: .primary, font: .Roboto(.bold, size: 14))
					}
					cell.buttonAction.setup(color: .primary, textColor: .white, font: UIFont.Roboto(.bold, size: 14))
					
					return cell
				} else {
					let cell = tableView.dequeueReusableCell(withIdentifier: OrderTransactionWithoutButtonCell.className, for: index) as! OrderTransactionWithoutButtonCell
					
					cell.setUpCell(item: object, buttonText: "")
					cell.statusLabel.text = object.noInvoice
					cell.statusLabel.textColor = .secondary
					return cell
				}

			default:
				return nil
			}
		}
		
		updateUI()
	}
	
	private func createSnapshot() -> NSDiffableDataSourceSnapshot<SectionOrderSales, AnyHashable> {
		var snapshot = NSDiffableDataSourceSnapshot<SectionOrderSales, AnyHashable>()
		snapshot.appendSections([.tabAll])
		snapshot.appendItems(self.interactor.dataSource.data)

		return snapshot
	}
	
	private func updateUI() {
		let snapshot = createSnapshot()
		dataSource.apply(snapshot, animatingDifferences: false)
	}
	
	override func loadView() {
		view = mainView
		mainView.tableView.delegate = self
	}
	
	@objc func refresh(){
		page = 0
		interactor.doRequest(self.endpoint)
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
	}
	
	
	// MARK: - OrderSalesTabAllDisplayLogic
	func displayViewModel(_ viewModel: OrderSalesTabAllModel.ViewModel) {
		DispatchQueue.main.async {
			switch viewModel {
				
			case let .orderSales(viewModel, lastPage):
				self.displayOrderSales(viewModel,lastPage)
			case .pickUp(let viewModel):
				self.displayPickUp(viewModel)
			}
		}
	}
}

extension OrderSalesTabAllController: UIGestureRecognizerDelegate, UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let object = dataSource.itemIdentifier(for: indexPath)
		
		switch object {
		
		case let object as OrderCellViewModel:
			guard let term = self.interactor.dataSource.terms, let title = self.interactor.dataSource.title else {
				return
			}
			
			self.router.routeTo(.detailTransaction(data: object, showPriceTerms: term, title: title))
		default:
			break
		}
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
			if endpoint == .getOrderSalesTabCancel(page: 0) && page <= lastPage {
				page = page + 1
				interactor.doRequest(.getOrderSalesTabCancel(page: page))
				return
			} else if endpoint == .getOrderSalesTabComplete(page: 0) && page <= lastPage {
				page = page + 1
				interactor.doRequest(.getOrderSalesTabComplete(page: page))
				return
			} else if endpoint == .getOrderSalesTabProcess(page: 0) && page <= lastPage {
				page = page + 1
				interactor.doRequest(.getOrderSalesTabProcess(page: page))
				return
			} else if endpoint == .getOrderSalesTabNew(page: 0) && page <= lastPage {
				page = page + 1
				interactor.doRequest(.getOrderSalesTabNew(page: page))
				return
			} else if endpoint == .getOrderSalesTabShipping(page: 0) && page <= lastPage {
				page = page + 1
				interactor.doRequest(.getOrderSalesTabShipping(page: page))
				return
			}
		}
	}
}


// MARK: - Private Zone
private extension OrderSalesTabAllController {
	
	func displayOrderSales(_ viewModel: [OrderCellViewModel], _ lastPage: Int) {
		if page == 0 {
			interactor.dataSource.data = viewModel
		} else {
			interactor.dataSource.data = interactor.dataSource.data + viewModel
		}
		
		self.lastPage = lastPage
		mainView.emptyView.isHidden = !interactor.dataSource.data.isEmpty
		refreshControl.endRefreshing()
		updateUI()
	}
	
	func displayPickUp(_ viewModel: RequestPickUpResponse) {
		self.refresh()
		
		guard let controllers = self.navigationController?.viewControllers else { return }
		
		for item in controllers {
			if let statusController = item as? StatusTransactionController {
				for itemController in statusController.viewControllerList {
					if let orderController = itemController as? OrderSalesController {
						orderController.swipeMenuView.jump(to: 2, animated: true)
						if let controller = orderController.viewControllers[2] as? OrderSalesTabAllController {
							controller.refresh()
						}
						
					}
				}
			}
		}
	}
}
