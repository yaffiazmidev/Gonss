//
//  AreasRouter.swift
//  KipasKipas
//
//  Created by movan on 12/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit


final class AreasRouter: Routeable {
	
	private weak var viewController: UIViewController?
	
	init(_ viewController: UIViewController?) {
		self.viewController = viewController
	}
	
	func dismissAreasScene() {
		viewController?.navigationController?.popViewController(animated: false)
	}
	
	func dismiss(_ value: Area,_ type: AreasTypeEnum) {
		
		for controller in (viewController?.navigationController!.viewControllers)! as Array {
				if controller.isKind(of: EditAddressController.self) {
						let editVC = controller as! EditAddressController
						editVC.back(value, type: type)
						viewController?.navigationController!.popToViewController(editVC, animated: true)
						break
				}
		}
	}
}

