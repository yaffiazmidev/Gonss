//
//  AuthPopUpViewController.swift
//  KipasKipas
//
//  Created by batm batmandiri on 19/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import FeedCleeps

class AuthPopUpViewController: UIViewController, PopUpViewDelegate {
    
    private var mainView: AuthPopUpView
    private var router: AuthPopUpRouting!
    var dismiss: (() -> ())?
    var handleWhenNotLogin: (() -> Void)?
    
    required init(mainView: AuthPopUpView) {
        self.mainView = mainView
        
        super.init(nibName: nil, bundle: nil)
        router = AuthPopUpRouter(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        mainView.delegate = self
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed {
            if let tabBar = presentingViewController as? MainTabController {
                if tabBar.selectedIndex == 1 {
                    dismiss?()
                }
            }
            NotificationCenter.default.post(name: .shouldResumePlayer, object: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: .shouldPausePlayer, object: nil)
    }
    
    override func loadView() {
        view = mainView
    }
    
    func whenLoginLabelCliked() {
        NotificationCenter.default.post(name: UIScene.willDeactivateNotification, object: nil)
        router.routeTo(.loginScene)
    }
    
    func dismissCurrentPopUp() {
//        router.routeTo(.dismissPopUp)
        handleWhenNotLogin?()
    }
}
