//
//  PopupCoordinator.swift
//  KipasKipas
//
//  Created by kuh on 05/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class PopupCoordinator {
    var presenter: UINavigationController
    var title: String = DefaultValues.string
    var message: String = DefaultValues.string
    var mainButtonTitle: String = DefaultValues.string
    var mainButtonHandler: ActionHandler.void = {}
    
    init(presenter: UINavigationController) {
        self.presenter = presenter
    }
    
    func start() {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: mainButtonTitle, style: .default, handler: { [weak self] _ in
            self?.mainButtonHandler()
            self?.presenter.dismiss(animated: true, completion: nil)
        }))
        presenter.present(alert, animated: true)
    }
}
