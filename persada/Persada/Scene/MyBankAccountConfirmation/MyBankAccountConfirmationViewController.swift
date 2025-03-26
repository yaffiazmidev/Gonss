//
//  MyBankAccountConfirmationViewController.swift
//  KipasKipas
//
//  Created by Yaffi Azmi on 25/10/21.
//

import UIKit
import KipasKipasShared

protocol MyBankAccountConfirmationViewControllerDisplayLogic: AnyObject {
    func displaySuccessDeleteBankAccount()
    func displayFailedDeleteBankAccount(_ message: String)
}

class MyBankAccountConfirmationViewController: BaseController, AlertDisplayer {
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var showPasswordIcon: UIImageView!
    var interactor: MyBankAccountConfirmationInteractorBusinessLogic!
	var router: MyBankAccountConfirmationRouterRoutingLogic!
    
    private let hud = CPKProgressHUD.progressHUD(style: .loading(text: nil))
    
    var id: String = ""
    
    var handleSuccessDeleteBankAccount: (() -> Void)?

	override func viewDidLoad() {
        super.viewDidLoad()
        title = String.get(.confirm)
        setupNavbar()
        
        showPasswordIcon.onTap {
            self.showPasswordIcon.image = !self.passwordTextField.isSecureTextEntry ? #imageLiteral(resourceName: "iconEyeOffOutline") : #imageLiteral(resourceName: "iconEyeOutLine")
            self.passwordTextField.isSecureTextEntry = !self.passwordTextField.isSecureTextEntry
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        MyBankAccountConfirmationRouter.configure(view: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func didCLickConfirmButton(_ sender: Any) {
        hud.show(in: view)
        guard let password = passwordTextField.text, !password.isEmpty else {
            hud.dismiss()
            displayAlert(with: .get(.error), message: .get(.pleaseFillPassword), actions: [UIAlertAction(title: "OK", style: .default)])
            return
        }
        interactor.verifyPAssword(password: password, id: id)
    }
}

extension MyBankAccountConfirmationViewController: MyBankAccountConfirmationViewControllerDisplayLogic {
    func displaySuccessDeleteBankAccount() {
        hud.dismiss()
        navigationController?.popViewController(animated: true)
        handleSuccessDeleteBankAccount?()
    }
    
    func displayFailedDeleteBankAccount(_ message: String) {
        hud.dismiss()
        displayAlert(with: .get(.error), message: message, actions: [UIAlertAction(title: "OK", style: .default)])
    }
}
