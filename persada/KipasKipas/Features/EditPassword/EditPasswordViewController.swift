//
//  EditPasswordViewController.swift
//  KipasKipas
//
//  Created by DENAZMI on 14/03/23.
//

import UIKit
import IQKeyboardManagerSwift

protocol IEditPasswordViewController: AnyObject {
	func displayUpdatePassword(phoneNumber: String)
    func displayError(with message: String, code: Int)
}

class EditPasswordViewController: UIViewController {
    
    @IBOutlet weak var oldPasswordView: KKDefaultTextField!
    @IBOutlet weak var newPasswordView: KKDefaultTextField!
    @IBOutlet weak var confirmPasswordView: KKDefaultTextField!
    @IBOutlet weak var minMaxValidIcon: UIImageView!
    @IBOutlet weak var uniqPasswordValidIcon: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    
    var interactor: IEditPasswordInteractor!
    var router: IEditPasswordRouter!
    private let checkIcon: UIImage? = UIImage(named: "ic_circle_check_fill_green")
    private let uncheckIcon: UIImage? = UIImage(named: "ic_circle_check_fill_grey")
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 15
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        
        handleSetupOldPasswordView()
        handleSetupNewPasswordView()
        handleSetupConfirmPasswordView()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        EditPasswordRouter.configure(controller: self)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func handleChecksPasswordsIsMatch() {
        if confirmPasswordView.textField.text?.isEmpty == true {
            return
        }
        confirmPasswordView.textField.text != newPasswordView.textField.text
        ? confirmPasswordView.showError("Password tidak sesuai") : confirmPasswordView.hideError()
    }
    
    private func handleSetupOldPasswordView() {
        oldPasswordView.isAllowWhitespaces = false
        oldPasswordView.textField.maxLength = 20
        oldPasswordView.setBorder(width: 1, color: .whiteSmoke)
        oldPasswordView.set(title: "Password Lama", titleTextColor: .contentGrey, placeholder: "Password lama", rightIcon: UIImage(named: .get(.iconEyeOffOutline)), isSecureTextEntry: true)
        
        oldPasswordView.handleTapRightIcon = { [weak self] in
            guard let self = self else { return }
            
            let isSecureTextEntry = self.oldPasswordView.textField.isSecureTextEntry
            self.oldPasswordView.textField.isSecureTextEntry = !isSecureTextEntry
            self.oldPasswordView.rightIcon = UIImage(named: .get(isSecureTextEntry ? .iconEyeOffOutline : .iconEyeOutLine))
        }
        
        oldPasswordView.handleTextFieldEditingChanged = { [weak self] textField in
            guard let self = self else { return }
                        
            textField.text == "" ? self.oldPasswordView.showError("Password lama tidak boleh kosong") : self.oldPasswordView.hideError()
            
            guard let confirmPassword = self.confirmPasswordView.textField.text, !confirmPassword.isEmpty,
                  let newPassword = self.newPasswordView.textField.text, !newPassword.isEmpty,
                  let oldPassword = self.oldPasswordView.textField.text, !oldPassword.isEmpty else {
                self.saveButton(isEnable: false)
                return
            }
            self.saveButton(isEnable: true)
        }
    }
    
    private func handleSetupNewPasswordView() {
        newPasswordView.isAllowWhitespaces = false
        newPasswordView.textField.maxLength = 20
        newPasswordView.setBorder(width: 1, color: .whiteSmoke)
        newPasswordView.set(title: "Password Baru", titleTextColor: .contentGrey, placeholder: "Input password baru", rightIcon: UIImage(named: .get(.iconEyeOffOutline)), isSecureTextEntry: true)
        
        newPasswordView.handleTapRightIcon = { [weak self] in
            guard let self = self else { return }
            
            let isSecureTextEntry = self.newPasswordView.textField.isSecureTextEntry
            self.newPasswordView.textField.isSecureTextEntry = !isSecureTextEntry
            self.newPasswordView.rightIcon = UIImage(named: .get(isSecureTextEntry ? .iconEyeOffOutline : .iconEyeOutLine))
        }
        
        newPasswordView.handleTextFieldEditingChanged = { [weak self] textField in
            guard let self = self else { return }
            
            guard let text = textField.text else { return }
            
            self.minMaxValidIcon.image = text.count >= 8 ? self.checkIcon : self.uncheckIcon
            self.uniqPasswordValidIcon.image = text.isUniqPassword() ? self.checkIcon : self.uncheckIcon
            self.handleChecksPasswordsIsMatch()
            self.saveButton(isEnable: text.isUniqPassword() && text.count >= 8 && (confirmPasswordView.textField.text?.count ?? 0) >= 8)
        }
    }
    
