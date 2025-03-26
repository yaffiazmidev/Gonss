//
//  EditProfileRouter.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 13/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.

import UIKit

protocol EditProfileRouting {
  
  func routeTo(_ route: EditProfileModel.Route)
}

final class EditProfileRouter: Routeable {
  
  private weak var viewController: UIViewController?
  
  init(_ viewController: UIViewController?) {
    self.viewController = viewController
  }
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}


// MARK: - EditProfileRouting
extension EditProfileRouter: EditProfileRouting {
  
  func routeTo(_ route: EditProfileModel.Route) {
    DispatchQueue.main.async {
      switch route {
        
      case .dismissWhenAlreadySave:
        self.dismissWhenAlreadySave()
        
      case .dismiss:
        self.dismiss()
      }
    }
  }
}


// MARK: - Private Zone
private extension EditProfileRouter {
  
  func dismissWhenAlreadySave() {
		viewController?.navigationController?.setNavigationBarHidden(true, animated: false)
        NotificationCenter.default.post(name: .notificationUpdateProfile, object: nil)
		viewController?.navigationController?.popToRootViewController(animated: false)
  }
  
  func dismiss() {
		viewController?.navigationController?.popViewController(animated: false)
  }
}
