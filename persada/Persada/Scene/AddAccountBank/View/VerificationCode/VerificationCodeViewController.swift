//
//  VerificationCodeViewController.swift
//  KipasKipas
//
//  Created by iOS Dev on 28/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import KipasKipasShared

protocol IVerificationCodeViewController: AnyObject {
    func displaySuccessRequestOTP(countdownTimeLeft: Int)
    func displayFailedRequestOTP(statusCode: Int, countdownTimeLeft: Int)
    
    func displaySuccessAddBankAccount(bank: BankData?)
    func displayFailedAddBankAccount(statusCode: Int, errorMessage: String)
}

class VerificationCodeViewController: UIViewController {
    @IBOutlet weak var changeSendingOTPMethodLabel: UILabel!
    @IBOutlet weak var notReceivingCodeLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var labelCount: UILabel!
    @IBOutlet weak var pinErrorMessageLabel: UILabel!
    @IBOutlet weak var resendingButton: UIButton!
    @IBOutlet weak var errorStackView: UIStackView!
    @IBOutlet weak var pinView: SVPinView! {
        didSet {
            pinView.pinLength = 4
            pinView.secureCharacter = "\u{25CF}"
            pinView.interSpace = 15
            pinView.textColor = UIColor.gray
            pinView.borderLineColor = .whiteSmoke
            pinView.activeBorderLineColor = .black
            pinView.activeBorderLineThickness = 3
            pinView.borderLineThickness = 3
            pinView.shouldSecureText = false
            pinView.allowsWhitespaces = false
            pinView.style = .underline
            pinView.fieldBackgroundColor = UIColor.white.withAlphaComponent(0.3)
            pinView.activeFieldBackgroundColor = .white
            pinView.fieldCornerRadius = 15
            pinView.activeFieldCornerRadius = 15
            pinView.becomeFirstResponderAtIndex = 0
            pinView.shouldDismissKeyboardOnEmptyFirstField = false
                pinView.font = .Roboto(.medium, size: 15)
            pinView.keyboardType = .phonePad
            pinView.deleteButtonAction = .moveToPreviousAndDelete
        }
    }
    
    var disposeBag = DisposeBag()
    private let hud = CPKProgressHUD.progressHUD(style: .loading(text: nil))
    
    var interactor: IVerificationCodeInteractor?
    var router: IVerificationCodeRouter?
    var countdownTimeLeft: Int = 0
    var platform: String = ""
    var countdown: ICountdownManager = CountdownManager(notificationCenter: NotificationCenter.default,
                                                        willResignActive: UIApplication.willResignActiveNotification,
                                                        willEnterForeground: UIApplication.willEnterForegroundNotification)

    private var timeLeft: Int = 20
    var handleCallbackSuccessAddBankAccount: (() ->Void)?
    var isSuccessAddBankAccount: Bool = false
    
