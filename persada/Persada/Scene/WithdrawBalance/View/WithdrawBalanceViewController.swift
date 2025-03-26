//
//  WithdrawBalanceViewController.swift
//  KipasKipas
//
//  Created by iOS Dev on 21/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import KipasKipasShared

enum TabActive: String {
    case penjualan = "TRANSACTION"
    case refund = "REFUND"
}

class WithdrawBalanceViewController: UIViewController, AlertDisplayer {
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var penjualanLabel: UILabel!
    @IBOutlet weak var penjualanLineView: UIView!
    @IBOutlet weak var refundLabel: UILabel!
    @IBOutlet weak var refundLineView: UIView!
    @IBOutlet weak var topInfoLabel: UILabel!
    @IBOutlet weak var topInfoView: UIView!
    @IBOutlet weak var saldoPenjualanTitleLabel: UILabel!
    @IBOutlet weak var saldoPenjualanLabel: UILabel!
    @IBOutlet weak var tarikSemuaButton: UIButton!
    @IBOutlet weak var rupiahLabel: UILabel!
    @IBOutlet weak var nominalPenarikanTextField: UITextField!
    @IBOutlet weak var nominalPenarikanView: UIView!
    @IBOutlet weak var noInputRekeningView: UIView!
    @IBOutlet weak var infoRekeningView: UIView!
    @IBOutlet weak var namaBankLabel: UILabel!
    @IBOutlet weak var noRekLabel: UILabel!
    @IBOutlet weak var pemilikRekLabel: UILabel!
    @IBOutlet weak var biayaPenarikanLabel: UILabel!
    @IBOutlet weak var nominalPenarikanLabel: UILabel!
    @IBOutlet weak var totalPenarikanLabel: UILabel!
    @IBOutlet weak var infoBottomStackView: UIStackView!
    @IBOutlet weak var tarikSaldoButton: PrimaryButton!
    @IBOutlet weak var penjualanButton: UIButton!
    
    var viewModel = WithdrawalBalanceViewModel()
    var disposeBag = DisposeBag()
    var isSeller: Bool? {
        didSet {
            guard let isSeller = isSeller else { return }
//            self.setupTabByStatus(isSeller: isSeller)
        }
    }
    
    var tab: TabActive = .penjualan {
        didSet {
            setupViewForTab(tab: tab)
            setupView()
        }
    }
    
    var didWithdraw: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tarik Saldo"
        setupView()
        registerObserver()
        viewModel.fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupNavbar()
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func registerObserver() {
        viewModel.data.subscribe(onNext: { [weak self] data in
            guard let data = data else { return }
            self?.setupDataForTab(data: data)
        }).disposed(by: disposeBag)
        
        viewModel.isLoading.subscribe(onNext: { [weak self] isLoading in
            guard self != nil else { return }
            guard let isLoading = isLoading else { return }
            if isLoading {
                DispatchQueue.main.async { KKLoading.shared.show() }
                return
            } else {
                DispatchQueue.main.async { KKLoading.shared.hide() }
            }
        }).disposed(by: disposeBag)
        
        viewModel.errorMessage.subscribe(onNext: { [weak self] message in
            DispatchQueue.main.async { KKLoading.shared.hide() }
            
            guard let message = message else { return }
            if !message.isEmpty {
                let action = UIAlertAction(title: "OK", style: .default)
                self?.displayAlert(with: .get(.error), message: message, actions: [action])
            }
        }).disposed(by: disposeBag)
        
        nominalPenarikanTextField.rx.text
            .throttle(.milliseconds(1000), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                guard let text = text, !text.isEmpty else { return }
                let nominal = text.replacingOccurrences(of: ".", with: "").toDouble()
                self?.viewModel.checkInputWithdrawal(input: nominal)
                self?.viewModel.nominal.accept(nominal)
                self?.updateView()
            }).disposed(by: disposeBag)
        
        viewModel.isValidDebit.subscribe(onNext: { [weak self] isValid in
            guard isValid != nil else { return }
            self?.updateView()
        }).disposed(by: disposeBag)
        
        viewModel.choiceAccountBank.subscribe(onNext: { [weak self] data in
            guard let data = data else {
                self?.noInputRekeningView.isHidden = false
                self?.infoRekeningView.isHidden = true
                return
            }
            
            self?.setupChoiceBank(data: data)
        }).disposed(by: disposeBag)
        
