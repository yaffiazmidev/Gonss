//
//  AddressRouter.swift
//  KipasKipas
//
//  Created by movan on 11/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit



final class AddressRouter: Routeable {
	
	private weak var viewController: UIViewController?
	
	init(_ viewController: UIViewController?) {
		self.viewController = viewController
	}
	
	func dismissAddressScene() {
		viewController?.dismiss(animated: true)
	}
	
    func detailEditAddress(_ data: Address, isSeller: AddressFetchType, _ isMultipleAddress: Bool) {
		let editAddress = EditAddressController(mainView: EditAddressView(), address: data, type: .edit, isSeller: isSeller, isMultipleAddress)

		viewController?.navigationController?.pushViewController(editAddress, animated: true)
	}
	
    func detailAddAddress(isSeller: AddressFetchType, isFirstAdded: Bool = false, isCheckout: Bool = false) {
		
		let addAddress = EditAddressController(mainAddView: AddAddressView(), address: nil, type: .add, isSeller: isSeller)
        addAddress.isFirstAdded = isFirstAdded
        addAddress.isFromCheckout = isCheckout
		viewController?.navigationController?.pushViewController(addAddress, animated: true)
	}
	
	
	func dismissAndUpdate(address: String, id: String) {
		
		for controller in (viewController?.navigationController!.viewControllers)! as Array {
				if controller.isKind(of: CheckoutController.self) {
						let checkoutVC = controller as! CheckoutController
						checkoutVC.updateDataAddress(address: address, id: id)
						viewController?.navigationController!.popToViewController(checkoutVC, animated: true)
						break
				}
		}
	}
}



