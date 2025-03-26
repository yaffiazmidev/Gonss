//
//  HistoryOfBalanceRouter.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 01/03/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import UIKit
import ContextMenu

protocol HistoryOfBalanceRouting {
	func dismiss()
	func filter(source: UIViewController, destination: UIViewController)
	func detailBalance(id: String)
}

final class HistoryOfBalanceRouter: Routeable {
  
  private weak var viewController: UIViewController?
  
  init(_ viewController: UIViewController?) {
    self.viewController = viewController
  }
}


// MARK: - HistoryOfBalanceRouting
extension HistoryOfBalanceRouter: HistoryOfBalanceRouting {
	
	func dismiss() {
		viewController?.dismiss(animated: true)
	}
	
	func filter(source: UIViewController, destination: UIViewController) {
		let destination = destination as! BalanceFilterMenuController
		ContextMenu.shared.show(
			sourceViewController: source,
			viewController: destination,
			options: ContextMenu.Options(menuStyle: .minimal, hapticsStyle: .heavy)
		)
	}
	
	func detailBalance(id: String) {
		let controller = DetailOfBalanceController(mainView: DetailOfBalanceView())
		
		viewController?.navigationController?.pushViewController(controller, animated: false)
	}
}