    private func handleSetupConfirmPasswordView() {
        confirmPasswordView.isAllowWhitespaces = false
        confirmPasswordView.textField.maxLength = 20
        confirmPasswordView.setBorder(width: 1, color: .whiteSmoke)
        confirmPasswordView.set(title: "Konfirmasi Password", titleTextColor: .contentGrey, placeholder: "Konfirmasi", rightIcon: UIImage(named: .get(.iconEyeOffOutline)), isSecureTextEntry: true)
        
        confirmPasswordView.handleTapRightIcon = { [weak self] in
            guard let self = self else { return }
            
            let isSecureTextEntry = self.confirmPasswordView.textField.isSecureTextEntry
            self.confirmPasswordView.textField.isSecureTextEntry = !isSecureTextEntry
            self.confirmPasswordView.rightIcon = UIImage(named: .get(isSecureTextEntry ? .iconEyeOffOutline : .iconEyeOutLine))
        }
        
        confirmPasswordView.handleTextFieldEditingChanged = { [weak self] textField in
            guard let self = self else { return }
            
            guard let text = textField.text else { return }
            
            self.handleChecksPasswordsIsMatch()
            let isUniqPassword = text.isUniqPassword()
            self.saveButton(isEnable: isUniqPassword && text.count >= 8 && (newPasswordView.textField.text?.count ?? 0) >= 8)
        }
    }
    
    private func saveButton(isEnable: Bool) {
        saveButton.setBackgroundColor(isEnable ? .primary : .primaryDisabled, forState: .normal)
        saveButton.isEnabled = isEnable
    }
    
    private func checkAllPasswordField() {
        guard let confirmPassword = confirmPasswordView.textField.text, !confirmPassword.isEmpty,
              let newPassword = newPasswordView.textField.text, !newPassword.isEmpty,
              let oldPassword = oldPasswordView.textField.text, !oldPassword.isEmpty else {
            saveButton(isEnable: false)
            return
        }
        
        let passwordIsMatch = confirmPassword == newPassword
        passwordIsMatch ? confirmPasswordView.hideError() : confirmPasswordView.showError("Password tidak sesuai")
        saveButton(isEnable: passwordIsMatch)
    }
    
    @IBAction func didClickCancelButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didClickSavePasswordButton(_ sender: Any) {
        guard let oldPassword = oldPasswordView.textField.text, !oldPassword.isEmpty else {
            oldPasswordView.showError("Password lama tidak boleh kosong")
            saveButton(isEnable: false)
            return
        }
        
        interactor.oldPassword = oldPassword
        interactor.newPassword = newPasswordView.textField.text ?? ""
        
        oldPasswordView.hideError()
        DispatchQueue.main.async { KKLoading.shared.show() }
        interactor.updatePassword()
    }
}

extension EditPasswordViewController: IEditPasswordViewController {
    func displayUpdatePassword(phoneNumber: String) {
        DispatchQueue.main.async { KKLoading.shared.hide { [weak self] in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
        }}
    }
    
    func displayError(with message: String, code: Int) {
        DispatchQueue.main.async { KKLoading.shared.hide() }
        switch code {
        case 2224:
            oldPasswordView.showError("Password lama yang anda masukan salah")
        case 2200:
            oldPasswordView.showError("Anda sudah 5x salah memasukan password lama, silahkan tunggu 10 menit lagi")
        default:
            DispatchQueue.main.async {
                Toast.share.show(message: message)
            }
        }
    }
}
