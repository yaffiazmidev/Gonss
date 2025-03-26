//
//  DiamondWithdrawalViewController.swift
//  KipasKipasDirectMessage
//
//  Created by DENAZMI on 11/08/23.
//

import UIKit
import KipasKipasDirectMessage
import KipasKipasShared

protocol IDiamondWithdrawalViewController: AnyObject {
    func displayBalanceDetail(data:RemoteBalanceCurrencyDetail)
    func displayConverter(unitPrice: Int, totalPrice: Int)
    func displayWithdrawal(value: WithdrawalDiamond)
    func displayErrorWithdrawal(message: String)
    func displayErrorBalanceDetail(message: String)
}

public class DiamondWithdrawalViewController: UIViewController, NavigationAppearance {
    
    private lazy var mainView: DiamondWithdrawalView = {
        let view = DiamondWithdrawalView().loadViewFromNib() as! DiamondWithdrawalView
        view.delegate = self
        return view
    }()
    
	var interactor: IDiamondWithdrawalInteractor!
	var router: IDiamondWithdrawalRouter!
    private var bankAccountId: String?
    private var withdrawalFee: Int?
    private var totalPrice: Int?
    
    private var type: String = "LIVE"
    private var currencyDetail: RemoteBalanceCurrencyDetail?
    
    private var diamond: Int = 0 {
        didSet {
            mainView.myDiamondLabel.text = "\(diamond)"
        }
    }
    
    public init(type: String = "LIVE") {
        super.init(nibName: nil, bundle: nil)
        self.type = type
        self.mainView.topTypeLabel.text = type
        if type == "LIVE" {
            self.diamond = KKCache.common.readInteger(key: .liveDiamondAmount) ?? 0
        }else{
            self.diamond = KKCache.common.readInteger(key: .diamond) ?? 0
        }  
    }
    
    public init(diamond: Int = 0) {
        self.diamond = diamond
        super.init(nibName: nil, bundle: nil)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        interactor.requestBalanceDetsil()
        mainView.onTap { [weak self] in
            guard let self = self else { return }
            self.view.endEditing(true)
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func loadView() {
        super.loadView()
        view = mainView
        mainView.myDiamondLabel.text = "\(diamond)"
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        overrideUserInterfaceStyle = .light
        bindNavBar()
        setupNavigationBar(title: "Penarikan Diamond", tintColor: .black)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: mainView.historyButton)
    }
    
    func reset() {
        DispatchQueue.main.async {
            self.mainView.inputDiamondTextField.text = "0"
            self.mainView.errorNameBankLabel.isHidden = false
            self.mainView.norekStackView.isHidden = true
            self.mainView.nameBankLabel.isHidden = true
            self.mainView.diamondWithdrawalLabel.text = 0.toCurrency()
            self.mainView.unitPriceLabel.text = 0.toCurrency()
            self.mainView.withdrawalAmountLabel.text = 0.toCurrency()
            self.mainView.withdrawalFeeLabel.text = 0.toCurrency()
            self.mainView.totalWithdrawalLabel.text = 0.toCurrency()
            self.mainView.inputDiamondTextField.isEnabled = false
            self.mainView.withdrawalButton.isEnabled = false
        }
    }
}

extension DiamondWithdrawalViewController: DiamondWithdrawalViewDelegate {
    func currencyConverter(with value: Int) {
        interactor.currenyConverter(value: value)
    }
    
    func didTapBank() {
        router.navigateToBank()
    }
    
    func didTapTnC() {
        router.presentTnCWebView()
    }
    
    func didTapHistoryButton() {
        router.navigateToHistory()
    }
    
    func didTapWithdrawalButton() {
        if currencyDetail?.verifIdentityStatus != "verified" {
            let view = UnverifiedIdentityView()
            view.verifyStatus = currencyDetail?.verifIdentityStatus ?? ""
            let configure = KKBottomSheetConfigureItem(viewHeight: 380, canSlideUp: false, canSlideDown: false, isShowHeaderView: false)
            let vc = KKBottomSheetController(view: view, configure: configure)
            view.handleVerificationLaterButton = vc.animateDismissView
            view.handleContinueVerificationButton = { [weak self] status in
                guard let self = self else { return }
                vc.animateDismissView { [weak self] in
                    guard let self = self else { return }
                    self.router.navigateToVerifyIdentity(status: status)
                }
            }
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: false)
        } else {
            router.presentConfirmPassword()
        }
    }
    
    func withdrawalDiamond(){
        guard let bankAccountId = self.bankAccountId else { return }

        let amount = Int(self.mainView.inputDiamondTextField.text ?? "") ?? 0
        interactor.withdrawalDiamond(type:type,bankAccountId: bankAccountId, amount: amount)
    }
}

extension DiamondWithdrawalViewController: IDiamondWithdrawalViewController {
    func displayBalanceDetail(data: KipasKipasDirectMessage.RemoteBalanceCurrencyDetail) {
        currencyDetail = data
        if type == "LIVE" {
            self.diamond = data.liveDiamondAmount ?? 0
        }else{
            self.diamond = data.diamondAmount ?? 0
        }
        KKCache.common.save(integer: data.diamondAmount ?? 0, key: .diamond)
        KKCache.common.save(integer: data.liveDiamondAmount ?? 0, key: .liveDiamondAmount)
    }
    
    func displayConverter(unitPrice: Int, totalPrice: Int) {
        DispatchQueue.main.async {
            self.mainView.unitPriceLabel.text = unitPrice.toCurrency()
            self.mainView.diamondWithdrawalLabel.text = self.mainView.inputDiamondTextField.text
            self.mainView.withdrawalAmountLabel.text = totalPrice.toCurrency()
            
            let withdrawal = self.withdrawalFee ?? 0
            self.mainView.totalWithdrawalLabel.text = (totalPrice - withdrawal).toCurrency()
        }
    }
    
    func displaySelectedBank(with value: BankAccountItem) {
        DispatchQueue.main.async {
            self.bankAccountId = value.bankId
            self.mainView.nameBankLabel.text = value.nameBank
            self.mainView.norekLabel.text = value.noRekening
            self.mainView.usernameLabel.text = value.username
            self.mainView.withdrawalFeeLabel.text = value.withdrawalFee.toCurrency()
            self.mainView.norekStackView.isHidden = false
            self.mainView.nameBankLabel.isHidden = false
            self.mainView.norekLabel.isHidden = false
            self.mainView.usernameLabel.isHidden = false
            self.mainView.errorNameBankLabel.isHidden = true
            self.withdrawalFee = value.withdrawalFee
            if self.mainView.withdrawalFeeLabel.text ?? "" == value.withdrawalFee.toCurrency() {
                self.mainView.totalWithdrawalLabel.text = ((self.totalPrice ?? 0 ) - (value.withdrawalFee) ).toCurrency()
                self.mainView.didEditingChanged(self.mainView.inputDiamondTextField)
            }
            self.mainView.layoutIfNeeded()
        }
    }
    
    func displayWithdrawal(value: WithdrawalDiamond) {
        reset()
        if type == "LIVE" {
            self.diamond = KKCache.common.readInteger(key: .liveDiamondAmount) ?? 0
        }else{
            self.diamond = KKCache.common.readInteger(key: .diamond) ?? 0
        } 
        router.navigateDiamondWithdrawal(value: value)
    }
    
    func displayErrorWithdrawal(message: String) {
        self.presentAlert(title: "Batas Penarikan", message: message)
    }
    
    func displayErrorBalanceDetail(message: String) {
        
    }
}