        viewModel.profileUseCase.getNetworkProfile(id: getIdUser()).asObservable().subscribe(onNext: { [weak self] profile in
            guard let isSeller = profile.data?.isSeller else { return }
            self?.isSeller = isSeller
        }).disposed(by: disposeBag)
    }
    
    func setupView() {
        setupContentViewConstraint()
        self.viewModel.type.accept(tab)
        nominalPenarikanTextField.delegate = self
        nominalPenarikanView.layer.borderColor = UIColor(hexString: "EEEEEE").cgColor
        tarikSaldoButton.isEnabled = false
        tarikSaldoButton.backgroundColor = .primaryDisabled
        topInfoView.backgroundColor = UIColor(hexString: "#FFEBEF")
        topInfoLabel.text = "Penarikan hanya bisa dilakukan 2x dalam 1 hari"
        topInfoLabel.textColor = .primary
        nominalPenarikanTextField.textColor = UIColor(hexString: "#000000")
        rupiahLabel.textColor = UIColor(hexString: "#000000")
        noInputRekeningView.onTap {
            self.navigateToChoiceBank()
        }
        infoRekeningView.onTap {
            self.navigateToChoiceBank()
        }
    }
    
    func setupContentViewConstraint(){
        let topViewHeight = 153
        let screenHeight = UIScreen.main.bounds.height
        let scrollViewHeight = screenHeight - CGFloat(topViewHeight)
        let rekeningHeight = viewModel.choiceAccountBank.value == nil ? 77 : 101
        let infoHeight = infoBottomStackView.frame.height
        let fixedContentHeight = 409
        let estimatedHeight = CGFloat(fixedContentHeight) + CGFloat(rekeningHeight) + infoHeight + 32  //32 is min spacing between info bottom & biaya
        let toolbarHeight = (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 48) +
        (self.navigationController?.navigationBar.frame.height ?? 44)
        if scrollViewHeight <= estimatedHeight {
            contentViewHeight.constant = estimatedHeight
        }else{
            contentViewHeight.constant = screenHeight - CGFloat(topViewHeight) - toolbarHeight
        }
    }
    
    func setupDataForTab(data: WithdrawalBalanceInfoModel) {
        switch tab {
        case .penjualan:
            saldoPenjualanLabel.text = data.saldo?.toMoney() ?? "-"
        default:
            saldoPenjualanLabel.text = data.saldoRefund?.toMoney() ?? "-"
        }
        biayaPenarikanLabel.text = data.withdrawFee?.toMoney() ?? "Rp 0"
    }
    
    func setupViewForTab(tab: TabActive) {
        switch tab {
        case .penjualan:
            saldoPenjualanTitleLabel.text = "Saldo Penjualan"
            penjualanLabel.textColor = .primary
            penjualanLineView.backgroundColor = .primary
            refundLabel.textColor = UIColor(hexString: "777777")
            refundLineView.backgroundColor = .white
            infoBottomStackView.isHidden = false
        case .refund:
            saldoPenjualanTitleLabel.text = "Saldo Refund"
            penjualanLabel.textColor = UIColor(hexString: "777777")
            penjualanLineView.backgroundColor = .white
            refundLabel.textColor = .primary
            refundLineView.backgroundColor = .primary
            infoBottomStackView.isHidden = true
        }
        
        viewModel.choiceAccountBank.accept(nil)
        viewModel.withdrawFee.accept(0)
        nominalPenarikanTextField.text = ""
        biayaPenarikanLabel.text = "Rp 0"
        nominalPenarikanLabel.text = "Rp 0"
        totalPenarikanLabel.text = "Rp 0"
        tarikSaldoButton.isEnabled = false
        tarikSaldoButton.backgroundColor = .primaryDisabled
        setupContentViewConstraint()
        viewModel.fetchData()
    }
    
    func setupTabByStatus(isSeller: Bool) {
        if !isSeller {
            tab = .refund
            penjualanLabel.textColor = UIColor(hexString: "#DDDDDD")
            penjualanButton.isEnabled = false
        }
    }
    
    func navigateToChoiceBank() {
        let vc = AccountDestinationViewController(isMyAccount: false)
        vc.bindNavigationBar("Rekening Tujuan")
        vc.choice = { [weak self] data in
            guard let self = self else { return }
            self.viewModel.choiceAccountBank.accept(data)
        }
        vc.selectedBank = viewModel.choiceAccountBank.value
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func navigateToConfirmPassword() {
        let vc = ConfirmViewController()
        vc.viewModel = viewModel
        vc.biayaPenarikan = biayaPenarikanLabel.text!
        vc.isGopay = viewModel.choiceAccountBank.value?.swiftCode ?? "" == "gopay"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setupChoiceBank(data: AccountDestinationModel) {
        setupContentViewConstraint()
        noInputRekeningView.isHidden = true
        infoRekeningView.isHidden = false
        noRekLabel.text = data.noRek
        namaBankLabel.text = data.namaBank
        pemilikRekLabel.text = data.nama
        
        let isBCA = data.swiftCode == "CENAIDJA"
        if tab == .penjualan {
            biayaPenarikanLabel.text = isBCA ? "Rp. 0 (BCA)" : data.swiftCode == "gopay" ? "Rp 1.000" : "Rp. 6.500 (untuk non BCA)"
            viewModel.withdrawFee.accept(isBCA ? 0 : data.withdrawFee ?? 0.0)
        }
        updateView()
        
        self.viewModel.checkInputWithdrawal(input: nominalPenarikanTextField.text?.replacingOccurrences(of: ".", with: "").toDouble() ?? 0)
    }
    
    func updateView() {
        let withdrawFee = viewModel.withdrawFee.value
        let withdrawNominal = viewModel.nominal.value ?? 0
        let isWithdrawUnderMin = withdrawNominal < 10000
        let withdrawTotal = withdrawFee + withdrawNominal
        let saldoTotal = tab == .penjualan ? viewModel.data.value?.saldo ?? 0 : viewModel.data.value?.saldoRefund ?? 0
        let isWithdrawExceed = withdrawTotal > saldoTotal
        
        setupView()
        nominalPenarikanLabel.text = withdrawNominal.toMoney()
        totalPenarikanLabel.text = withdrawTotal.toMoney()
        
        if isWithdrawUnderMin {
            topInfoView.backgroundColor = UIColor(hexString: "#FFEBEF")
            topInfoLabel.text = "Batas nominal penarikan Rp. 10.000"
            topInfoLabel.textColor = UIColor(hexString: "E70000")
            nominalPenarikanView.layer.borderColor = UIColor(hexString: "E70000").cgColor
            nominalPenarikanTextField.textColor = UIColor(hexString: "E70000")
            rupiahLabel.textColor = UIColor(hexString: "#E70000")
            return
        }
        
        if isWithdrawExceed {
            topInfoView.backgroundColor = UIColor(hexString: "#FFEBEF")
            topInfoLabel.text = "Penarikan saldo tidak bisa dilakukan karena saldo kamu tidak cukup untuk biaya penarikan"
            topInfoLabel.textColor = UIColor(hexString: "E70000")
            nominalPenarikanView.layer.borderColor = UIColor(hexString: "E70000").cgColor
            nominalPenarikanTextField.textColor = UIColor(hexString: "E70000")
            rupiahLabel.textColor = UIColor(hexString: "#E70000")
            return
        }
        
        guard viewModel.choiceAccountBank.value != nil else { return }
        tarikSaldoButton.isEnabled = true
        tarikSaldoButton.backgroundColor = .primary
    }
    
    @IBAction func tarikSaldoPressed(_ sender: Any) {
        let nominalPenarikan = nominalPenarikanTextField.text?.replacingOccurrences(of: ".", with: "").toDouble()
        if Int(nominalPenarikan!) < 10000 {
            let action = UIAlertAction(title: "OK", style: .default)
            displayAlert(with: .get(.error), message: "Batas nominal penarikan Rp. 10.000", actions: [action])
        } else {
            if viewModel.saveNominal(nominal: nominalPenarikanTextField.text?.replacingOccurrences(of: ".", with: "").toDouble() ?? 0) {
                if let account = viewModel.choiceAccountBank.value {
                    let vc = ConfirmPasswordViewController()
                    vc.handleSuccessVerifyPassword = { [weak self] in
                        guard let self = self else { return }
                        
                        self.withdraw(isGopay: account.swiftCode ?? "" == "gopay")
                    }
                    vc.modalPresentationStyle = .overFullScreen
                    vc.modalTransitionStyle = .crossDissolve
                    present(vc, animated: true)
                } else {
                    navigateToChoiceBank()
                }
            } else {
                
            }
        }
     }
    
    @IBAction func penjualanPressed(_ sender: Any) {
        if tab != .penjualan {
            saldoPenjualanLabel.text = ""
            tab = .penjualan
        }
    }
    
    
    @IBAction func refundPressed(_ sender: Any) {
        if tab != .refund {
            saldoPenjualanLabel.text = ""
            tab = .refund
        }
    }
    
    @IBAction func tarikSemuaPressed(_ sender: Any) {
        let nominal = Double(viewModel.getMaxWithdrawal().replacingOccurrences(of: ".", with: "")) ?? 0
        viewModel.checkInputWithdrawal(input: nominal)
        nominalPenarikanTextField.text = "\(viewModel.getMaxWithdrawal())"
        viewModel.nominal.accept(nominal)
        updateView()
    }
}

extension WithdrawBalanceViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        var textFormatted = textField.text?.replacingOccurrences(of: ",", with: "")
        textFormatted = textFormatted?.replacingOccurrences(of: ".", with: "")
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = "."
        if let text = textFormatted, let textAsInt = Int(text) {
            textField.text = numberFormatter.string(from: NSNumber(value: textAsInt))
        }
    }
}

