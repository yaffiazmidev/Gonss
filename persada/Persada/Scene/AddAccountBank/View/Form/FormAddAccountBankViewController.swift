//
//  FormAddAccountBankViewController.swift
//  KipasKipas
//
//  Created by iOS Dev on 28/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import KipasKipasShared

class FormAddAccountBankViewController: UIViewController, AlertDisplayer {
    @IBOutlet weak var namaBankLabel: UILabel!
    @IBOutlet weak var namaBankView: UIView!
    @IBOutlet weak var nomorRekeningTextField: UITextField!
    @IBOutlet weak var addRekButton: UIButton!
    @IBOutlet weak var notFoundRekeningLabel: UILabel!
    @IBOutlet weak var bottomNamaBankLabel: UILabel!
    @IBOutlet weak var bottomNamaPemilikLabel: UILabel!
    @IBOutlet weak var bottomNomorRekLabel: UILabel!
    @IBOutlet weak var infoLabel: UIView!
    @IBOutlet weak var infoStackView: UIStackView!
    
    let viewModel = AddAccountBankViewModel()
    let disposeBag = DisposeBag()
    private let hud = CPKProgressHUD.progressHUD(style: .loading(text: nil))
    var handleAddBankAccount: ((AccountDestinationModel?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
//        setupNavbarForPresent()
        registerObserver()
        title = "Tambah Rekening"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        overrideUserInterfaceStyle = .light
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        navigationController?.interactivePopGestureRecognizer?.delegate = self
//        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func registerObserver() {
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
        
        viewModel.bankChoice.subscribe(onNext: { [weak self] bank in
            guard let bank = bank else { return }
            self?.namaBankLabel.text = bank.namaBank
            self?.namaBankLabel.textColor = .black
        }).disposed(by: disposeBag)
        
        let accountvalid = nomorRekeningTextField.rx.text.orEmpty.map { (text) -> Bool in
                  text.count > 20
        }.share(replay: 1)
              
              _ = accountvalid.subscribe(onNext: { (valid) in
                  
                  if valid{
                      let index = self.nomorRekeningTextField.text!.index(self.nomorRekeningTextField!.text!.startIndex, offsetBy:20)
                      
                      self.nomorRekeningTextField.text = self.nomorRekeningTextField!.text!.substring(to: index)
                  }
              })
        
        nomorRekeningTextField.rx.controlEvent([.editingDidBegin])
            .asObservable()
            .subscribe(onNext: { [weak self] in
                self?.createRightViewText()
            }).disposed(by: disposeBag)
        
        viewModel.isRekValid.subscribe(onNext: { isValid in
            guard let isValid = isValid else {
                self.infoLabel.isHidden = true
                self.nomorRekeningTextField.rightView = .none
                self.setupButton(isValid: false)
                return
            }
            if isValid {
                self.setupButton(isValid: isValid)
                self.createRightViewImage()
                self.setupInfoRek()
            } else {
                self.setupButton(isValid: isValid)
                self.infoLabel.isHidden = false
                self.notFoundRekeningLabel.isHidden = false
                self.infoStackView.isHidden = true
            }
        }).disposed(by: disposeBag)
    }
    
    func setupView() {
        namaBankView.layer.borderColor = UIColor(hexString: "EEEEEE").cgColor
        namaBankView.onTap {
            self.navigateToListBank()
        }
    }
    
    func createRightViewText() {
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        label.text = "Cek Rekening"
        label.font = UIFont.Roboto(.medium, size: 12)
        label.textColor = UIColor(hexString: "#1890FF")
        label.textAlignment = .center

        rightView.addSubview(label)
        rightView.onTap {
            self.viewModel.textAccountNumber.accept(self.nomorRekeningTextField.text)
            self.viewModel.checkBankAccount()
        }

        nomorRekeningTextField.rightView = rightView
        nomorRekeningTextField.rightViewMode = .always
    }
    
    func createRightViewImage() {
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        
        let imageView = UIImageView(frame: CGRect(x: rightView.frame.maxX - 40, y: 0, width: 20, height: 20))
        imageView.image = UIImage(named: "iconConfirmWithoutFill")
        imageView.tintColor = UIColor(hexString: "#52C41A")
        rightView.addSubview(imageView)
        
        nomorRekeningTextField.rightView = rightView
        nomorRekeningTextField.rightViewMode = .always
    }
    
    func setupButton(isValid: Bool) {
        if isValid {
            addRekButton.backgroundColor = .primary
            addRekButton.isEnabled = true
        } else {
            addRekButton.backgroundColor = UIColor(hexString: "#DDDDDD")
            addRekButton.isEnabled = false
        }
    }
    
    func setupInfoRek() {
        if let data = viewModel.bankCheck.value {
            infoLabel.isHidden = false
            notFoundRekeningLabel.isHidden = true
            infoStackView.isHidden = false
            
            bottomNamaBankLabel.text = data.namaBank
            bottomNomorRekLabel.text = data.noRek
            bottomNamaPemilikLabel.text = data.nama
        }
    }
    
    func navigateToListBank() {
        let vc = BankListViewController()
        vc.viewModel = viewModel
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func navigateToVerificationForm() {
//        let otpMethodOption = OTPMethodOptionViewController(
//          otpFrom: .bankAccount, phoneNumber: "",
//          whatsappCountdown: CountdownManager(notificationCenter: NotificationCenter.default,
//                                              willResignActive: UIApplication.willResignActiveNotification,
//                                              willEnterForeground: UIApplication.willEnterForegroundNotification),
//          smsCountdown: CountdownManager(notificationCenter: NotificationCenter.default,
//                                              willResignActive: UIApplication.willResignActiveNotification,
//                                              willEnterForeground: UIApplication.willEnterForegroundNotification))
//        otpMethodOption.bankAccount = viewModel.bankCheck.value
//        navigationController?.pushViewController(otpMethodOption, animated: true)
    }
    
    @IBAction func addRekPressed(_ sender: Any) {
//        dismiss(animated: false) {
//            self.handleAddBankAccount?(self.viewModel.bankCheck.value)
//        }
        navigationController?.popViewController(animated: false)
        handleAddBankAccount?(viewModel.bankCheck.value)
    }
}

extension FormAddAccountBankViewController: UIGestureRecognizerDelegate { }
