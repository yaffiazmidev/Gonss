//
//  ConfirmPasswordViewController.swift
//  KipasKipas
//
//  Created by DENAZMI on 02/02/23.
//

import UIKit
import IQKeyboardManagerSwift

protocol IConfirmPasswordViewController: AnyObject {
    func displaySuccessVerifyPassword()
    func displayError(message: String, code: Int)
}

class ConfirmPasswordViewController: UIViewController {
    
    @IBOutlet weak var passwordContainerStackView: UIStackView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var secureIconStackView: UIStackView!
    @IBOutlet weak var secureIconImageView: UIImageView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var confirmButtonContainerView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var buttonLoadingActivity: UIActivityIndicatorView!
    
    var interactor: IConfirmPasswordInteractor!
    var handleSuccessVerifyPassword: (() -> Void)?
    private var isLoading: Bool? {
        didSet {
            buttonLoadingActivity.isHidden = isLoading == false
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        overrideUserInterfaceStyle = .light
        setupIQKeyboardManager()
        overlayAnimation()
    }

	override func viewDidLoad() {
        super.viewDidLoad()
        
        handleOnTap()
        passwordTextField.addTarget(self, action: #selector(handleDidChangePassword(_:)), for: .editingChanged)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func handleOnTap() {
        secureIconStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.passwordTextField.isSecureTextEntry = !self.passwordTextField.isSecureTextEntry
            self.secureIconImageView.image = UIImage(named: .get( self.passwordTextField.isSecureTextEntry ? .iconEyeOffOutline : .iconEyeOutLine))
        }
        
        overlayView.onTap { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true)
        }
        
        confirmButtonContainerView.onTap { [weak self] in
            guard let self = self else { return }
            
            guard self.confirmButtonContainerView.backgroundColor == .primary else { return }
            self.isLoading = true
            self.interactor.verifyPassword(self.passwordTextField.text ?? "")
        }
    }
    
    private func showError(with message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        confirmButtonContainerView.isUserInteractionEnabled = false
        confirmButtonContainerView.backgroundColor = .primaryDisabled
    }
    
    private func hideError() {
        errorLabel.text = ""
        errorLabel.isHidden = true
        confirmButtonContainerView.isUserInteractionEnabled = true
        confirmButtonContainerView.backgroundColor = .primary
    }
    
    private func setupIQKeyboardManager() {
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 100
    }
    
    private func overlayAnimation() {
        UIView.animate(withDuration: 0.5, delay: 0) {
            self.overlayView.alpha = 1
        }
    }
    
    @objc private func handleDidChangePassword(_ textField: UITextField) {
        guard let password = textField.text, !password.isEmpty else {
            showError(with: .get(.pleaseFillPassword))
            return
        }
        
        if password.count < 6 {
            showError(with: .get(.passwordMin6Char))
            return
        }
        
        hideError()
    }
}

extension ConfirmPasswordViewController: IConfirmPasswordViewController {
    func displaySuccessVerifyPassword() {
        isLoading = false
        dismiss(animated: true) {
            self.handleSuccessVerifyPassword?()
        }
    }
    
    func displayError(message: String, code: Int) {
        isLoading = false
        
        switch code {
        case 2200:
            showError(with: "Kamu sudah 5x memasukan password yang salah, tunggu 10 menit kemudian untuk mencoba kembali")
        case 2224:
            showError(with: "Password yang anda masukan salah")
        default:
            showError(with: "Opss.. terjadi kesalahan, silahkan coba lagi")
        }
    }
}

extension ConfirmPasswordViewController {
    func configure() {
        let presenter = ConfirmPasswordPresenter(controller: self)
        let network = DIContainer.shared.apiDataTransferService
        interactor = ConfirmPasswordInteractor(presenter: presenter, network: network)
    }
}
