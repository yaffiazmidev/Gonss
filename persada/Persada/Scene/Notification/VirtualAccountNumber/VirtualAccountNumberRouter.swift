//
//  VirtualAccountNumberRouter.swift
//  KipasKipas
//
//  Created by movan on 19/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol VirtualAccountNumberRouting {
  
  func routeTo(_ route: VirtualAccountNumberModel.Route)
}

final class VirtualAccountNumberRouter: Routeable {
  
  private weak var viewController: UIViewController?
  
  init(_ viewController: UIViewController?) {
    self.viewController = viewController
  }
}


// MARK: - VirtualAccountNumberRouting
extension VirtualAccountNumberRouter: VirtualAccountNumberRouting {
  
  func routeTo(_ route: VirtualAccountNumberModel.Route) {
    DispatchQueue.main.async {
      switch route {
        
      case .dismissVirtualAccountNumberScene:
        self.dismissVirtualAccountNumberScene()
      }
    }
  }
}


// MARK: - Private Zone
private extension VirtualAccountNumberRouter {
  
  func dismissVirtualAccountNumberScene() {
		viewController?.navigationController?.popViewController(animated: true)
  }
}
