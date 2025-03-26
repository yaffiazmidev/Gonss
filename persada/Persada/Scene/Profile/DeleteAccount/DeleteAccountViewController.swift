//
//  DeleteAccountViewController.swift
//  KipasKipas
//
//  Created by DENAZMI on 26/01/22.
//

import UIKit
import OneSignal
import KipasKipasPaymentInAppPurchase
import FeedCleeps
import KipasKipasShared
import KipasKipasDonationCart

protocol DeleteAccountViewControllerDisplayLogic: AnyObject {
    func displayDeleteMyAccount()
    func displayFailedDeleteMyAccount()
    func displayLogout(isSuccess: Bool)
}

class DeleteAccountViewController: UIViewController {
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordSecureIcon: UIImageView!
    @IBOutlet weak var deleteAccountReasonTextView: UITextView!
    @IBOutlet weak var passwordContainerView: UIView!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    
    var interactor: DeleteAccountInteractorBusinessLogic?
	var router: DeleteAccountRouterRoutingLogic?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bindNavigationBar(.get(.hapusAkun))
    }

	override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    @objc func handleTapPasswordSecureIcon() {
        passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
        passwordSecureIcon.image = passwordTextField.isSecureTextEntry != true ? UIImage(named: "iconEyeOffOutline") : UIImage(named: "iconEyeOutLine")
    }
    
    func setupView() {
        passwordTextField.delegate = self
        deleteAccountReasonTextView.delegate = self
        bindNavigationBar(.get(.hapusAkun))
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "Password akun",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.placeholder])
        
        deleteAccountReasonTextView.backgroundColor = .white
        deleteAccountReasonTextView.text = "Alasan penghapusan akun."
        deleteAccountReasonTextView.textColor = .placeholder
        deleteAccountReasonTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        passwordSecureIcon.isUserInteractionEnabled = true
        passwordSecureIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapPasswordSecureIcon)))
        
        view.onTap { [weak self] in self?.view.endEditing(true) }
    }
    
    @IBAction func didClickDeleteAccountButton(_ sender: Any) {
        guard let password = passwordTextField.text, !password.isEmpty else {
            let vc = CustomPopUpViewController(title: .get(.fillPasswordFirst), withOption: false)
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
            return
        }
        
        let vc = CustomPopUpViewController(title: .get(.deleteAccountAlert), iconImage: UIImage(named: "icon_warning"), iconHeight: 35, withOption: true, okBtnTitle: .get(.hapusAkun))
        vc.handleTapOKButton = { [weak self] in
            DispatchQueue.main.async { KKLoading.shared.show() }
            self?.interactor?.deleteMyAccount(password: password, reason: self?.deleteAccountReasonTextView.text ?? "")
        }
        
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func didClickCancelButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension DeleteAccountViewController: DeleteAccountViewControllerDisplayLogic {
    func displayDeleteMyAccount() {
        removeUserDataOnPhone()
        DispatchQueue.main.async { KKLoading.shared.hide {
            let vc = CustomPopUpViewController(title: .get(.successDeleteAccount),
                                               withOption: false)
            vc.handleTapOKButton = { [weak self] in
                self?.interactor?.logout()
            }
            
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        } }
    }
    
    func displayFailedDeleteMyAccount() {
        DispatchQueue.main.async { KKLoading.shared.hide() }
        passwordContainerView.setBorderColor = .warning
        passwordErrorLabel.isHidden = false
    }
    
    func displayLogout(isSuccess: Bool) {
        if isSuccess {
            removeUserDataOnPhone()
            DispatchQueue.main.async {
                let vc = SplashScreenViewController().configure()
                vc.configureNotification()
                self.view.window?.switchRootWithPushTo(viewController: vc)
            }
        } else {
            let vc = CustomPopUpViewController(title: .get(.logoutFailed),
                                               withOption: false)
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func removeUserDataOnPhone(){
        print("**** removeUserDataOnPhone")
        removeToken()
        //DataCache.instance.cleanAll()
        InAppPurchasePendingManager.instance.destroy()
        KKFeedLike.instance.reset()
        interactor?.logoutCallFeature()
        DonationCartManager.instance.logout()
        StorySimpleCache.instance.saveStories(stories: [])
        
        // Removing External User Id with Callback Available in SDK Version 2.13.1+
        OneSignal.removeExternalUserId({ results in
            // The results will contain push and email success statuses
            print("External user id update complete with results: ", results!.description)
            // Push can be expected in almost every situation with a success status, but
            // as a pre-caution its good to verify it exists
            if let pushResults = results!["push"] {
                print("Remove external user id push status: ", pushResults)
            }
            // Verify the email is set or check that the results have an email success status
            if let emailResults = results!["email"] {
                print("Remove external user id email status: ", emailResults)
            }
        })
        

    }
}

extension DeleteAccountViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        passwordContainerView.setBorderColor = .gainsboro
        passwordErrorLabel.isHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

extension DeleteAccountViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholder {
            textView.text = nil
            textView.textColor = .contentGrey
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Alasan penghapusan akun."
            textView.textColor = .placeholder
        }
    }
}
