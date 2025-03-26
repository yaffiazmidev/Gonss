//
//  EditUsernameViewController.swift
//  KipasKipas
//
//  Created by DENAZMI on 12/03/23.
//

import UIKit

protocol IEditUsernameViewController: AnyObject {
	func displayUpdateUsername()
    func displayError(with message: String, code: Int)
}

class EditUsernameViewController: UIViewController {
    
    @IBOutlet weak var usernameFieldContainerView: UIView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var notJustNumbersValidIcon: UIImageView!
    @IBOutlet weak var minMaxValidIcon: UIImageView!
    @IBOutlet weak var saveUsernameButton: UIButton!
    @IBOutlet weak var allowCharValidIcon: UIImageView!
    
    var interactor: IEditUsernameInteractor!
	var router: IEditUsernameRouter!

	override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        
        usernameTextField.delegate = self
        usernameTextField.addTarget(self, action: #selector(didChangeUsername(_:)), for: .editingChanged)
        
        view.onTap { [weak self] in
            guard let self = self else { return }
            self.view.endEditing(true)
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        EditUsernameRouter.configure(controller: self)
    }
    
    @objc private func didChangeUsername(_ textField: UITextField) {
        guard let text = textField.text, !text.isEmpty else {
            notJustNumbersValidIcon.image = UIImage(named: "ic_circle_check_fill_grey")
            allowCharValidIcon.image = UIImage(named: "ic_circle_check_fill_grey")
            return
        }
        
        saveUsernameButton.backgroundColor = text.isValidUsername() ? .primary : .primaryDisabled
        saveUsernameButton.isEnabled = text.isValidUsername()
        
        minMaxValidIcon.image = UIImage(named: "ic_circle_check_fill_\(text.count >= 4 ? "green" : "grey")")
        if text.count < 4 { return }
        
        notJustNumbersValidIcon.image = UIImage(named: "ic_circle_check_fill_\(!text.isOnlyNumber() ? "green" : "grey")")
        if text.isOnlyNumber() { return }
        
        let isAllowCharValidIcon = text.first != "_" && text.last != "_" && text.first != "." && text.last != "."
        allowCharValidIcon.image = UIImage(named: "ic_circle_check_fill_\(isAllowCharValidIcon ? "green" : "grey")")
        if !isAllowCharValidIcon { return }
    }
    
    @IBAction func didClickCancelButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didClickSaveButton(_ sender: Any) {
        guard let username = usernameTextField.text, username.isValidUsername() else {
            DispatchQueue.main.async { Toast.share.show(message: "Username yang anda masukan tidak valid")}
            return
        }
        
        DispatchQueue.main.async { KKLoading.shared.show() }
        interactor.username = username
        interactor.updateUsername()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension EditUsernameViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        usernameFieldContainerView.setBorderColor = .secondary
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        usernameFieldContainerView.setBorderColor = .whiteSmoke
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        notJustNumbersValidIcon.image = UIImage(named: "ic_circle_check_fill_grey")
        minMaxValidIcon.image = UIImage(named: "ic_circle_check_fill_grey")
        saveUsernameButton.backgroundColor = .primaryDisabled
        saveUsernameButton.isEnabled = false
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz1234567890_.")
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
}

extension EditUsernameViewController: IEditUsernameViewController {
    func displayUpdateUsername() {
        DispatchQueue.main.async { KKLoading.shared.hide() }
        navigationController?.popViewController(animated: true)
    }
    
    func displayError(with message: String, code: Int) {
        DispatchQueue.main.async { KKLoading.shared.hide() }
        switch code {
        case 4200:
            router.presentCustomPopUpViewController(title: "Username sudah digunakan!", description: "Sudah ada akun yang menggunakan username yang baru saja kamu tulis, gunakan username lain agar bisa melanjutkan proses ini.")
        case 5006:
            router.presentCustomPopUpViewController(title: "Tidak bisa merubah username!", description: "Kamu tercatat sudah melakukan perubahan pada username, tunggu 30 hari sejak perubahan username terakhir jika ingin melakukan perubahan kembali.")
        case 5007:
            router.presentCustomPopUpViewController(title: "Sudah 3x merubah username", description: "Kamu tidak bisa merubah username karena kamu sudah melakukan 3x perubahan pada username, hubungi Customer Service Kipaskipas jika memang diperlukan.")
        default:
            DispatchQueue.main.async { Toast.share.show(message: message) }
        }
    }
}
