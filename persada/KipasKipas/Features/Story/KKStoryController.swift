//
//  KKStoryController.swift
//  KipasKipas
//
//  Created by DENAZMI on 23/01/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import UIKit
import KipasKipasShared

final class KKStoryController: KKPageViewController, NavigationAppearance {

    private let hud = KKProgressHUD()
    private lazy var emptyController = UIViewController()
        
    public override init(
        childControllers: [UIViewController] = [],
        navigationOrientation: UIPageViewController.NavigationOrientation = .horizontal
    ) {
        super.init(navigationOrientation: .horizontal)
    }
        
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    lazy var mainView: StoryContentView = {
        let view = StoryContentView()
        return view
    }()
        
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        hud.show(in: view)
    }

    override func loadView() {
        view = mainView
    }
    
    // MARK: API
    public func set(_ childControllers: [StoryContentController]) {
        hud.dismiss()
        
        if childControllers.isEmpty {
            setupNavigationBar(color: .black, tintColor: .white)
            navigationController?.setNavigationBarHidden(false, animated: false)
            add(emptyController, ignoreSafeArea: false, animated: false)
            return
        }
        
        setViewControllers(
            childControllers,
            direction: .forward,
            animated: true
        )
    }
}
