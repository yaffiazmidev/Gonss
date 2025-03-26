//
//  ExampleController.swift
//  KipasKipas
//
//  Created by kuh on 05/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class ExampleController: BaseController, Controller {
    @IBOutlet weak var labelExample: UILabel!
    var viewModel = ExampleControllerViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoading()
        labelExample.text = viewModel.exampleText
        labelExample.textColor = .black
        labelExample.onTap(action: viewModel.showExampleLoading)
    }
}
