//
//  ConfirmViewController.swift
//  KipasKipas
//
//  Created by iOS Dev on 28/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import KipasKipasShared

class ConfirmViewController: UIViewController, AlertDisplayer {
    
    @IBOutlet weak var textField: UITextField!
    
    let disposeBag = DisposeBag()
    var viewModel: WithdrawalBalanceViewModel?
    var biayaPenarikan = ""
    var isGopay: Bool = false
    
    private let hud = CPKProgressHUD.progressHUD(style: .loading(text: nil))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Konfirmasi"
        registerObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavbar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createRightViewImage()
    }
    
    func registerObserver() {
        guard let viewModel = viewModel else { return }
        viewModel.isLoading.subscribe(onNext: { [weak self] isLoading in
            guard let isLoading = isLoading else { return }
            if isLoading {
                guard let view = self?.view else { return }
                self?.hud.show(in: view)
                return
            } else {
                self?.hud.dismiss()
            }
        }).disposed(by: disposeBag)
        
        viewModel.errorMessage.subscribe(onNext: { [weak self] message in
            guard let message = message else { return }
            if !message.isEmpty {
                let action = UIAlertAction(title: "OK", style: .default)
                self?.displayAlert(with: .get(.error), message: message, actions: [action])
            }
        }).disposed(by: disposeBag)
        
        viewModel.isSuccessWithdrawal.subscribe(onNext: { [weak self] _ in
            guard let isSuccess = viewModel.isSuccessWithdrawal.value else { return }
            if isSuccess {
                self?.navigateToSuccessPage()
            }
        }).disposed(by: disposeBag)
    }
    
    func createRightViewImage() {
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        imageView.image = UIImage(named: "iconEye")
        imageView.center = rightView.center
        rightView.addSubview(imageView)
        rightView.onTap {
            self.textField.isSecureTextEntry = !self.textField.isSecureTextEntry
        }
        
        textField.rightView = rightView
        textField.rightViewMode = .always
    }
    
    func navigateToSuccessPage() {
        guard let viewModel = viewModel else { return }
        let vc = SuccessWithdrawalViewController()
        vc.biayaPenarikan = biayaPenarikan
        vc.viewModel = viewModel
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func confirmPressButton(_ sender: Any) {
        guard let viewModel = viewModel, let text = textField.text, !text.isEmpty else { return }
        viewModel.password.accept(text)
        viewModel.confirmPassword(isGopay: isGopay)
    }
}