extension WithdrawBalanceViewController {
    
    private func presentPopUpLimitWithdrawl() {
        let vc = CustomPopUpViewController(
            title: "Maaf, kamu sudah mencapai\nlimit penarikan hari ini",
            description: "Kamu sudah melakukan penarikan saldo sebanyak 2x hari ini, silahkan lakukan\npenarikan lagi di hari berikutnya.",
            okBtnTitle: "Kembali", isHideIcon: true, okBtnBgColor: .primary
        )
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true, completion: nil)
    }
    
    private func navigateToWithdraw(status: String) {
        let accountBank = viewModel.choiceAccountBank.value
        let nominalPenarikan = nominalPenarikanTextField.text?.replacingOccurrences(of: ".", with: "").toDouble() ?? 0.0
        let withdrawFee = accountBank?.withdrawFee ?? 0.0
        let totalWithdrawal = withdrawFee + nominalPenarikan
        let withdrawItem = WithdrawalStatusItem(accountBank: accountBank,
                                                amountWithdrawal: nominalPenarikan,
                                                totalWithdrawal: totalWithdrawal,
                                                status: status)
        let vc = WithdrawalStatusViewController(withdrawalStatusItem: withdrawItem)
        vc.handleBackToDonationList = { [weak self] in
            guard let self = self else { return }
            guard self.didWithdraw != nil else {
                self.viewModel.fetchData()
                self.setupViewForTab(tab: tab)
                self.setupView()
                return
            }
            
            self.navigationController?.popViewController(animated: false)
            self.didWithdraw?()
        }
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    func withdraw(isGopay: Bool) {
        let path = "balance/withdrawl\(isGopay ? "/payout" : "")"
        let headerParamaters = ["Authorization": "Bearer \(getToken() ?? "")", "Content-Type": "application/json"]
        
        let nominal = viewModel.nominal.value ?? 0.0
        let bankAccountId = viewModel.choiceAccountBank.value?.id ?? ""
        let withdrawFee = viewModel.choiceAccountBank.value?.withdrawFee ?? 0.0
        let total = nominal
        let bodyParamaters: [String: Any] = ["bankAccountId": bankAccountId, "nominal": total, "accountBalanceType": viewModel.type.value.rawValue]
        
        if isGopay {
            let endpoint: Endpoint<RemoteDonationWithdrawGopay?> = Endpoint(
                path: path, method: .post,
                headerParamaters: headerParamaters,
                bodyParamaters: bodyParamaters
            )
            
            DIContainer.shared.apiDataTransferService.request(with: endpoint) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .failure(let error):
                    if error.statusCode == 400 {
                        self.presentPopUpLimitWithdrawl()
                    } else {
                        DispatchQueue.main.async {
                            Toast.share.show(message: error.message)
                        }
                    }
                case .success(let response):
                    self.navigateToWithdraw(status: response?.data?.payouts?.first?.status ?? "success")
                }
            }
        } else {
            struct Root: Codable {
                let code, message: String?
            }
            let endpoint: Endpoint<Root?> = Endpoint(
                path: path, method: .post,
                headerParamaters: headerParamaters,
                bodyParamaters: bodyParamaters
            )
            
            DIContainer.shared.apiDataTransferService.request(with: endpoint) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .failure(let error):
                    if error.statusCode == 400 {
                        self.presentPopUpLimitWithdrawl()
                    } else {
                        DispatchQueue.main.async {
                            Toast.share.show(message: error.message)
                        }
                    }
                case .success(_):
                    self.navigateToWithdraw(status: "success")
                }
            }
        }
    }
}

extension WithdrawBalanceViewController: UIGestureRecognizerDelegate { }
