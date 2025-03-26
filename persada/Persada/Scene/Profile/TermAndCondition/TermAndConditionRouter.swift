//
//  TermAndConditionRouter.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 11/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.

import UIKit

protocol TermAndConditionRouting {
  
  func routeTo(_ route: TermAndConditionModel.Route)
}

final class TermAndConditionRouter: Routeable {
  
  private weak var viewController: UIViewController?
  
  init(_ viewController: UIViewController?) {
    self.viewController = viewController
  }
}


// MARK: - TermAndConditionRouting
extension TermAndConditionRouter: TermAndConditionRouting {
  
  func routeTo(_ route: TermAndConditionModel.Route) {
    DispatchQueue.main.async {
      switch route {
        
      case .dismissTermAndConditionScene:
        self.dismissTermAndConditionScene()
        
      case .xScene(let data):
        self.showXSceneBy(data)
      }
    }
  }
}


// MARK: - Private Zone
private extension TermAndConditionRouter {
  
  func dismissTermAndConditionScene() {
		viewController?.dismiss(animated: true, completion: nil)
  }
  
  func showXSceneBy(_ data: Int) {
    print("will show the next screen")
  }
}
