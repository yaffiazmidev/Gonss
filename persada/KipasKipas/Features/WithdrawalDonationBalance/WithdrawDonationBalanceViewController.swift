//
//  WithdrawDonationBalanceViewController.swift
//  KipasKipas
//
//  Created by DENAZMI on 24/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

protocol IWithdrawDonationBalanceViewController: AnyObject {
    func displaySuccessWithdrawalBank()
    func displaySuccessWithdrawalGopay(payout: RemoteDonationWithdrawGopayPayout)
    func displayErrorWithdrawal(message: String)
}

class WithdrawDonationBalanceViewController: UIViewController {

    @IBOutlet weak var destinationAccountStackView: UIStackView!
    @IBOutlet weak var amountAvailableLabel: UILabel!
    @IBOutlet weak var emptyBankAccountLabel: UILabel!
    @IBOutlet weak var bankNameLabel: UILabel!
    @IBOutlet weak var bankNumberLabel: UILabel!
    @IBOutlet weak var bankAccountNameLabel: UILabel!
    @IBOutlet weak var withdrawAmountTextField: UITextField!
    @IBOutlet weak var withdrawButton: UIButton!
    @IBOutlet weak var withdrawAllAmountLabel: UILabel!
    @IBOutlet weak var withdrawalAmountLabel: UILabel!
    @IBOutlet weak var withdrawalFeesLabel: UILabel!
    @IBOutlet weak var totalWithdrawalLabel: UILabel!
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var nominalWithdrawalStackView: UIStackView!
    @IBOutlet weak var errorWithdrawal: UIStackView!
    @IBOutlet weak var errorWithdrawalLabel: UILabel!
    
    var interactor: IWithdrawDonationBalanceInteractor!
    var router: IWithdrawDonationBalanceRouter!
    
    private var postDonationId: String = ""
    private var amountAvailable: Double = 0.0
    private var withdrawalFees: Double = 0.0
    private var accountBank: AccountDestinationModel?
    var handleReloadDonationList: (() -> Void)?
    
