//
//  ExampleControllerViewModel.swift
//  KipasKipas
//
//  Created by kuh on 05/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

class ExampleControllerViewModel: BaseControllerViewModel {
    var exampleText: String = "Tap for loading and show other screen"
    var onExampleLabelTap: ActionHandler.void = {}

    func showExampleLoading() {
        startLoading()
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 2,
            execute: {
                self.stopLoading()
                self.onExampleLabelTap()
            }
        )
    }
}
