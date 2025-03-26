//
//  CancelSalesOrderRouter.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 03/02/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import UIKit

protocol CancelSalesOrderRouting {
  
  func routeTo(_ route: CancelSalesOrderModel.Route)
}

final class CancelSalesOrderRouter: Routeable {
  
  private weak var viewController: UIViewController?
  
  init(_ viewController: UIViewController?) {
    self.viewController = viewController
  }
}


// MARK: - CancelSalesOrderRouting
extension CancelSalesOrderRouter: CancelSalesOrderRouting {
  
  func routeTo(_ route: CancelSalesOrderModel.Route) {
    DispatchQueue.main.async {
      switch route {
        
      case .dismiss:
        self.dismiss()
      }
    }
  }
}


// MARK: - Private Zone
private extension CancelSalesOrderRouter {
  
  func dismiss() {
		guard let viewControllers = self.viewController?.navigationController?.viewControllers else { return }
		
      for destinationVC in viewControllers {
          if destinationVC is StatusTransactionController {
              if let controller = destinationVC as? StatusTransactionController {
                  controller.backToPenjualan()
                  self.viewController?.navigationController?.popToViewController(controller, animated: false)
              }
              break
          }
          if destinationVC is NotificationController {
              if let controller = destinationVC as? NotificationController {
                  self.viewController?.navigationController?.popToViewController(controller, animated: false)
                  controller.routeToPenjualan()
             }
              break
          }
      }
  }
}
