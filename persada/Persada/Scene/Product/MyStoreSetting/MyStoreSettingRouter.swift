//
//  MyStoreSettingRouter.swift
//  KipasKipas
//
//  Created by IEN-Yasin-MacbookPro on 18/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

protocol MyStoreSettingRouting {

    func routeTo(_ route: MyStoreSettingModel.Route)
}

final class MyStoreSettingRouter: Routeable {

    private weak var viewController: UIViewController?

    init(_ viewController: UIViewController?) {
        self.viewController = viewController
    }
}

// MARK: - MyStoreSettingRouting
extension MyStoreSettingRouter: MyStoreSettingRouting {

    func routeTo(_ route: MyStoreSettingModel.Route) {
        DispatchQueue.main.async {
            switch route {
            case .dismissMyStoreSetting:
                self.dismissMyStoreSetting()
            case .showMyAddress:
                self.showMyAddress()
            case .showMyCourier:
                self.showMyCourier()
            case .showMyArchiveProduct:
                self.showMyArchiveProduct()
						case .addAddress:
							self.addAddress()
            }
        }
    }
}


// MARK: - Private Zone
private extension MyStoreSettingRouter {
    func dismissMyStoreSetting() {
        viewController?.navigationController?.popViewController(animated: true)
    }
    
    func showMyAddress() {
        let changeAddress = AddressController(mainView: AddressView(), type: .seller)
        viewController?.navigationController?.pushViewController(changeAddress, animated: true)
    }
    func showMyCourier() {
        let myCourier = SelectCourierController(mainView: SelectCourierView())
        viewController?.navigationController?.pushViewController(myCourier, animated: true)
    }

    func showMyArchiveProduct() {
        let myArchiveProduct = ProductArchiveController(mainView: ProductArchiveView(), dataSource: ProductArchiveModel.DataSource())
        viewController?.navigationController?.pushViewController(myArchiveProduct, animated: true)
    }
    
    func addAddress(){
        
        let addAddressController = EditAddressController(mainAddView: AddAddressView(), address: nil, type: .add, isSeller: .seller)
        addAddressController.isFirstAdded = true

        viewController?.navigationController?.pushViewController(addAddressController, animated: true)
    }
}
