//
//  OrderPurchaseController.swift
//  KipasKipas
//
//  Created by NOOR on 19/01/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import UIKit
import Combine

final class OrderPurchaseController: SwipeMenuViewController {

	private var options = SwipeMenuViewOptions()
	private var subscription = Set<AnyCancellable>()
	
	private let menu = ["Belum Bayar", "Menunggu", "Diproses", "Dikirim", "Selesai", "Batal"]
	var viewControllers = [
		OrderPurchaseTabAllController(mainView: OrderPurchaseTabAllView(), dataSource: OrderPurchaseTabAllModel.DataSource(), endpoint: .getOrderPurchaseTabUnpaid(page: 0)),
		OrderPurchaseTabAllController(mainView: OrderPurchaseTabAllView(), dataSource: OrderPurchaseTabAllModel.DataSource(), endpoint: .getOrderPurchaseTabWaiting(page: 0)),
		OrderPurchaseTabAllController(mainView: OrderPurchaseTabAllView(), dataSource: OrderPurchaseTabAllModel.DataSource(), endpoint: .getOrderPurchaseTabProcess(page: 0)),
		OrderPurchaseTabAllController(mainView: OrderPurchaseTabAllView(), dataSource: OrderPurchaseTabAllModel.DataSource(), endpoint: .getOrderPurchaseTabShipping(page: 0)),
		OrderPurchaseTabAllController(mainView: OrderPurchaseTabAllView(), dataSource: OrderPurchaseTabAllModel.DataSource(), endpoint: .getOrderPurchaseTabComplete(page: 0)),
		OrderPurchaseTabAllController(mainView: OrderPurchaseTabAllView(), dataSource: OrderPurchaseTabAllModel.DataSource(), endpoint: .getOrderPurchaseTabCancel(page: 0)),
	]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		viewControllers.enumerated().forEach { (key, controller) in
			let vc = controller
			self.addChild(vc)
			vc.view.fillSuperview()
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
		
		self.viewControllers[4].interactor.dataSource.totalOrder.sink(receiveValue: {
			self.swipeMenuView.tabView?.itemViews[4].setCounter(value: $0)
		}).store(in: &subscription)
		
		self.viewControllers[5].interactor.dataSource.totalOrder.sink(receiveValue: {
			self.swipeMenuView.tabView?.itemViews[5].setCounter(value: $0)
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
        
        viewControllers[toIndex].refresh()
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
