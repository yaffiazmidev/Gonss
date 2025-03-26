//
//  OTPMethodOptionViewController.swift
//  KipasKipas
//
//  Created by DENAZMI on 05/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit
import KipasKipasShared

enum RequestOTPFrom {
    case register, forgotPassword, bankAccount, editPhoneNumber
}

protocol IOTPMethodOptionViewController: AnyObject {
    func displayWhatsappOTP(item: AuthOTPItem)
    func displayErrorWhatsappOTP(item: AuthOTPItem)
    func displaySmsOTP(item: AuthOTPItem)
    func displayErrorSmsOTP(item: AuthOTPItem)
}

class OTPMethodOptionViewController: UIViewController, UIGestureRecognizerDelegate, NavigationAppearance {
    
    @IBOutlet weak var iconWhatsappImageView: UIImageView!
    @IBOutlet weak var sendWhatsappLabel: UILabel!
    @IBOutlet weak var whatsappCountdownLabel: UILabel!
    @IBOutlet weak var whatsappContainerView: UIView!
    @IBOutlet weak var whatsappErrorLabel: UILabel!
    @IBOutlet weak var iconSmsImageView: UIImageView!
    @IBOutlet weak var sendSmsLabel: UILabel!
    @IBOutlet weak var smsContainerView: UIView!
    @IBOutlet weak var smsCountdownLabel: UILabel!
    @IBOutlet weak var smsErrorLabel: UILabel!
    @IBOutlet weak var whatsappSmsErrorLabel: UILabel!
    
