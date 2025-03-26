//
//  LoginRouter.swift
//  Persada
//
//  Created by monggo pesen 3 on 11/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.

import UIKit

protocol AuthPopUpRouting {
    
    func routeTo(_ route: AuthPopUpModel.Route)
}

final class AuthPopUpRouter: Routeable {
    
    private weak var viewController: UIViewController?
    
    init(_ viewController: UIViewController?) {
        self.viewController = viewController
    }
}


// MARK: - LoginRouting
extension AuthPopUpRouter: AuthPopUpRouting {
    
    func routeTo(_ route: AuthPopUpModel.Route) {
        DispatchQueue.main.async {
            switch route {
                
            case .dismissPopUp:
                self.dismissPopUp()
            case .loginScene:
                self.showLoginScene()
            }
            
        }
    }
}

// MARK: - Private Zone
private extension AuthPopUpRouter {
    
    func dismissPopUp() {
        viewController?.dismiss(animated: false)
    }
    
    func showLoginScene(){
        showLogin?()
    }
}
