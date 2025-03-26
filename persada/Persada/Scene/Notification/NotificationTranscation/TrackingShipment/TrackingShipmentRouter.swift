//
//  TrackingShipmentRouter.swift
//  KipasKipas
//
//  Created by movan on 18/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol TrackingShipmentRouting {
  
  func routeTo(_ route: TrackingShipmentModel.Route)
}

final class TrackingShipmentRouter: Routeable {
  
  private weak var viewController: UIViewController?
  
  init(_ viewController: UIViewController?) {
    self.viewController = viewController
  }
}


// MARK: - TrackingShipmentRouting
extension TrackingShipmentRouter: TrackingShipmentRouting {
  
  func routeTo(_ route: TrackingShipmentModel.Route) {
    DispatchQueue.main.async {
      switch route {
        
      case .dismissTrackingShipmentScene:
        self.dismissTrackingShipmentScene()
      }
    }
  }
}


// MARK: - Private Zone
private extension TrackingShipmentRouter {
  
  func dismissTrackingShipmentScene() {
    viewController?.dismiss(animated: true)
  }
}
