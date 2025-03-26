//
//  Coordinator.swift
//  KipasKipas
//
//  Created by kuh on 05/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import RxSwift


protocol CoordinatorType {
    var presenter: UINavigationController { get }
    func start()
}

class Coordinator: CoordinatorType {
    var presenter: UINavigationController
    
    func setupViewModel() {}
    init(presenter: UINavigationController) {
        self.presenter = presenter
        setupViewModel()
    }

    func start() {
        fatalError("override this")
    }
    
    func startErrorHandler(
        title: String = DefaultValues.string,
        message: String = DefaultValues.string,
        buttonTitle: String = "Tutup",
        handler: @escaping ActionHandler.void = {}
    ) {
        let popup = PopupCoordinator(presenter: presenter)
        popup.title = title
        popup.message = message
        popup.mainButtonHandler = handler
        popup.mainButtonTitle = buttonTitle
        popup.start()
        
    }

    func startErrorHandler(message: String) {
        let popup = PopupCoordinator(presenter: presenter)
        popup.message = message
        popup.mainButtonTitle = "Tutup"
        popup.start()
    }
}
