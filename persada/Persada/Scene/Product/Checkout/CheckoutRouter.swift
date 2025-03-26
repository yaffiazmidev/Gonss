//
//  CheckoutRouter.swift
//  Persada
//
//  Created by movan on 22/07/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import KipasKipasShared

protocol CheckoutBusinessLogic {
	func dismiss()
	func changeAddress()
	func chooseCourier(_ parameter: ParameterCourier)
	func browser(_ url: String)
    func showExampleCoordinator()
}

final class CheckoutRouter: Routeable {
	
	private weak var viewController: UIViewController?
    private var exampleCoordinator: ExampleCoordinator?
	
	init(_ viewController: UIViewController?) {
		self.viewController = viewController
	}
	
	func dismiss() {
		viewController?.navigationController?.popViewController(animated: true)
	}
	
	func changeAddress() {
		let changeAddress = AddressController(mainView: AddressCheckoutView(), type: .buyer)
		viewController?.navigationController?.pushViewController(changeAddress, animated: true)
	}
	
	func chooseCourier(_ parameter: ParameterCourier?) {
        let parameter = CourierParameter(productId: parameter?.productId ?? "", addressId: parameter?.addressId ?? "", quantity: parameter?.quantity ?? 0)
        let courierController = CourierUIFactory.create(parameter: parameter) { [weak self] courier, index in
            guard let self = self else { return }
            if let controller = self.viewController as? CheckoutController {
                let prices = courier.prices?.map{ price in
                    return CourierPrice(duration: price.duration, price: price.price, service: price.service)
                }
                controller.send(value: Courier(name: courier.name!, prices: prices), index: index)
            }
        }
        
        courierController.bindNavigationBar(.get(.checkout))
		
		viewController?.navigationController?.pushViewController(courierController, animated: true)
	}
	
	func browser(_ url: String) {
		let browserController = BrowserController(url: url, type: .general)
        browserController.onBack = { [weak self] in
            guard let self = self else { return }
            
            if let firstVC = self.viewController?.navigationController?.viewControllers.first {
                self.viewController?.navigationController?.popToViewController(firstVC, animated: false)
                let controller = StatusTransactionController()
                controller.hidesBottomBarWhenPushed = true

                firstVC.navigationController?.pushViewController(controller, animated: false)
            }
        }
		viewController?.navigationController?.pushViewController(browserController, animated: true)
	}
    
    func delayedTransaction() {
        let controller = StatusTransactionController()
        viewController?.navigationController?.pushViewController(controller, animated: true)
    }

    func showExampleCoordinator() {
        guard let navigation = viewController?.navigationController else { return }
        exampleCoordinator = ExampleCoordinator(presenter: navigation)
        exampleCoordinator?.start()
    }
	
}
