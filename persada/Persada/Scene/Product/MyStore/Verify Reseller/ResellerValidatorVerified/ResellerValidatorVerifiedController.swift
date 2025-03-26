//
//  ResellerValidatorVerifiedController.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 06/04/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

final class ResellerValidatorVerifiedController: UIViewController {

    private lazy var mainView: ResellerValidatorVerifiedViewUI = ResellerValidatorVerifiedViewUI(frame: view.bounds)
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
