//
//  ExampleCoordinator.swift
//  KipasKipas
//
//  Created by kuh on 05/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

class ExampleCoordinator: Coordinator {
    private let controller = ExampleController()
    var otherExampleCoordinator: ExampleCoordinator?

    override func setupViewModel() {
        let viewModel = ExampleControllerViewModel()
        viewModel.onExampleLabelTap = showOtherCoordinator
        controller.viewModel = viewModel
    }

    override func start() {
        presenter.setNavigationBarHidden(false, animated: true)
        //presenter.push(controller)
    }

    private func showOtherCoordinator() {
        otherExampleCoordinator = ExampleCoordinator(presenter: presenter)
        otherExampleCoordinator?.start()
    }
}