    init(amountAvailable: Double, postDonationId: String) {
        super.init(nibName: nil, bundle: nil)
        self.amountAvailable = amountAvailable
        self.postDonationId = postDonationId
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tarik Saldo"
        overrideUserInterfaceStyle = .light
        
        amountAvailableLabel.text = amountAvailable.toMoney()
        withdrawalFeesLabel.text = withdrawalFees.toMoney()
        withdrawAmountTextField.delegate = self
        withdrawAmountTextField.addTarget(self, action: #selector(didValueChange(_:)), for: .editingChanged)
        handleOnTap()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func handleOnTap() {
        view.onTap { [weak self] in
            guard let self = self else { return }
            self.view.endEditing(true)
        }
        
        destinationAccountStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.navigateToChoiceBank()
        }
        
        withdrawButton.onTap { [weak self] in
            guard let self = self else { return }
            self.navigateToConfirmPassword()
        }
        
        withdrawAllAmountLabel.onTap { [weak self] in
            guard let self = self else { return }
            self.withdrawAmountTextField.text = "\(self.amountAvailable)".toMoney(withCurrency: false)
            self.calculateWithdrawalTotal()
        }
    }
    
    private func navigateToConfirmPassword() {
        let vc = ConfirmPasswordViewController()
        vc.handleSuccessVerifyPassword = { [weak self] in
            guard let self = self else { return }
            let withdrawAmount = Double(Int(self.withdrawAmountTextField.text?.digits() ?? "0") ?? 0)
            let total = withdrawAmount
            DispatchQueue.main.async { KKLoading.shared.show() }
            self.interactor.withdraw(bankAccountId: self.accountBank?.id ?? "",
                                     nominal: total,
                                     postDonationId: self.postDonationId, isGopay: self.accountBank?.swiftCode ?? "" == "gopay")
        }
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }
    
    private func navigateToWithdraw(status: String) {
        let withdrawAmount = Double(Int(withdrawAmountTextField.text?.digits() ?? "0") ?? 0)
        let withdrawalFees = accountBank?.withdrawFee ?? 0.0
        let totalWithdrawal = withdrawalFees + withdrawAmount
        let withdrawItem = WithdrawalStatusItem(accountBank: accountBank,
                                                amountWithdrawal: withdrawAmount,
                                                totalWithdrawal: totalWithdrawal,
                                                status: status)
        let vc = WithdrawalStatusViewController(withdrawalStatusItem: withdrawItem)
        vc.handleBackToDonationList = { [weak self] in
            guard let self = self else { return }
            self.handleReloadDonationList?()
            self.navigationController?.popViewController(animated: true)
        }
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    func navigateToChoiceBank() {
        let vc = AccountDestinationViewController(isMyAccount: false)
        vc.bindNavigationBar("Rekening Tujuan")
        vc.choice = { [weak self] data in
            guard let self = self else { return }
            self.withdrawalFees = data.withdrawFee ?? 0.0
            self.withdrawalFeesLabel.text = data.withdrawFee?.toMoney()
            self.setupBankAccount(bank: data)
            self.calculateWithdrawalTotal()
        }
        vc.selectedBank = accountBank
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func calculateWithdrawalTotal() {
        let withdrawAmount = Double(Int(withdrawAmountTextField.text?.digits() ?? "0") ?? 0)
        let total = withdrawalFees + withdrawAmount
        totalWithdrawalLabel.text = total.toMoney()
        withdrawalAmountLabel.text = withdrawAmount.toMoney()
        let notEnoughSaldo = amountAvailable < 10_000 || amountAvailable < withdrawAmount
        let notEnoughWithdrawalFee = withdrawAmount < 10_000
        if notEnoughSaldo {
            showError(with: "Penarikan saldo tidak bisa dilakukan karena saldo kamu tidak cukup untuk biaya penarikan")
        } else if notEnoughWithdrawalFee {
            showError(with: "Minimal penarikan 10.000")
        } else {
            showError(with: "")
        }
        
        enableWithdrawButton()
    }
    
    @objc private func didValueChange(_ textField: UITextField) {
        guard let amount = textField.text, !amount.isEmpty else {
            showError(with: "")
            return
        }
        withdrawAmountTextField.text = amount.digits().toMoney(withCurrency: false)
        calculateWithdrawalTotal()
    }
    
    private func showError(with message: String) {
        if message.isEmpty {
            errorWithdrawal.isHidden = true
            errorWithdrawalLabel.text = ""
            nominalWithdrawalStackView.setBorderColor = .whiteSmoke
            nominalWithdrawalStackView.setBorderWidth = 1
        } else {
            errorWithdrawal.isHidden = false
            errorWithdrawalLabel.text = message
            nominalWithdrawalStackView.setBorderColor = .warning
            nominalWithdrawalStackView.setBorderWidth = 1
        }
    }
    
    private func enableWithdrawButton() {
        let withdrawAmount = Double(Int(withdrawAmountTextField.text?.digits() ?? "0") ?? 0)
        let total = withdrawalFees + withdrawAmount
        let minimalDonation: Double = 10_000
        withdrawButton.isEnabled = total >= minimalDonation + withdrawalFees && total <= amountAvailable && accountBank != nil
        notificationLabel.text = total <= amountAvailable ? "Penarikan hanya bisa dilakukan 2x dalam 1 hari" : "Penarikan saldo tidak bisa dilakukan karena saldo kamu tidak cukup untuk biaya penarikan"
        withdrawButton.backgroundColor = withdrawButton.isEnabled ? .primary : .primaryDisabled
    }
    
    private func setupBankAccount(bank: AccountDestinationModel?) {
        accountBank = bank
        emptyBankAccountLabel.isHidden = bank != nil
        bankNameLabel.isHidden = bank == nil
        bankNumberLabel.isHidden = bank == nil
        bankAccountNameLabel.isHidden = bank == nil
        bankNameLabel.text = bank?.namaBank ?? "-"
        bankNumberLabel.text = bank?.noRek ?? "-"
        bankAccountNameLabel.text = bank?.nama ?? "-"
        enableWithdrawButton()
    }
}

extension WithdrawDonationBalanceViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        withdrawalAmountLabel.text = 0.toMoney()
        totalWithdrawalLabel.text = withdrawalFees.toMoney()
        withdrawButton.isEnabled = false
        withdrawButton.backgroundColor = .primaryDisabled
        return true
    }
}

extension WithdrawDonationBalanceViewController: IWithdrawDonationBalanceViewController {
    func displaySuccessWithdrawalBank() {
        DispatchQueue.main.async { KKLoading.shared.hide() }
        navigateToWithdraw(status: "success")
    }
    
    func displaySuccessWithdrawalGopay(payout: RemoteDonationWithdrawGopayPayout) {
        DispatchQueue.main.async { KKLoading.shared.hide() }
        navigateToWithdraw(status: payout.status ?? "")
    }
    
    func displayErrorWithdrawal(message: String) {
        DispatchQueue.main.async {
            KKLoading.shared.hide()
            Toast.share.show(message: message)
        }
    }
}
