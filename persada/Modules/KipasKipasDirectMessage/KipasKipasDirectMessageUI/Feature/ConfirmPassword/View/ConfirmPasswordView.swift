//
//  ConfirmPasswordView.swift
//  KipasKipasDirectMessage
//
//  Created by DENAZMI on 11/08/23.
//

import UIKit

protocol ConfirmPasswordViewDelegate: AnyObject {
    func didTapOverlayView()
    func didTapConfirmButton(with password: String)
}

class ConfirmPasswordView: UIView {
    
    @IBOutlet weak var passwordContainerStackView: UIStackView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var secureIconStackView: UIStackView!
    @IBOutlet weak var secureIconImageView: UIImageView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var confirmButtonContainerView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var buttonLoadingActivity: UIActivityIndicatorView!
    
    weak var delegate: ConfirmPasswordViewDelegate?
    var handleSuccessVerifyPassword: (() -> Void)?
    var isLoading: Bool? {
        didSet {
            buttonLoadingActivity.isHidden = isLoading == false
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        passwordTextField.becomeFirstResponder()
        handleOnTap()
        passwordTextField.addTarget(self, action: #selector(handleDidChangePassword(_:)), for: .editingChanged)
    }
    
    private func handleOnTap() {
        secureIconStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.passwordTextField.isSecureTextEntry = !self.passwordTextField.isSecureTextEntry
            let isSecurePassword = self.passwordTextField.isSecureTextEntry
            self.secureIconImageView.setImage("ic_eye_\(isSecurePassword ? "off" : "on")_grey")
        }
        
        overlayView.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didTapOverlayView()
        }
        
        confirmButtonContainerView.onTap { [weak self] in
            guard let self = self else { return }
            
            guard self.confirmButtonContainerView.backgroundColor != UIColor(hexString: "#FFA4B5") else { return }
            self.isLoading = true
            

            self.delegate?.didTapConfirmButton(with: self.passwordTextField.text ?? "")
        }
    }
    
    func showError(with message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        confirmButtonContainerView.isUserInteractionEnabled = false
        confirmButtonContainerView.backgroundColor = UIColor(hexString: "#FFA4B5")
    }
    
    func hideError() {
        errorLabel.text = ""
        errorLabel.isHidden = true
        confirmButtonContainerView.isUserInteractionEnabled = true
        confirmButtonContainerView.backgroundColor = UIColor(hexString: "#FF4265")
    }
    
    func overlayAnimation() {
        UIView.animate(withDuration: 0.5, delay: 0) {
            self.overlayView.alpha = 1
        }
    }
    
    @objc private func handleDidChangePassword(_ textField: UITextField) {
        guard let password = textField.text, !password.isEmpty else {
            showError(with: "Harap masukan password")
            return
        }
        
        if password.count < 6 {
            showError(with: "Password minimal 6 karakter")
            return
        }
        
        hideError()
    }
}
