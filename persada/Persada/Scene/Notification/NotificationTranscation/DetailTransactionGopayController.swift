//
//  DetailTransactionGopayController.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 15/05/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit


final class DetailTransactionGopayController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var withdrawalAmountLabel: UILabel!
    @IBOutlet weak var withdrawalFeesLabel: UILabel!
    @IBOutlet weak var totalWithdrawalLabel: UILabel!
    @IBOutlet weak var bankNameLabel: UILabel!
    @IBOutlet weak var bankAccountNameLabel: UILabel!
    @IBOutlet weak var statusMessageLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var statusDescriptionLabel: UILabel!
    
    private var withdraw: Withdrawl?

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        setupComponent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    init(withdraw: Withdrawl) {
        super.init(nibName: nil, bundle: nil)
        self.withdraw = withdraw
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupComponent() {
        let accountBankName = withdraw?.bankAccountName ?? ""
        let accountBankNumber = withdraw?.bankAccount ?? ""
        bankAccountNameLabel.text   = "\(accountBankName) - \(accountBankNumber)"
        withdrawalAmountLabel.text  = withdraw?.nominal?.toMoney() ?? "Rp 0"
        withdrawalFeesLabel.text    = withdraw?.bankFee?.toMoney() ?? "Rp 0"
        totalWithdrawalLabel.text   = withdraw?.total?.toMoney() ?? "Rp 0"
        bankNameLabel.text          = withdraw?.bankName ?? "-"
        
        let isProccess = withdraw?.status == "queue"
        statusMessageLabel.text = isProccess ? "Dalam proses pengiriman dana.." : "Berhasil dikirim ke rekening tujuan"
        statusMessageLabel.textColor = isProccess ? .warning : .success
        statusImageView.image = UIImage(named: isProccess ? "ic_hourglass_fill_blue" : "ic_circle_check_fill_green")
                
        if withdraw?.bankName == "GOPAY" {
            statusDescriptionLabel.text = isProccess ? "Permintaan penarikan saldo GoPay sedang diproses. Kami akan memberitahu Anda ketika penarikan saldo sudah berhasil. Terima kasih." : "Penarikan saldo GoPay berhasil dilakukan dan saldo sudah masuk ke rekening Anda. Terima kasih."
        } else {
            let isSuccess = withdraw?.status ?? "" == "success"
            statusDescriptionLabel.text = isSuccess ? "Penarikan Dana Berhasil" : "Penarikan Dana Gagal"
        }
        
    }
}