    init(bank: AccountDestinationModel?, platform: String) {
        super.init(nibName: nil, bundle: nil)
        VerificationCodeRouter.configure(self)
        interactor?.bank = bank
        interactor?.platform = platform
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Konfirmasi OTP"
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        changeSendingOTPMethodLabel.attributedText = NSAttributedString(string: "Ubah metode pengiriman OTP", attributes: underlineAttribute)
        resendingButton.titleLabel?.attributedText = NSAttributedString(string: "Kirim Ulang", attributes: underlineAttribute)
        
        phoneNumberLabel.text = getPhone()
        setupNavbar()
        
        countdown.setupObserver()
        countdown.startTimer(timeLeft: countdownTimeLeft)
        
        countdown.didChangeCountdown = { [weak self] timeLeft in
            guard let self = self else { return }
            self.resendingButton.isUserInteractionEnabled = false
            self.resendingButton.isHidden = true
            self.notReceivingCodeLabel.isHidden = true
            self.labelCount.isHidden = false
            self.labelCount.text = "Kirim ulang kode verifikasi dalam \n\(self.timeFormatted(timeLeft))"
//            print("countdown \(self.timeFormatted(timeLeft))")
        }
        
        countdown.didFinishCountdown = { [weak self] in
            guard let self = self else { return }
            self.resendingButton.isUserInteractionEnabled = true
            self.resendingButton.isHidden = false
            self.notReceivingCodeLabel.isHidden = false
            self.labelCount.isHidden = true
            self.hidePinError()
//            print("countdown selesai")
        }
        
        confirmButton.rx.tap
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind {
            self.addBankAccount()
        }.disposed(by: disposeBag)
        
        resendingButton.rx.tap
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind {
            self.interactor?.requestOTP()
        }.disposed(by: disposeBag)
                
        pinView.didFinishCallback = self.didFinishEnteringPin(pin:)
        pinView.didChangeCallback = { pin in
            self.errorStackView.isHidden = true
            if pin.count < 4 {
                self.confirmButton.isUserInteractionEnabled = false
                self.confirmButton.backgroundColor = .placeholder
            } else {
                self.confirmButton.isUserInteractionEnabled = true
                self.confirmButton.backgroundColor = .primary
            }
        }
        
        changeSendingOTPMethodLabel.onTap { [weak self] in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        countdown.stopTimer()
        countdown.removeObserver()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isSuccessAddBankAccount {
            self.handleCallbackSuccessAddBankAccount?()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func didFinishEnteringPin(pin:String) {
        let otpCode = pinView.getPin()
        if otpCode.isEmpty || otpCode.count == 0 {
            pinErrorMessageLabel.text = "OTP Harus diisi"
            errorStackView.isHidden = false
            pinView.clearPin(completionHandler: nil)
            return
        } else if otpCode.count < 4 {
            pinErrorMessageLabel.text = "OTP tidak lengkap"
            errorStackView.isHidden = false
            pinView.clearPin(completionHandler: nil)
            return
        }
        
        pinErrorMessageLabel.text = nil
        errorStackView.isHidden = true
    }
    
    private func requestOTP() {
        DispatchQueue.main.async { self.hud.show(in: self.view) }
        interactor?.requestOTP()
    }
    
    private func addBankAccount() {
        let otpCode = pinView.getPin()
        if otpCode.isEmpty || otpCode.count == 0 {
            pinErrorMessageLabel.text = "OTP Harus diisi"
            errorStackView.isHidden = false
            pinView.clearPin(completionHandler: nil)
            hud.dismiss()
            return
        }

        errorStackView.isHidden = true
        interactor?.addBankAccount(otpCode: otpCode)
    }
    
    @IBAction func didClickConfirmButton(_ sender: Any) {
        DispatchQueue.main.async { self.hud.show(in: self.view) }
        
    }
    
    @IBAction func didClickResendingButton(_ sender: Any) {
        DispatchQueue.main.async { self.hud.show(in: self.view) }
    }
    
    func showPinError(_ message: String) {
        pinErrorMessageLabel.text = message
        errorStackView.isHidden = false
    }
    
    func hidePinError() {
        pinErrorMessageLabel.text = nil
        errorStackView.isHidden = true
    }
    
    private func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

extension VerificationCodeViewController: IVerificationCodeViewController {
    func displaySuccessRequestOTP(countdownTimeLeft: Int) {
        countdown.startTimer(timeLeft: countdownTimeLeft)
        hud.dismiss()
    }
    
    func displayFailedRequestOTP(statusCode: Int, countdownTimeLeft: Int) {
        if statusCode == 429 {
            countdown.startTimer(timeLeft: countdownTimeLeft)
            showPinError("Kamu sudah melakukan 3x request OTP, coba lagi setelah 60 menit")
        } else {
            countdown.stopTimer()
        }
        
        DispatchQueue.main.async { self.hud.dismiss() }
    }
    
    func displaySuccessAddBankAccount(bank: BankData?) {
        DispatchQueue.main.async { self.hud.dismiss() }
        isSuccessAddBankAccount = true
        navigationController?.popViewController(animated: false)
    }
    
    func displayFailedAddBankAccount(statusCode: Int, errorMessage: String) {
        DispatchQueue.main.async { self.hud.dismiss() }
        if statusCode == 429 || errorMessage.contains("Too Many Input") == true {
            showPinError("Kamu sudah 3 kali memasukan kode yang salah")
        } else {
            showPinError(errorMessage)
        }
        isSuccessAddBankAccount = false
    }
}
