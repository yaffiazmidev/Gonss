//
//  AccountDestinationViewController.swift
//  KipasKipas
//
//  Created by iOS Dev on 26/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import KipasKipasShared

class AccountDestinationViewController: UIViewController, AlertDisplayer {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveButton: UIButton!
    
    var viewModel = AccountDestinationViewModel()
    var disposeBag = DisposeBag()
    
    var choice: ((AccountDestinationModel) -> Void)? = nil
    var selectedBank: AccountDestinationModel?
    var bankAccounts: [AccountDestinationModel] = []
    var gopayAccounts: [AccountDestinationModel] = []
    let isMyAccount: Bool
    
    init(isMyAccount: Bool) {
        self.isMyAccount = isMyAccount
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isHidden = isMyAccount
        registerObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupView()
        viewModel.fetchBanckAccount()
    }
    
    func setupView() {
        overrideUserInterfaceStyle = .light
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UINib(nibName: "DataBankUserTableViewCell", bundle: nil), forCellReuseIdentifier: "DataBankCell")
        
        navigationController?.navigationBar.layer.shadowColor   = UIColor.black.cgColor
        navigationController?.navigationBar.layer.shadowOpacity = 0.2
        navigationController?.navigationBar.layer.shadowOffset  = CGSize.zero
        navigationController?.navigationBar.layer.shadowRadius  = 2
    }
    
    func registerObserver() {
        viewModel.data.subscribe(onNext: { [weak self] bankAccounts in
            guard let self = self else { return }
            
            self.bankAccounts = bankAccounts.filter({ $0.swiftCode != "gopay" })
            self.gopayAccounts = bankAccounts.filter({ $0.swiftCode == "gopay" })
            self.tableView.reloadData()
        }).disposed(by: disposeBag)
        
        viewModel.isLoading.subscribe(onNext: { [weak self] isLoading in
            guard self != nil else { return }
            
            guard let isLoading = isLoading else { return }
            if isLoading {
                DispatchQueue.main.async { KKLoading.shared.show() }
            } else {
                DispatchQueue.main.async { KKLoading.shared.hide() }
            }
        }).disposed(by: disposeBag)
        
        viewModel.errorMessage.subscribe(onNext: { [weak self] message in
            guard let self = self else { return }
            guard let message = message else { return }
            if !message.isEmpty {
                let action = UIAlertAction(title: "OK", style: .default)
                self.displayAlert(with: .get(.error), message: message, actions: [action])
            }
        }).disposed(by: disposeBag)
    }
    
    func presentAddAcountBank() {
        let vc = FormAddAccountBankViewController()
        vc.handleAddBankAccount = { [weak self] bank in
            guard let self = self else { return }
            self.navigateToOTPMethodOption(bank: bank)
        }
        vc.bindNavigationBar("Tambah Rekening")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToOTPMethodOption(bank: AccountDestinationModel?) {
        let otpMethodOption = OTPMethodOptionViewController(
          otpFrom: .bankAccount, phoneNumber: "",
          whatsappCountdown: CountdownManager(notificationCenter: NotificationCenter.default, willResignActive: UIApplication.willResignActiveNotification, willEnterForeground: UIApplication.willEnterForegroundNotification),
          smsCountdown: CountdownManager(notificationCenter: NotificationCenter.default, willResignActive: UIApplication.willResignActiveNotification, willEnterForeground: UIApplication.willEnterForegroundNotification))
        otpMethodOption.bankAccount = bank
        self.navigationController?.pushViewController(otpMethodOption, animated: true)
    }
    
    @IBAction func simpanPressed(_ sender: Any) {
        guard let bank = selectedBank else {
            DispatchQueue.main.async {
                Toast.share.show(message: "Silahkan pilih rekening tujuan terlebih dahulu..")
            }
            return
        }
        
        choice?(bank)
        navigationController?.popViewController(animated: true)
    }
}

