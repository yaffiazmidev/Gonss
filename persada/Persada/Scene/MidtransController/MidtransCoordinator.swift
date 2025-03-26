//
//  MidtransCoordinator.swift
//  muriafresh
//
//  Created by kuh on 13/02/21.
//  Copyright © 2021 -. All rights reserved.
//

import UIKit

class MidtransCoordinator: Coordinator {
    let controller = MidtransController()
    var onComplete: () -> Void = {}
    var onCancel: () -> Void = {}
    private let urlString: String

    init(presenter: UINavigationController, urlString: String) {
        self.urlString = urlString
        super.init(presenter: presenter)
    }

    override func setupViewModel() {
        let viewModel = MidtransViewModel()
        viewModel.onError = { [weak self] message in
            self?.startErrorHandler(message: message)
        }
        viewModel.onComplete = { [weak self] in
            guard let self = self else { return }
            self.controller.dismiss(animated: true, completion: self.onComplete)
        }
        viewModel.onCancel = { [weak self] in
            guard let self = self else { return }
            self.controller.dismiss(animated: true, completion: self.onCancel)
        }
        viewModel.urlString = urlString
        controller.viewModel = viewModel
    }

    override func start() {
        //presenter.presentFullScreen(controller)
    }
}
