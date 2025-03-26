//
//  MyProductRouter.swift
//  KipasKipas
//
//  Created by DENAZMI on 12/01/22.
//

import Foundation
import ContextMenu

protocol MyProductRouterRoutingLogic {
    func dismiss()
    func visitStore()
    func seeProduct(_ shop: Product, handleRefresh: (() -> Void)?)
    func createNewProduct(product: Product?, callback: @escaping () -> ())
    func addResellerProduct(callback: @escaping () -> ())
    func addAddress()
    func options(source: UIViewController, destination: UIViewController, texts: [String])
    func showHistoryWithdrawal()
    func navigateToWithdrawBalance(didWithdraw: @escaping () -> Void)
    func showMyStoreSetting()
    func navigateToProfileSetting()
    func editProduct(_ item: Product)
}

class MyProductRouter: MyProductRouterRoutingLogic {
    weak var controller: MyProductViewController?
    
    init(_ controller: MyProductViewController?) {
        self.controller = controller
    }
    
    func dismiss() {
        controller?.navigationController?.setNavigationBarHidden(true, animated: false)
        controller?.navigationController?.popViewController(animated: true)
    }
    
    func visitStore() {
        let chooseProduct = ChooseProductController(viewModel: ChooseProductViewModel(playersService: ProductNetworkModel()))
        controller?.present(chooseProduct, animated: false, completion: nil)
    }
    
    func seeProduct(_ shop: Product, handleRefresh: (() -> Void)?) {
        let detailController = ProductDetailFactory.createProductDetailController(dataSource: shop)
        detailController.handleRefreshList = handleRefresh
        detailController.hidesBottomBarWhenPushed = true
        controller?.navigationController?.pushViewController(detailController, animated: true)
    }

    func createNewProduct(product: Product?, callback: @escaping () -> ()) {
        let vc = EditProductController(mainView: EditProductView(), dataSource: product, isAdd: true)
        vc.onSuccessAddProduct = { callback() }
        controller?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func addResellerProduct(callback: @escaping () -> ()) {
        let vc = ResellerAddProductFactory.createSelectController()
        vc.onSuccessAddProduct = callback
        controller?.navigationController?.pushViewController(vc, animated: true)
    }

    func addAddress() {
        let addAddressController = EditAddressController(mainAddView: AddAddressView(), address: nil, type: .add, isSeller: .seller)
        addAddressController.isFirstAdded = true
        controller?.navigationController?.pushViewController(addAddressController, animated: true)
    }
    
    func options(source: UIViewController, destination: UIViewController, texts: [String]) {
        let destination = destination as! ProductOptionsController
        destination.source(texts: texts)
        ContextMenu.shared.show(
            sourceViewController: source,
            viewController: destination,
            options: ContextMenu.Options(menuStyle: .minimal, hapticsStyle: .heavy)
        )
    }
    
    func showHistoryWithdrawal() {
        let vc = HistoryTransactionsViewController()
        vc.hidesBottomBarWhenPushed = true
        controller?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func navigateToWithdrawBalance(didWithdraw: @escaping () -> Void) {
        let vc = WithdrawBalanceViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.didWithdraw = didWithdraw
        controller?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showMyStoreSetting() {
        let myStoreSetting = MyStoreSettingViewController(mainView: MyStoreSettingView(), dataSource: MyStoreSettingModel.DataSource())
        controller?.navigationController?.pushViewController(myStoreSetting, animated: true)
    }
    
    func navigateToProfileSetting(){
        let vc = ProfileSettingAccountViewController(mainView: ProfileSettingAccountView(), dataSource: ProfileSettingAccountModel.DataSource())
        controller?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func editProduct(_ item: Product){
        let vc = EditProductController(mainView: EditProductView(), dataSource: item)
        controller?.navigationController?.pushViewController(vc, animated: true)
    }
}
