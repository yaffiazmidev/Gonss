//
//  ConfirmPasswordViewController.swift
//  KipasKipasDirectMessage
//
//  Created by DENAZMI on 11/08/23.
//

import UIKit

protocol IConfirmPasswordViewController: AnyObject {
    func displayConfirmation()
    func displayError(statusCode: String, message: String)
}

class ConfirmPasswordViewController: UIViewController {
    
    private lazy var mainView: ConfirmPasswordView = {
        let view = ConfirmPasswordView().loadViewFromNib() as! ConfirmPasswordView
        view.delegate = self
        return view
    }()
    
	var interactor: IConfirmPasswordInteractor!
	var router: IConfirmPasswordRouter!
    var dismissAction: (() -> Void)?
        
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func loadView() {
        super.loadView()
        view = mainView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        overrideUserInterfaceStyle = .light
        mainView.overlayAnimation()
    }
}

extension ConfirmPasswordViewController: ConfirmPasswordViewDelegate {
    func didTapOverlayView() {
        dismiss(animated: true)
    }
    
    func didTapConfirmButton(with password: String) {
        interactor.verify(with: password)
    }
}

extension ConfirmPasswordViewController: IConfirmPasswordViewController {
    
    func displayConfirmation() {
        self.dismiss(animated: true) {
            self.dismissAction?()
        }
    }
    
    func displayError(statusCode: String, message: String) {
        DispatchQueue.main.async {
            self.mainView.isLoading = false
            if statusCode == "2200" {
                self.mainView.showError(with: .get(.passwordFreeze))
            } else if statusCode == "2225" {
                self.mainView.showError(with: .get(.passwordInvalid))
            }
        }
    }
}
