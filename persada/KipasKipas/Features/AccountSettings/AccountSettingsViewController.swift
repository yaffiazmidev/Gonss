//
//  AccountSettingsViewController.swift
//  KipasKipas
//
//  Created by DENAZMI on 05/03/23.
//

import UIKit

protocol IAccountSettingsViewController: AnyObject {
    func displayCheckUsername()
    func displayCheckUsernameError(with message: String, code: Int)
    func displayCheckPhoneNumber()
    func displayCheckPhoneNumberError(with message: String, code: Int)
    
    func displayReferralCode(referralCode: String?)
    
}

class AccountSettingsViewController: UIViewController {
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var mobilePhoneLabel: UILabel!
    
    @IBOutlet weak var reffCodeLabel: UILabel!
    
    var interactor: IAccountSettingsInteractor!
    var router: IAccountSettingsRouter!

	override func viewDidLoad() {
        super.viewDidLoad()
        
        reffCodeLabel.isHidden = true
        
        
        
        overrideUserInterfaceStyle = .light
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: .get(.iconEllipsis))?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(onClickEllipse(_:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupComponent()
        
        interactor.checkProfile()
    }
    
    private func setupComponent() {
        
        emailLabel.text = getEmail()
        usernameLabel.text = getUsername()
        mobilePhoneLabel.text = "\(getPhone().first != "0" ? "+" : "")\(getPhone())"
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        AccountSettingsRouter.configure(controller: self)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @objc func onClickEllipse(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Please Select an Option", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: .get(.hapusAkun), style: .destructive , handler:{ [weak self] (UIAlertAction) in
            let vc = DeleteAccountRouter.create()
            self?.navigationController?.pushViewController(vc, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func didClickEditUsernameButton(_ sender: Any) {
        DispatchQueue.main.async { KKLoading.shared.show() }
        interactor.checkUsername()
    }
    
    @IBAction func didClickEditMobilePhoneButton(_ sender: Any) {
        DispatchQueue.main.async { KKLoading.shared.show() }
        interactor.checkPhoneNumber()
    }
    
    @IBAction func didClickEditPasswordButton(_ sender: Any) {
        router.navigateToEditPassword()
    }
}

extension AccountSettingsViewController: IAccountSettingsViewController {
    
    func displayReferralCode(referralCode: String?) {
        if let referralCode = referralCode {
            reffCodeLabel.text = ("Refferal Code : \(referralCode)")
            reffCodeLabel.isHidden = false
        }
    }
    
    func displayCheckUsername() {
        setupComponent()
        DispatchQueue.main.async { KKLoading.shared.hide { [weak self] in
            guard let self = self else { return }
            self.router.navigateToEditUsername()
        }}
    }
    
    func displayCheckUsernameError(with message: String, code: Int) {
        DispatchQueue.main.async { KKLoading.shared.hide() }
        switch code {
        case 5006:
            router.presentCustomPopUpViewController(title: "Tidak bisa merubah username!",
                                                    description: "Kamu tercatat sudah melakukan perubahan pada username, tunggu 30 hari sejak perubahan username terakhir jika ingin melakukan perubahan kembali.")
        case 5007:
            router.presentCustomPopUpViewController(title: "Sudah 3x merubah username",
                                                    description: "Kamu tidak bisa merubah username karena kamu sudah melakukan 3x perubahan pada username, hubungi Customer Service Kipaskipas jika memang diperlukan.")
        default:
            DispatchQueue.main.async { Toast.share.show(message: message) }
        }
    }
    
    func displayCheckPhoneNumber() {
        setupComponent()
        DispatchQueue.main.async { KKLoading.shared.hide { [weak self] in
            guard let self = self else { return }
            self.router.navigateToEditPhoneNumber()
        }}
    }
    
    func displayCheckPhoneNumberError(with message: String, code: Int) {
        DispatchQueue.main.async { KKLoading.shared.hide() }
        switch code {
        case 5006:
            router.presentCustomPopUpViewController(
                title: "Tidak bisa merubah nomor telepon!",
                description: "Kamu tercatat sudah melakukan perubahan pada nomor telepon, tunggu 30 hari sejak perubahan nomor telepon terakhir jika ingin melakukan perubahan kembali."
            )
        case 5007:
            router.presentCustomPopUpViewController(
                title: "Sudah 3x merubah No. Telepone",
                description: "Kamu tidak bisa merubah No. Telepone karena kamu sudah melakukan 3x perubahan pada No. Telepone, hubungi Customer Service Kipaskipas jika memang diperlukan."
            )
        default:
            DispatchQueue.main.async { Toast.share.show(message: message) }
        }
    }
}
