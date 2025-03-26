//
//  OTPViewController.swift
//  Persada
//
//  Created by monggo pesen 3 on 15/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import UIKit
import RxSwift
import KipasKipasShared

protocol OTPDisplayLogic where Self: UIViewController {
	func displayViewModel(_ viewModel: OTPModel.ViewModel)
    func displayOTP(item: AuthOTPItem)
    func displayErrorOTP(item: AuthOTPItem)
    func displayUpdatePhoneNumber()
    func displayErrorUpdatePhoneNumber(message: String, code: Int)
}

class OTPViewController: UIViewController {
	
	private let mainView: OTPView
    private var router: OTPRouting!
    private var interactor: OTPInteractable!
    private var disposeBag = DisposeBag()
    private let hud = CPKProgressHUD.progressHUD(style: .loading(text: nil))
    private var incorrectOtpCount: Int = 0
    private let isFromEditPhoneNumber: Bool
    var handleEditPhoneNumberCallback: ((String?, Int) -> Void)?
    
    var countdownTimeLeft: Int = 0
    var countdown: ICountdownManager = CountdownManager(notificationCenter: NotificationCenter.default,
                                                        willResignActive: UIApplication.willResignActiveNotification,
                                                        willEnterForeground: UIApplication.willEnterForegroundNotification)
	
    init(mainView: OTPView, dataSource: OTPModel.DataSource, platform: String, isFromEditPhoneNumber: Bool = false) {
		self.mainView = mainView
        self.isFromEditPhoneNumber = isFromEditPhoneNumber
		super.init(nibName: nil, bundle: nil)
		interactor = OTPInteractor(viewController: self, dataSource: dataSource)
        interactor.platform = platform
        interactor.phoneNumber = dataSource.number
        interactor.isFromEditPhoneNumber = isFromEditPhoneNumber
		router = OTPRouter(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
        mainView.notReceivedOTPLabel.isHidden = true
        
		mainView.delegate = self
		mainView.reloadNumberText()
		
        actionOTPViewHandler()
		hideKeyboardWhenTappedAround()
        handleOntapTimerLabel()
        
        
        countdown.setupObserver()
        countdown.startTimer(timeLeft: countdownTimeLeft)
        
        countdown.didChangeCountdown = { [weak self] timeLeft in
            guard let self = self else { return }
            self.mainView.timerLabel.text = "Kirim ulang kode verifikasi dalam\n \(self.timeFormatted(timeLeft)) detik"
            self.mainView.timerLabel.textColor = .grey
            self.mainView.timerLabel.isUserInteractionEnabled = false
            self.mainView.timerLabel.isHidden = false
            self.mainView.notReceivedOTPLabel.isHidden = true
        }
        
        countdown.didFinishCountdown = { [weak self] in
            guard let self = self else { return }
            self.mainView.timerLabel.text = "Kirim Ulang"
            self.mainView.timerLabel.textColor = .primary
            self.mainView.timerLabel.isUserInteractionEnabled = true
            self.mainView.timerLabel.isHidden = false
            self.mainView.notReceivedOTPLabel.isHidden = false
        }
	}
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        countdown.stopTimer()
        countdown.removeObserver()
    }
	
	override func loadView() {
		view = mainView
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
	}
    
    private func actionOTPViewHandler() {
        mainView.otpView.didFinishCallback = didFinishEnteringPin(pin:)
        mainView.otpView.didChangeCallback = { pin in
            self.mainView.hideError()
        }
    }
    
    private func handleOntapTimerLabel() {
        mainView.timerLabel.onTap {
            self.mainView.hideError()
            self.mainView.timerLabel.isHidden = true
            self.requestOTP()
        }
        
        mainView.changeOTPOptionLabel.onTap { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true)
        }
    }
    
    private func requestOTP() {
        DispatchQueue.main.async { KKLoading.shared.show() }
        interactor.requestOTP()
    }
	
	private func didFinishEnteringPin(pin: String) {
        DispatchQueue.main.async { self.hud.show(in: self.mainView) }
        
        if isFromEditPhoneNumber {
            interactor.updatePhoneNumber(code: pin)
            return
        }
        
		interactor.doRequest(.verifyOTP(code: pin, phoneNumber: interactor.dataSource.number))
	}
    
    private func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