extension AccountDestinationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let bank = bankAccounts[indexPath.row]
            selectedBank = bank
            choice?(bank)
        } else {
            let gopay = gopayAccounts[indexPath.row]
            selectedBank = gopay
            choice?(gopay)
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let vc = CustomPopUpViewController(
                title: "Hapus Rekening",
                description: "Apa kamu yakin menghapus rekening ini?",
                withOption: true,
                isHideIcon: true
            )
            vc.handleTapOKButton = { [weak self] in
                guard let self = self else { return }
                let accountId = indexPath.section == 0 ? self.bankAccounts[indexPath.row].id : self.gopayAccounts[indexPath.row].id
                self.navigateToConfirmPassword(accountId: accountId ?? "", completion: { [weak self] result in
                    guard self != nil else { return }
                    
                    DispatchQueue.main.async { KKLoading.shared.hide() }
                    
                    switch result {
                    case .success(_):
                        tableView.beginUpdates()
                        
                        if indexPath.section == 0 {
                            self?.bankAccounts.remove(at: indexPath.row)
                        } else {
                            self?.gopayAccounts.remove(at: indexPath.row)
                        }
                        
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        tableView.endUpdates()
                    case .failure(let error):
                        DispatchQueue.main.async { Toast.share.show(message: error.localizedDescription) }
                    }
                })
            }
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
        }
    }
    
    private func navigateToConfirmPassword(accountId: String, completion: @escaping ((Swift.Result<RemoteDonationWithdrawGopay?, DataTransferError>) -> Void)) {
        let vc = ConfirmPasswordViewController()
        vc.handleSuccessVerifyPassword = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async { KKLoading.shared.show() }
            self.deleteBankAccount(accountId: accountId, completion: completion)
        }
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }
    
    private func deleteBankAccount(accountId: String, completion: @escaping ((Swift.Result<RemoteDonationWithdrawGopay?, DataTransferError>) -> Void)) {
        let endpoint: Endpoint<RemoteDonationWithdrawGopay?> = Endpoint(
            path: "/bankaccounts/\(accountId)",
            method: .delete,
            headerParamaters: ["Authorization": "Bearer \(getToken() ?? "")", "Content-Type": "application/json"]
        )
        
        DIContainer.shared.apiDataTransferService.request(with: endpoint, completion: completion)
    }
}

extension AccountDestinationViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? bankAccounts.count : gopayAccounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DataBankCell") as! DataBankUserTableViewCell
            let item = bankAccounts[indexPath.row]
            cell.data = item
            cell.isSelected(item.id == selectedBank?.id ?? "")
            cell.bankNameLabel.isHidden = false
            cell.iconImage.isHidden = isMyAccount
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DataBankCell") as! DataBankUserTableViewCell
            let item = gopayAccounts[indexPath.row]
            cell.data = item
            cell.isSelected(item.id == selectedBank?.id ?? "")
            cell.bankNameLabel.isHidden = true
            cell.iconImage.isHidden = isMyAccount
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .whiteSmoke
        
        if section == 0 {
            let titleLabel = UILabel()
            titleLabel.frame = CGRect(x: 10, y: 10, width: view.frame.width - 24, height: 14)
            titleLabel.text = "Bank"
            titleLabel.font = .Roboto(.bold, size: 12)
            titleLabel.textColor = .black
            headerView.addSubview(titleLabel)
            return headerView
        } else {
            let titleIcon = UIImageView()
            titleIcon.frame = CGRect(x: 10, y: 10, width: 74, height: 14)
            titleIcon.image = UIImage(named: "img_gopay")
            titleIcon.clipsToBounds = true
            titleIcon.contentMode = .scaleAspectFit
            headerView.addSubview(titleIcon)
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .white
        
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 10, y: 10, width: view.frame.width - 24, height: 14)
        titleLabel.text = "+  Tambah akun \(section == 0 ? "bank" : "gopay")"
        titleLabel.font = .Roboto(.bold, size: 12)
        titleLabel.textColor = .secondary
        footerView.addSubview(titleLabel)
        
        footerView.onTap { [weak self] in
            guard let self = self else { return }
            
            if section == 0 {
                self.presentAddAcountBank()
            } else {
                let vc = AddGopayAccountViewController()
                vc.handleSendOTPCallback = { [weak self] bank in
                    guard let self = self else { return }
                    self.navigateToOTPMethodOption(bank: bank)
                }
                vc.bindNavigationBar("Tambah Akun Gopay")
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        if section == 0 {
            return bankAccounts.count >= 2 ? nil : footerView
        } else {
            return gopayAccounts.count >= 2 ? nil : footerView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 35 }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return bankAccounts.count >= 2 ? 0 : 38
        } else {
            return gopayAccounts.count >= 2 ? 0 : 38
        }
    }
}
