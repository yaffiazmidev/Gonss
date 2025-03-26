//
//  StoryContentController.swift
//  KipasKipas
//
//  Created by DENAZMI on 23/01/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import UIKit

class StoryContentController: UIViewController {
    
    lazy var mainView: StoryContentView = {
        let view = StoryContentView()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        view = mainView
    }
}