extension OTPViewController: OTPViewDelegate {
	func handleBackButton() {
        countdown.removeObserver()
		router.routeTo(.dismissOTPScene)
	}
	
	func textNumber() -> String {
		return interactor.dataSource.number
	}
}

extension OTPViewController: OTPDisplayLogic {
    
    func displayViewModel(_ viewModel: OTPModel.ViewModel) {
        DispatchQueue.main.async {
            self.hud.dismiss()
            
            switch viewModel {
            case .OTP(let data):
                self.displayOTPResponse(data)
            case .verifyOTP(let data):
                self.displayVerifyOTPResponse(data)
            case .verifyOTPPassword(viewModelData: let data):
                self.displayVerifyOTPForgotPasswordResponse(data)
            }
        }
    }
	
	func displayOTPResponse(_ viewModel: ResultData<DefaultResponse>) {
		switch viewModel {
		case .failure(let err):
            if err?.statusCode == 429 || err?.statusData?.contains("Kamu sudah 3 kali meminta OTP") == true {
                mainView.showError(message: .get(.otpLimitation))
                countdown.startTimer(timeLeft: countdownTimeLeft)
            } else {
                mainView.showError(message: err?.statusData ?? .get(.somethingWrong))
            }
		case .success(_):
            incorrectOtpCount = 0
            mainView.otpView.isUserInteractionEnabled = true
            countdown.startTimer(timeLeft: countdownTimeLeft)
		}
	}
    
	func displayVerifyOTPResponse(_ data: ResultData<VerifyOTP>){
		switch data {
		case .failure(let error):
            handleErrorVerifyOTP(error)
		case .success:
			let pinCode = mainView.otpView.getPin()
			router.routeTo(.inputUserScene(phoneNumber: interactor.dataSource.number, otpCode: pinCode))
		}
	}
	
	func displayVerifyOTPForgotPasswordResponse(_ data: ResultData<VerifyForgotPassword>){
		switch data {
		case .failure(let error):
            handleErrorVerifyOTP(error)
		case .success(let data):
            router.routeTo(.navigateToResetPassword(id: data.data?.id ?? "", phoneNumber: data.data?.key ?? "", otp: data.data?.otpCode ?? "", otpPlatform: interactor.platform))
		}
	}
    
    private func handleErrorVerifyOTP(_ error: ErrorMessage?) {
        if error?.statusCode == 400 && error?.code == "4000"{
            incorrectOtpCount += 1
            if incorrectOtpCount >= 3 {
                mainView.otpView.isUserInteractionEnabled = false
                countdownTimeLeft = 0
                countdown.stopTimer()
                
                self.mainView.timerLabel.text = "Kirim Ulang"
                self.mainView.timerLabel.textColor = .primary
                self.mainView.timerLabel.isUserInteractionEnabled = true
                self.mainView.timerLabel.isHidden = false
                
                mainView.otpView.clearPin {
                    self.view.endEditing(true)
                }
                mainView.showError(message: error?.statusData ?? "Terjadi kesalahan")
                return
            }
            
            mainView.showError(message: error?.statusData ?? "Terjadi kesalahan")
            return
        }
        
        if error?.statusData?.contains("Too Many Input") == true {
            mainView.showError(message: .get(.otpInputLimitation))
        } else {
            mainView.showError(message: error?.statusData ?? .get(.somethingWrong))
        }
    }
}

extension OTPViewController {
    func displayOTP(item: AuthOTPItem) {
        DispatchQueue.main.async { KKLoading.shared.hide() }
        incorrectOtpCount = 0
        mainView.otpView.isUserInteractionEnabled = true
        countdown.startTimer(timeLeft: item.expireInSecond ?? 0)
    }
    
    func displayErrorOTP(item: AuthOTPItem) {
        DispatchQueue.main.async { KKLoading.shared.hide() }
        if item.code == 429 {
            mainView.showError(message: .get(.otpLimitation))
            countdown.startTimer(timeLeft: item.tryInSecond ?? 0)
            return
        }
        
        mainView.showError(message: .get(.somethingWrong))
    }
    
    func displayUpdatePhoneNumber() {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.handleEditPhoneNumberCallback?(nil, 1000)
        }
    }
    
    func displayErrorUpdatePhoneNumber(message: String, code: Int) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.handleEditPhoneNumberCallback?(message, code)
        }
    }
}
