//
//  ShopComingSoonController.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 25/03/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import UIKit

class ShopComingSoonController: UIViewController {
    
    private let mainView: ShopComingSoonView
    
    public init() {
        mainView = ShopComingSoonView()
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        super.loadView()
        view = mainView
    }
}
