//
//  SuccessWithdrawalViewController.swift
//  KipasKipas
//
//  Created by iOS Dev on 28/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SuccessWithdrawalViewController: UIViewController {
    @IBOutlet weak var nominalPenarikanLabel: UILabel!
    @IBOutlet weak var biayaPenarikanLabel: UILabel!
    @IBOutlet weak var namaBankLabel: UILabel!
    @IBOutlet weak var infoRekLabel: UILabel!
    @IBOutlet weak var backToShopButton: UIButton!
    
    let disposeBag = DisposeBag()
    var from: UIViewController?
    var model: HistoryTransactionModel?
    var viewModel: WithdrawalBalanceViewModel?
    var biayaPenarikan = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        if let vc = from, vc.nibName == "HistoryTransactionsViewController" {
            guard let model = model else { return }
            title = "Detail Riwayat Transaksi"
            backToShopButton.isHidden = true
            setupViewFromHistoryTransaction(model: model)
        } else {
            title = "Penarikan Berhasil"
            setupView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let vc = from, vc.nibName == "HistoryTransactionsViewController" {
            setupNavbar()
        } else {
            setupNavbarWithoutLeftItem()
        }
    }
    
    func setupViewFromHistoryTransaction(model: HistoryTransactionModel) {
        self.nominalPenarikanLabel.text = model.currency.toMoney()
        self.biayaPenarikanLabel.text = model.bankFee?.toMoney() ?? "Rp. 0"
        self.namaBankLabel.text = model.bankAccountName ?? ""
        self.infoRekLabel.text = "\(model.bankName ?? "") - \(model.bankAccountNumber ?? "")"
    }
    
    func setupView() {
        guard let viewModel = viewModel else { return }
        nominalPenarikanLabel.text = viewModel.nominal.value?.toMoney() ?? ""
        biayaPenarikanLabel.text = viewModel.data.value?.withdrawFee?.toMoney() ?? biayaPenarikan
        namaBankLabel.text = viewModel.choiceAccountBank.value?.namaBank ?? ""
        infoRekLabel.text = "\(viewModel.choiceAccountBank.value?.nama ?? "") - \(viewModel.choiceAccountBank.value?.noRek ?? "")"
    }
    
    @IBAction func backToMyShop(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
