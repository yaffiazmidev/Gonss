//
//  ProvinceRouter.swift
//  MOVANS
//
//  Created by movan on 11/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol ProvinceRouting {
  
  func routeTo(_ route: ProvinceModel.Route)
}

final class ProvinceRouter: Routeable {
  
  private weak var viewController: UIViewController?
  
  init(_ viewController: UIViewController?) {
    self.viewController = viewController
  }
}


// MARK: - ProvinceRouting
extension ProvinceRouter: ProvinceRouting {
  
  func routeTo(_ route: ProvinceModel.Route) {
    DispatchQueue.main.async {
      switch route {
        
      case .dismissProvinceScene:
        self.dismissProvinceScene()
      }
    }
  }
}


// MARK: - Private Zone
private extension ProvinceRouter {
  
  func dismissProvinceScene() {
    viewController?.dismiss(animated: true)
  }
}
