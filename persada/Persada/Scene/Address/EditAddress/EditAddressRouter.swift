//
//  EditAddressRouter.swift
//  KipasKipas
//
//  Created by movan on 11/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

final class EditAddressRouter: Routeable {
	
	private weak var viewController: UIViewController?
	
	init(_ viewController: UIViewController?) {
		self.viewController = viewController
	}
	
    func dismissEditAddressScene(address: Address? = nil, isFirstAdded: Bool = false, isCheckout: Bool = false) {
        if isFirstAdded && isCheckout {
            for controller in (viewController?.navigationController!.viewControllers)! as Array {
                    if controller.isKind(of: CheckoutController.self) {
                            let checkoutVC = controller as! CheckoutController
                        
                            let savedAddress = "\(address?.detail ?? ""), \(address?.subDistrict ?? "") \(address?.city ?? "") \(address?.postalCode ?? "")"
                        
                            checkoutVC.updateDataAddress(address: savedAddress, id: address?.id ?? "")
                            viewController?.navigationController!.popToViewController(checkoutVC, animated: true)
                            break
                    }
            }
        } else {
            viewController?.navigationController?.popViewController(animated: true)
        }
	}
	
	func chooseProvince(_ type: AreasTypeEnum) {
		let areaController = AreasController(mainView: AreasView(), type: type, id: nil)

		self.viewController?.navigationController?.pushViewController(areaController, animated: true)
	}
	
	func chooseCity(_ id: String, _ type: AreasTypeEnum) {
		let areaController = AreasController(mainView: AreasView(), type: type, id: id)

		self.viewController?.navigationController?.pushViewController(areaController, animated: true)
	}
	
	func chooseSubdistrict(_ id: String, _ type: AreasTypeEnum) {
		let areaController = AreasController(mainView: AreasView(), type: type, id: id)

		self.viewController?.navigationController?.pushViewController(areaController, animated: true)
	}
	
	func choosePostalcode(_ id: String, _ type: AreasTypeEnum) {
		let areaController = AreasController(mainView: AreasView(), type: type, id: id)

		self.viewController?.navigationController?.pushViewController(areaController, animated: true)
	}
    
    func chooseLocation(){
        let vc = MapViewController()
        self.viewController?.navigationController?.pushViewController(vc, animated: true)
    }
}