    var interactor: IOTPMethodOptionInteractor!
    var whatsappCountdown: ICountdownManager
    var smsCountdown: ICountdownManager
    let otpFrom: RequestOTPFrom
    var isLimitWhatsapp = false
    var isLimitSMS = false
    var bankAccount: AccountDestinationModel?
    var editPhoneNumberResult: [String : Any] = [:]
    var handleEditPhoneNumberCallback: (([String: Any]) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        setupNavigationBar()
        handleOnTapView()
        handleCountdown()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar(color: .white, tintColor: .black)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    init(otpFrom: RequestOTPFrom,
         phoneNumber: String,
         whatsappCountdown: ICountdownManager,
         smsCountdown: ICountdownManager)
    {
        self.whatsappCountdown = whatsappCountdown
        self.smsCountdown = smsCountdown
        self.otpFrom = otpFrom
        super.init(nibName: nil, bundle: nil)
        configure()
        interactor.otpFrom = otpFrom
        interactor.phoneNumber = phoneNumber
    }
    
    deinit {
        whatsappCountdown.stopTimer()
        whatsappCountdown.removeObserver()
        smsCountdown.stopTimer()
        smsCountdown.removeObserver()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if !editPhoneNumberResult.isEmpty {
            handleEditPhoneNumberCallback?(editPhoneNumberResult)
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func handleCountdown() {
        whatsappCountdown.setupObserver()
        smsCountdown.setupObserver()
        
        whatsappCountdown.didChangeCountdown = { [weak self] timeLeft in
            guard let self = self else { return }
            self.whatsappCountdownLabel.isHidden = false
            self.whatsappCountdownLabel.text = self.timeFormatted(timeLeft)
            self.whatsappButton(isEnable: false)
            
            if self.isLimitSMS {
                self.whatsappErrorLabel.isHidden = true
            } else {
                self.whatsappErrorLabel.isHidden = false
            }
        }
        
        whatsappCountdown.didFinishCountdown = { [weak self] in
            guard let self = self else { return }
            self.isLimitWhatsapp = false
            self.whatsappSmsErrorLabel.isHidden = true
            self.resetWhatsappButton()
        }
        
        smsCountdown.didChangeCountdown = { [weak self] timeLeft in
            guard let self = self else { return }
            self.smsCountdownLabel.isHidden = false
            self.smsCountdownLabel.text = self.timeFormatted(timeLeft)
            self.smsButton(isEnable: false)
            
            
            if self.isLimitWhatsapp {
                self.whatsappSmsErrorLabel.isHidden = false
                self.smsErrorLabel.isHidden = true
            } else {
                self.smsErrorLabel.isHidden = false
            }
        }
        
        smsCountdown.didFinishCountdown = { [weak self] in
            guard let self = self else { return }
            self.isLimitSMS = false
            self.whatsappSmsErrorLabel.isHidden = true
            self.resetSmsButton()
        }
    }
    
    private func handleOnTapView() {
        whatsappContainerView.onTap { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async { KKLoading.shared.show() }
            self.interactor.requestWhatsappOTP()
        }
        
        smsContainerView.onTap { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async { KKLoading.shared.show() }
            self.interactor.requestSmsOTP()
        }
    }
    
    private func setupNavigationBar() {
        bindNavigationBar("Kirim OTP")
        navigationController?.navigationBar.layer.shadowColor   = UIColor.black.cgColor
        navigationController?.navigationBar.layer.shadowOpacity = 0.2
        navigationController?.navigationBar.layer.shadowOffset  = CGSize.zero
        navigationController?.navigationBar.layer.shadowRadius  = 2
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    private func whatsappButton(isEnable: Bool) {
        iconWhatsappImageView.alpha = isEnable ? 1 : 0.3
        sendWhatsappLabel.alpha = isEnable ? 1 : 0.3
        whatsappContainerView.isUserInteractionEnabled = isEnable
    }
    
    private func smsButton(isEnable: Bool) {
        iconSmsImageView.alpha = isEnable ? 1 : 0.3
        sendSmsLabel.alpha = isEnable ? 1 : 0.3
        smsContainerView.isUserInteractionEnabled = isEnable
    }
    
    private func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func routeToNextPage(countdownTimeLeft: Int, platform: String) {
//        resetWhatsappButton()
//        resetSmsButton()
        
        switch otpFrom {
        case .register:
            let dataSource = OTPModel.DataSource(number: interactor.phoneNumber)
            let otpController = OTPViewController(mainView: OTPView(), dataSource: dataSource, platform: platform)
            otpController.countdownTimeLeft = countdownTimeLeft
            otpController.modalPresentationStyle = .fullScreen
            present(otpController, animated: true)
        case .forgotPassword:
            let dataSource = OTPModel.DataSource(number: interactor.phoneNumber, isFromForgotPassword: true)
            let otpController = OTPViewController(mainView: OTPView(), dataSource: dataSource, platform: platform)
            otpController.countdownTimeLeft = countdownTimeLeft
            otpController.modalPresentationStyle = .fullScreen
            present(otpController, animated: true)
        case .bankAccount:
            let vc = VerificationCodeViewController(bank: bankAccount, platform: platform)
            vc.countdownTimeLeft = countdownTimeLeft
            vc.handleCallbackSuccessAddBankAccount = { [weak self] in
                guard let self = self else { return }
                self.navigationController?.popViewController(animated: true)
            }
            navigationController?.pushViewController(vc, animated: true)
        case .editPhoneNumber:
            let dataSource = OTPModel.DataSource(number: interactor.phoneNumber)
            let otpController = OTPViewController(mainView: OTPView(), dataSource: dataSource, platform: platform, isFromEditPhoneNumber: true)
            otpController.countdownTimeLeft = countdownTimeLeft
            otpController.handleEditPhoneNumberCallback = { [weak self] (message, code) in
                guard let self = self else { return }
                self.editPhoneNumberResult = ["message": message ?? "", "code": code]
                self.navigationController?.popViewController(animated: false)
            }
            otpController.modalPresentationStyle = .fullScreen
            present(otpController, animated: true)
        }
    }
    
    private func resetWhatsappButton() {
        whatsappSmsErrorLabel.isHidden = true
        whatsappErrorLabel.isHidden = true
        whatsappCountdownLabel.text = "00:00"
        whatsappCountdownLabel.isHidden = true
        whatsappButton(isEnable: true)
    }
    
    private func resetSmsButton() {
        whatsappSmsErrorLabel.isHidden = true
        smsErrorLabel.isHidden = true
        smsCountdownLabel.text = "00:00"
        smsCountdownLabel.isHidden = true
        smsButton(isEnable: true)
    }
}

extension OTPMethodOptionViewController: IOTPMethodOptionViewController {
    func displayWhatsappOTP(item: AuthOTPItem) {
        DispatchQueue.main.async { KKLoading.shared.hide() }
        isLimitWhatsapp = false
        resetWhatsappButton()
        routeToNextPage(countdownTimeLeft: item.expireInSecond ?? 0, platform: item.platform)
    }
    
    func displayErrorWhatsappOTP(item: AuthOTPItem) {
        DispatchQueue.main.async { KKLoading.shared.hide() }
        whatsappButton(isEnable: item.code != 429)
        if item.code == 429 {
            isLimitWhatsapp = true
            whatsappCountdownLabel.isHidden = false
            whatsappCountdown.startTimer(timeLeft: item.tryInSecond ?? 0)
            return
        }
        
        DispatchQueue.main.async {
            Toast.share.show(message: item.code == 404 ? "\(self.interactor.phoneNumber) tidak di temukan" : "Opss Terjadi kesalahan, silahkan coba lagi..")
        }
    }
    
    func displaySmsOTP(item: AuthOTPItem) {
        DispatchQueue.main.async { KKLoading.shared.hide() }
        isLimitSMS = false
        resetSmsButton()
        routeToNextPage(countdownTimeLeft: item.expireInSecond ?? 0, platform: item.platform)
    }
    
    func displayErrorSmsOTP(item: AuthOTPItem) {
        DispatchQueue.main.async { KKLoading.shared.hide() }
        smsButton(isEnable: item.code != 429)
        if item.code == 429 {
            isLimitSMS = true
            smsCountdownLabel.isHidden = false
            smsCountdown.startTimer(timeLeft: item.tryInSecond ?? 0)
            return
        }
        
        DispatchQueue.main.async {
            Toast.share.show(message: item.code == 404 ? "\(self.interactor.phoneNumber) tidak di temukan" : "Opss Terjadi kesalahan, silahkan coba lagi..")
        }
    }
}

extension OTPMethodOptionViewController {
    func configure() {
        let presenter = OTPMethodOptionPresenter(controller: self)
        var apiService: DataTransferService = DIContainer.shared.defaultAPIDataTransferService
        if otpFrom == .bankAccount || otpFrom == .editPhoneNumber {
            apiService = DIContainer.shared.apiDataTransferService
        }
        let interactor = OTPMethodOptionInteractor(presenter: presenter, apiService: apiService)
        self.interactor = interactor
    }
}
