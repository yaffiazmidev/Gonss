//
//  AddGopayAccountViewController.swift
//  KipasKipas
//
//  Created by DENAZMI on 10/04/23.
//

import UIKit

protocol IAddGopayAccountViewController: AnyObject {
    func displayCheckGopay(account: RemoteCheckGopayAccountData?)
    func displayError(message: String, code: Int)
}

class AddGopayAccountViewController: UIViewController {
    @IBOutlet weak var phoneNumberView: KKDefaultTextField!
    @IBOutlet weak var accountContainerView: UIStackView!
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var accountNumberLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    
    var interactor: IAddGopayAccountInteractor!
    var router: IAddGopayAccountRouter!
    
    var handleSendOTPCallback: ((AccountDestinationModel?) -> Void)?
    var gopayAccount: AccountDestinationModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        title = "Tambah Akun Gopay"
//        setupNavbarForPresent()
        
//        navigationController?.navigationBar.layer.shadowColor   = UIColor.black.cgColor
//        navigationController?.navigationBar.layer.shadowOpacity = 0.2
//        navigationController?.navigationBar.layer.shadowOffset  = CGSize.zero
//        navigationController?.navigationBar.layer.shadowRadius  = 2
        
        phoneNumberView.textField.keyboardType = .numberPad
        phoneNumberView.textField.maxLength = 13
        phoneNumberView.setBorder(width: 1, color: .whiteSmoke)
        phoneNumberView.set(title: "Nomor Gopay", titleTextColor: .contentGrey, placeholder: "Masukan nomor Gopay")
        phoneNumberView.handleTextFieldEditingChanged = { [weak self] textField in
            guard let self = self else { return }
            
            let text = textField.text ?? ""
            text.isValidPhoneNumber() || text.isEmpty ? self.phoneNumberView.hideError() : self.phoneNumberView.showError(.get(.phoneNumberInvalid))
            self.checkButton.isEnabled = text.isValidPhoneNumber()
            self.checkButton.alpha = text.isValidPhoneNumber() ? 1.0 : 0.5
        }
    }
    
    @IBAction func didClickSendOTPButton(_ sender: Any) {
//        dismiss(animated: true) {
//            self.handleSendOTPCallback?(self.gopayAccount)
//        }
        navigationController?.popViewController(animated: false)
        handleSendOTPCallback?(gopayAccount)
    }
    
    @IBAction func didClickCheckGopayAccountButton(_ sender: Any) {
        DispatchQueue.main.async { KKLoading.shared.show() }
        interactor.phoneNumber = phoneNumberView.textField.text ?? ""
        interactor.checkGopayAccount()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        AddGopayAccountRouter.configure(controller: self)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        navigationController?.interactivePopGestureRecognizer?.delegate = self
//        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension AddGopayAccountViewController: IAddGopayAccountViewController {
    func displayCheckGopay(account: RemoteCheckGopayAccountData?) {
        DispatchQueue.main.async { KKLoading.shared.hide() }
        checkButton.isHidden = true
        accountContainerView.isHidden = false
        accountNameLabel.text = account?.accountName ?? ""
        accountNumberLabel.text = account?.accountNumber ?? ""
        gopayAccount = account.map({ AccountDestinationModel(id: "gopay",
                                                             namaBank: $0.bankName,
                                                             noRek: $0.accountNumber,
                                                             nama: $0.accountName,
                                                             swiftCode: "gopay",
                                                             withdrawFee: 1000) })
    }
    
    func displayError(message: String, code: Int) {
        DispatchQueue.main.async { KKLoading.shared.hide() }
        if message.contains("Account does not exist") {
            phoneNumberView.showError("Nomor belum terdaftar sebagai akun gopay")
            checkButton.isEnabled = false
            checkButton.alpha = 0.5
        } else {
            DispatchQueue.main.async { Toast.share.show(message: "Oppss terjadi kesalahan, silahkan coba lagi..") }
        }
    }
}

extension AddGopayAccountViewController: UIGestureRecognizerDelegate { }
