//
//  WithdrawalStatusViewController.swift
//  KipasKipas
//
//  Created by DENAZMI on 04/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

struct WithdrawalStatusItem {
    let accountBank: AccountDestinationModel?
    let amountWithdrawal: Double
    let totalWithdrawal: Double
    let status: String
}

class WithdrawalStatusViewController: UIViewController {
    
    @IBOutlet weak var withdrawalAmountLabel: UILabel!
    @IBOutlet weak var withdrawalFeesLabel: UILabel!
    @IBOutlet weak var totalWithdrawalLabel: UILabel!
    @IBOutlet weak var bankNameLabel: UILabel!
    @IBOutlet weak var bankAccountNameLabel: UILabel!
    @IBOutlet weak var statusMessageLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var statusDescriptionLabel: UILabel!
    
    private var withdrawalStatusItem: WithdrawalStatusItem?
    var handleBackToDonationList: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        setupComponent()
    }
    
    init(withdrawalStatusItem: WithdrawalStatusItem) {
        super.init(nibName: nil, bundle: nil)
        self.withdrawalStatusItem = withdrawalStatusItem
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupComponent() {
        let accountBankName = withdrawalStatusItem?.accountBank?.nama ?? ""
        let accountBankNumber = withdrawalStatusItem?.accountBank?.noRek ?? ""
        bankAccountNameLabel.text   = "\(accountBankName) - \(accountBankNumber)"
        withdrawalAmountLabel.text  = withdrawalStatusItem?.amountWithdrawal.toMoney()
        withdrawalFeesLabel.text    = withdrawalStatusItem?.accountBank?.withdrawFee?.toMoney()
        totalWithdrawalLabel.text   = withdrawalStatusItem?.totalWithdrawal.toMoney()
        bankNameLabel.text          = withdrawalStatusItem?.accountBank?.namaBank ?? "-"
        
        let isProccess = withdrawalStatusItem?.status == "queued"
        statusMessageLabel.text = isProccess ? "Dalam proses pengiriman dana.." : "Berhasil dikirim ke rekening tujuan"
        statusMessageLabel.textColor = isProccess ? .warning : .success
        statusImageView.image = UIImage(named: isProccess ? "ic_hourglass_fill_blue" : "ic_circle_check_fill_green")
                
        if withdrawalStatusItem?.accountBank?.swiftCode == "gopay" {
            statusDescriptionLabel.text = isProccess ? "Permintaan penarikan saldo GoPay sedang diproses. Kami akan memberitahu Anda ketika penarikan saldo sudah berhasil. Terima kasih." : "Penarikan saldo GoPay berhasil dilakukan dan saldo sudah masuk ke rekening Anda. Terima kasih."
        } else {
            let isSuccess = withdrawalStatusItem?.status ?? "" == "success"
            statusDescriptionLabel.text = isSuccess ? "Penarikan Dana Berhasil" : "Penarikan Dana Gagal"
        }
        
    }
    
    @IBAction func didClickButtonBackToDonationList(_ sender: Any) {
        if isModal, navigationController != nil {
            navigationController?.popViewController(animated: true)
            self.handleBackToDonationList?()
            return
        }
        
        dismiss(animated: true) {
            self.handleBackToDonationList?()
        }
    }
}
