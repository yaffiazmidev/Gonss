//
//  ResellerValidatorController.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 24/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

class ResellerValidatorController: UIViewController {

    private let delegate: ResellerValidatorControllerDelegate
    
    lazy var mainView: ResellerValidatorViewUI = ResellerValidatorViewUI(frame: view.bounds)
   
    init(delegate: ResellerValidatorControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate.didVerifyReseller()
        setupView()
    }
    
    override func loadView() {
        super.loadView()
        view = mainView
    }

    private func setupView() {
        mainView.okayButton.onTap { [weak self] in
            guard let self = self else { return }
            
            self.dismiss(animated: true)
        }
        
        mainView.termAndConditionButton.onTap { [weak self] in
            guard let self = self else { return }
            
            let browserController = AlternativeBrowserController(url: .get(.kipasKipasPrivacyPolicyUrl))
            browserController.bindNavigationBar(.get(.kebijakanPrivasi), false)
            
            let navigate = UINavigationController(rootViewController: browserController)
            navigate.modalPresentationStyle = .fullScreen

            self.present(navigate, animated: true, completion: nil)
        }
    }
}

extension ResellerValidatorController: ResellerValidatorView, ResellerValidatorLoadingErrorView {
    
    func display(_ viewModel: ResellerValidatorViewModel) {
        mainView.configure(verifyFollower:  viewModel.item.follower, verifyTotalPost: viewModel.item.totalPost, verifyShopDisplay: viewModel.item.shopDisplay)
    }
    
    func display(_ viewModel: ResellerValidatorLoadingErrorViewModel) {
        
    }
    
}
