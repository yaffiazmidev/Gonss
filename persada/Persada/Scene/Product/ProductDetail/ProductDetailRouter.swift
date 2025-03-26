//
//  ProductDetailRouter.swift
//  Persada
//
//  Created by movan on 22/07/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import ContextMenu

protocol ShopDetailRouting {
    func dismiss()
    func checkout(_ item: Product, _ total: Int, onProductUpdated: ((_ product: Product) -> Void)?)
    func profile(_ id: String, _ type: String)
    func options(source: UIViewController, destination: UIViewController, texts: [String])
    func editProduct(_ item: Product, isArchive: Bool)
    func review(_ id: String, loader: ReviewPagedLoader)
    func reviewMedia(_ id: String, loader: ReviewMediaPagedLoader)
    func reviewDetailMedia(_ items: [ReviewMedia], itemAt: Int)
}

final class ProductDetailRouter: Routeable {
    
    private weak var viewController: UIViewController?
    
    init(_ viewController: UIViewController?) {
        self.viewController = viewController
    }
}


// MARK: - ShopDetailRouting
extension ProductDetailRouter {
    
    func dismiss() {
        viewController?.navigationController?.showBarIfNecessary()
        viewController?.navigationController?.popViewController(animated: true)
    }
    
    func checkout(_ item: Product, _ quantity: Int, onProductUpdated: ((_ product: Product) -> Void)?) {
        let checkout = CheckoutController(mainView: CheckoutView(), productId: item.id ?? "", quantity: quantity)
        checkout.onProductUpdated = onProductUpdated
        viewController?.navigationController?.pushViewController(checkout, animated: true)
    }
    
    func profile(_ id: String, _ type: String) {
        let controller = ProfileRouter.create(userId: id)
        controller.bindNavigationBar("", icon: "ic_chevron_left_outline_black", customSize: .init(width: 20, height: 14), contentHorizontalAlignment: .fill, contentVerticalAlignment: .fill)
        
        viewController?.navigationController?.push(controller)
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
    
    func toArchive(){
        let myArchiveProduct = ProductArchiveController(mainView: ProductArchiveView(), dataSource: ProductArchiveModel.DataSource())
        viewController?.navigationController?.pushViewController(myArchiveProduct, animated: true)
    }
    
    func editProduct(_ item: Product, isArchive: Bool){
        let vc = EditProductController(mainView: EditProductView(), dataSource: item)
        vc.isArchive = isArchive
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func review(_ id: String, loader: ReviewPagedLoader){
        let vc = ReviewViewController(idProduct: id, loader: loader)
        vc.hidesBottomBarWhenPushed = true
        viewController?.navigationController?.pushViewController(vc, animated: true)
        let router = ReviewRouter(controller: vc)
        vc.router = router
    }
    
    func reviewMedia(_ id: String, loader: ReviewMediaPagedLoader){
        let vc = ReviewMediaViewController(idProduct: id, loader: loader)
        vc.hidesBottomBarWhenPushed = true
        viewController?.navigationController?.pushViewController(vc, animated: true)
        let router = ReviewRouter(controller: vc)
        vc.router = router
    }
    
    func reviewDetailMedia(_ items: [ReviewMedia], itemAt: Int) {
        let vc = ReviewMediaDetailViewController(medias: items, itemAt: itemAt)
        let router = ReviewRouter(controller: vc)
        vc.router = router
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
}
