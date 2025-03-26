//
//  EditPhoneNumberViewController.swift
//  KipasKipas
//
//  Created by DENAZMI on 21/03/23.
//

import UIKit

protocol IEditPhoneNumberViewController: AnyObject {
    func displayCheckPhoneNumber(item: VerifyPhoneNumberData?)
    func displayError(with message: String, code: Int)
}

class EditPhoneNumberViewController: UIViewController {
    
    @IBOutlet weak var verificationButton: UIButton!
    @IBOutlet weak var phoneNumberView: KKDefaultTextField!
    
    var interactor: IEditPhoneNumberInteractor!
    var router: IEditPhoneNumberRouter!

    override func viewDidLoad() {
        super.viewDidLoad()
                
        view.onTap { [weak self] in
            guard let self = self else { return }
            self.view.endEditing(true)
        }
        
        phoneNumberView.textField.keyboardType = .numberPad
        phoneNumberView.textField.maxLength = 14
        phoneNumberView.setBorder(width: 1, color: .whiteSmoke)
        phoneNumberView.set(title: "No. Telepon", titleTextColor: .contentGrey, placeholder: "Masukan No. Telepon Baru")
        phoneNumberView.handleTextFieldEditingChanged = { [weak self] textField in
            guard let self = self else { return }
            
            let text = textField.text ?? ""
            text.isValidPhoneNumber() || text.isEmpty ? self.phoneNumberView.hideError() : self.phoneNumberView.showError(.get(.phoneNumberInvalid))
            self.verificationButton.isEnabled = text.isValidPhoneNumber()
            self.verificationButton.setBackgroundColor(text.isValidPhoneNumber() ? .primary : .primaryDisabled, forState: .normal)
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        EditPhoneNumberRouter.configure(controller: self)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @IBAction func didClickVerificationButton(_ sender: Any) {
        DispatchQueue.main.async { KKLoading.shared.show() }
        interactor.phoneNumber = phoneNumberView.textField.text ?? ""
        interactor.checkPhoneNumber()
    }
    
    @IBAction func didClickCancelButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension EditPhoneNumberViewController: IEditPhoneNumberViewController {
    func displayCheckPhoneNumber(item: VerifyPhoneNumberData?) {
        DispatchQueue.main.async { KKLoading.shared.hide() }
        
        guard let item = item else {
            DispatchQueue.main.async { Toast.share.show(message: "Opss data tidak ditemukan, silahkan coba lagi") }
            return
        }
        
        if item.status ?? false == true {
            router.presentCustomPopUpViewController(title: "Nomor telepon sudah digunakan!",
                                                    description: "Coba nomor yang lain karena nomor yang ingin kamu gunakan sudah digunakan oleh pengguna lain.")
            return
        }
        
        router.navigateToOTPMethodOption(phoneNumber: phoneNumberView.textField.text ?? "",
                                         handleEditPhoneNumberCallback: { [weak self] result in
            guard let self = self else { return }
            
            let statusCode = result["code"] as? Int
                        
            switch statusCode {
            case 1000:
                self.navigationController?.popViewController(animated: true)
                DispatchQueue.main.async { Toast.share.show(message: "Akun berhasil diperbaharui") }
            case 4041:
                DispatchQueue.main.async { Toast.share.show(message: "Kode OTP tidak sesuai") }
            case 4042:
                DispatchQueue.main.async { Toast.share.show(message: "Kode OTP telah kadaluarsa") }
            case 4001:
                DispatchQueue.main.async { Toast.share.show(message: "Kamu sudah 3x memasukan kode yang salah") }
            default:
                self.router.presentCustomPopUpViewController(title: "Error", description: "Error \(statusCode ?? 404) with message \((result["code"] as? String) ?? "Error not found!")")
                break
            }
        })
    }
    
    func displayError(with message: String, code: Int) {
        DispatchQueue.main.async { KKLoading.shared.hide() }
        switch code {
        case 4200:
            router.presentCustomPopUpViewController(title: "Nomor telepon sudah digunakan!", description: "Coba nomor yang lain karena nomor yang ingin kamu gunakan sudah digunakan oleh pengguna lain.")
        case 5006:
            router.presentCustomPopUpViewController(title: "Tidak bisa merubah nomor telepon!", description: "Kamu tercatat sudah melakukan perubahan pada nomor telepon, tunggu 30 hari sejak perubahan nomor telepon terakhir jika ingin melakukan perubahan kembali.")
        case 5007:
            router.presentCustomPopUpViewController(title: "Sudah 3x merubah No. Telepone", description: "Kamu tidak bisa merubah No. Telepone karena kamu sudah melakukan 3x perubahan pada No. Telepone, hubungi Customer Service Kipaskipas jika memang diperlukan.")
        default:
            DispatchQueue.main.async { Toast.share.show(message: message) }
        }
    }
}
