//
//  DiamondWithdrawalDetailView.swift
//  KipasKipasDirectMessage
//
//  Created by DENAZMI on 11/08/23.
//

import UIKit
import KipasKipasDirectMessage

protocol DiamondWithdrawalDetailViewDelegate: AnyObject {
    
}

class DiamondWithdrawalDetailView: UIView {
    
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var totalDiamondLabel: UILabel!
    @IBOutlet weak var totalDiamondTitleLabel: UILabel!
    @IBOutlet weak var exchangeRateContainerStackView: UIStackView!
    @IBOutlet weak var destinationAccountContainerStackView: UIStackView!
    @IBOutlet weak var totalWithdrawalContainerStackView: UIStackView!
    @IBOutlet weak var paidDMContainerStackView: UIStackView!
    
    @IBOutlet weak var conversionPerUnitLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var totalWithdrawalLabel: UILabel!
    @IBOutlet weak var bankNameLabel: UILabel!
    @IBOutlet weak var accountNumberLabel: UILabel!
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var diamondIconView: UIImageView!
    @IBOutlet weak var transactionDateLabel: UILabel!
    weak var delegate: DiamondWithdrawalDetailViewDelegate?
    
    @IBOutlet weak var transactionDateTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupView(
        item: RemoteCurrencyHistoryDetailData?,
        _ status: DiamondPurchaseStatus,
        _ type: DiamondActivityType
    ) {
        switch (status, type) {
        case (.process, _):
            statusImageView.setImage("ic_hourglass_blue")
            statusLabel.text = "Penarikan Diamond Sedang Diproses"
            totalDiamondLabel.text = "\(item?.qty ?? 0)"
            paidDMContainerStackView.isHidden = true
            transactionDateTitleLabel.text = "Tanggal Transaksi"
            
        case (.complete, .withdrawal):
            statusImageView.setImage("ic_success_green")
            statusLabel.text = "Penarikan Diamond Berhasil"
            totalDiamondLabel.text = "\(item?.qty ?? 0)"
            paidDMContainerStackView.isHidden = true
            transactionDateTitleLabel.text = "Tanggal Transaksi"
            
        case (.complete, .dm):
            statusImageView.setImage("img_diamond_blue")
            statusLabel.text = "Diamond Bertambah"
            totalDiamondTitleLabel.text = "Diamond Bertambah"
            exchangeRateContainerStackView.isHidden = true
            destinationAccountContainerStackView.isHidden = true
            totalWithdrawalContainerStackView.isHidden = true
            paidDMContainerStackView.isHidden = false
            sourceLabel.text = "DM Berbayar"
            diamondIconView.isHidden = true
            totalDiamondLabel.text = "+ \(item?.qty ?? 0)"
            transactionDateTitleLabel.text = "Tanggal"
            
        case (.complete, .gift):
            statusImageView.setImage("img_diamond_blue")
            statusLabel.text = "Diamond Bertambah"
            totalDiamondTitleLabel.text = "Diamond Bertambah"
            exchangeRateContainerStackView.isHidden = true
            destinationAccountContainerStackView.isHidden = true
            totalWithdrawalContainerStackView.isHidden = true
            paidDMContainerStackView.isHidden = false
            sourceLabel.text = "Live Streaming"
            diamondIconView.isHidden = true
            totalDiamondLabel.text = "+ \(item?.qty ?? 0)"
            transactionDateTitleLabel.text = "Tanggal"
        }
        
        setupComponent(item: item)
    }
    
    private func setupComponent(item: RemoteCurrencyHistoryDetailData?) {
        conversionPerUnitLabel.text = item?.conversionPerUnit?.toCurrency()
        totalWithdrawalLabel.text = item?.totalAmount?.toCurrency()
        bankNameLabel.text = item?.bankName ?? ""
        accountNumberLabel.text = item?.accountNumber ?? ""
        accountNameLabel.text = item?.accountName ?? ""
        transactionDateLabel.text = item?.createAt?.toDate(format: "dd MMM yyyy HH:mm:ss")
    }
}
