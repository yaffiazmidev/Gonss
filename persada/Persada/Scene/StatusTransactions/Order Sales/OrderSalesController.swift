//
//  OrderSalesController.swift
//  KipasKipas
//
//  Created by NOOR on 19/01/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import UIKit
import Combine

final class OrderSalesController: SwipeMenuViewController {
	
	var options = SwipeMenuViewOptions()
	private var subscription = Set<AnyCancellable>()
	
	private let menu = [String.get(.pesananBaru), String.get(.diproces), String.get(.dikirim), String.get(.done), String.get(.batal)]
	
	static var newOrderDataSource: OrderSalesTabAllModel.DataSource = {
		let data = OrderSalesTabAllModel.DataSource()
		data.terms = ProcessTermsCondition(title: .get(.processNewOrderTermsContent), subtitle: .get(.processAdjustTerm), showPriceTerm: true)
		data.title = .get(.detailTransaction)
		return data
	}()
	
	static var notReadyDataSource: OrderSalesTabAllModel.DataSource = {
		let data = OrderSalesTabAllModel.DataSource()
		data.terms = ProcessTermsCondition(title: .get(.processNotReadyTermContent), subtitle: .get(.processAdjustTerm), showPriceTerm: true)
		data.title = .get(.detailCourier)
		return data
	}()
	
	static var processCourierDataSource: OrderSalesTabAllModel.DataSource = {
		let data = OrderSalesTabAllModel.DataSource()
		data.terms = ProcessTermsCondition(title: "", subtitle: "", showPriceTerm: false)
		data.title = .get(.detailProcessCourier)
		return data
	}()
	
	static var processDoneDataSource: OrderSalesTabAllModel.DataSource = {
		let data = OrderSalesTabAllModel.DataSource()
		data.terms = ProcessTermsCondition(title: .get(.priceTermsContent), subtitle: .get(.priceAdjustTerms), showPriceTerm: true)
		data.title = .get(.detailTransactionSalesDone)
		return data
	}()
	
	static var cancelDataSource: OrderSalesTabAllModel.DataSource = {
		let data = OrderSalesTabAllModel.DataSource()
		data.terms = ProcessTermsCondition(title: "", subtitle: "", showPriceTerm: false)
		data.title = .get(.detailTransaction)
		return data
	}()
	
	var viewControllers = [
		OrderSalesTabAllController(mainView: OrderSalesTabAllView(), dataSource: newOrderDataSource, endpoint: .getOrderSalesTabNew(page: 0)),
		OrderSalesTabAllController(mainView: OrderSalesTabAllView(), dataSource: notReadyDataSource, endpoint: .getOrderSalesTabProcess(page: 0)),
		OrderSalesTabAllController(mainView: OrderSalesTabAllView(), dataSource: processCourierDataSource, endpoint: .getOrderSalesTabShipping(page: 0)),
		OrderSalesTabAllController(mainView: OrderSalesTabAllView(), dataSource: processDoneDataSource, endpoint: .getOrderSalesTabComplete(page: 0)),
		OrderSalesTabAllController(mainView: OrderSalesTabAllView(), dataSource: cancelDataSource, endpoint: .getOrderSalesTabCancel(page: 0))
	]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		viewControllers.enumerated().forEach { (key, controller) in
			let vc = controller
            self.addChild(vc)
			vc.view.fillSuperview()
//            fillContainer()
		}
		
		options.tabView.style = .flexible
		options.tabView.addition = .none
		options.contentScrollView.isScrollEnabled = true
		swipeMenuView.backgroundColor = .white
		swipeMenuView.reloadData(options: options)
		
		self.viewControllers.first?.interactor.dataSource.totalOrder.sink(receiveValue: {
			self.swipeMenuView.tabView?.itemViews.first?.setCounter(value: $0)
		}).store(in: &subscription)
		
		self.viewControllers[1].interactor.dataSource.totalOrder.sink(receiveValue: {
			self.swipeMenuView.tabView?.itemViews[1].setCounter(value: $0)
		}).store(in: &subscription)
		
		self.viewControllers[2].interactor.dataSource.totalOrder.sink(receiveValue: {
			self.swipeMenuView.tabView?.itemViews[2].setCounter(value: $0)
		}).store(in: &subscription)
		
		self.viewControllers[3].interactor.dataSource.totalOrder.sink(receiveValue: {
			self.swipeMenuView.tabView?.itemViews[3].setCounter(value: $0)
		}).store(in: &subscription)
		
		self.viewControllers.last?.interactor.dataSource.totalOrder.sink(receiveValue: {
			self.swipeMenuView.tabView?.itemViews.last?.setCounter(value: $0)
		}).store(in: &subscription)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		navigationController?.hideKeyboardWhenTappedAround()
		navigationController?.navigationBar.backgroundColor = UIColor.white
		navigationController?.interactivePopGestureRecognizer?.isEnabled = true
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		navigationController?.navigationBar.backgroundColor = nil
	}
	
	override func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewWillSetupAt currentIndex: Int) {
			super.swipeMenuView(swipeMenuView, viewWillSetupAt: currentIndex)
	}

	override func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewDidSetupAt currentIndex: Int) {
			super.swipeMenuView(swipeMenuView, viewDidSetupAt: currentIndex)
	}

	override func swipeMenuView(_ swipeMenuView: SwipeMenuView, willChangeIndexFrom fromIndex: Int, to toIndex: Int) {
			super.swipeMenuView(swipeMenuView, willChangeIndexFrom: fromIndex, to: toIndex)
	}

	override func swipeMenuView(_ swipeMenuView: SwipeMenuView, didChangeIndexFrom fromIndex: Int, to toIndex: Int) {
			super.swipeMenuView(swipeMenuView, didChangeIndexFrom: fromIndex, to: toIndex)
	}

	// MARK - SwipeMenuViewDataSource

	override func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int {
		return viewControllers.count
	}

	override func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String {
			return menu[index]
	}

	override func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController {
			let vc = viewControllers[index]
			vc.didMove(toParent: self)
			return vc
	}
	
}
