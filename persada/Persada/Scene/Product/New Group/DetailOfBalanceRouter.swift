//
//  DetailOfBalanceRouter.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 15/03/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import UIKit

protocol DetailOfBalanceRouting {

  func dismiss()
}

final class DetailOfBalanceRouter: Routeable, DetailOfBalanceRouting {
	
	private weak var viewController: UIViewController?
	
	init(_ viewController: UIViewController?) {
		self.viewController = viewController
	}
	
	func dismiss() {
		viewController?.dismiss(animated: true)
	}
}
