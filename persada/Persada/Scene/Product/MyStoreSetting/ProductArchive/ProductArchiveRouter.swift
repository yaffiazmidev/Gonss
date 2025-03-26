//
//  ProductArchiveRouter.swift
//  KipasKipas
//
//  Created by IEN-Yasin-MacbookPro on 22/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

protocol ProductArchiveRouting {

    func routeTo(_ route: ProductArchiveModel.Route)
}

final class ProductArchiveRouter: Routeable {

    private weak var viewController: UIViewController?

    init(_ viewController: UIViewController?) {
        self.viewController = viewController
    }
    
    func toDeleteSuccessView() {
        let deleteSuccess = DeleteSuccessController(mainView: DeleteSuccessView())
        
        viewController?.navigationController?.pushViewController(deleteSuccess, animated: true)
    }
}

// MARK: - ProductArchiveRouting
extension ProductArchiveRouter: ProductArchiveRouting {
   
    func routeTo(_ route: ProductArchiveModel.Route) {
        DispatchQueue.main.async {
            switch route {
            case .seeDetailProductArchive(let product):
                self.seeDetailProductArchive(product: product)
            }
        }
    }
}


// MARK: - Private Zone
private extension ProductArchiveRouter {
    func seeDetailProductArchive(product: Product) {
        let detailController = ProductDetailFactory.createProductDetailController(dataSource: product)
        detailController.hidesBottomBarWhenPushed = true
        detailController.isArchive = true
        viewController?.navigationController?.pushViewController(detailController, animated: true)
    }
    
   
}
