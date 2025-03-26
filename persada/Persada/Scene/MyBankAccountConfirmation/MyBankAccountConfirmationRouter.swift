//
//  MyBankAccountConfirmationRouter.swift
//  KipasKipas
//
//  Created by Yaffi Azmi on 25/10/21.
//

import Foundation

protocol MyBankAccountConfirmationRouterRoutingLogic {
	// do someting...
}

class MyBankAccountConfirmationRouter: MyBankAccountConfirmationRouterRoutingLogic {
    weak var view: MyBankAccountConfirmationViewController?
    
    init(view: MyBankAccountConfirmationViewController?) {
        self.view = view
    }
}

extension MyBankAccountConfirmationRouter {
    static func configure(view: MyBankAccountConfirmationViewController, parameters: [String: Any] = [:]) {
        let router = MyBankAccountConfirmationRouter(view: view)
        let presenter = MyBankAccountConfirmationPresenter(view: view)
        let interactor = MyBankAccountConfirmationInteractor()
        interactor.presenter = presenter
        
        view.interactor = interactor
        view.router = router
        interactor.parameters = parameters
    }
}
