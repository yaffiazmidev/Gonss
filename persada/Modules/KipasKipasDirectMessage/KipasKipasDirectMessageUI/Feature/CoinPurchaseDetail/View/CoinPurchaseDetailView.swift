//
//  CoinPurchaseDetailView.swift
//  KipasKipasDirectMessage
//
//  Created by DENAZMI on 10/08/23.
//

import UIKit
import KipasKipasDirectMessage

protocol CoinPurchaseDetailViewDelegate: AnyObject {
    
}

public enum CoinPurchaseStatus: String {
    case complete = "COMPLETE"
    case process = "PROCESS"
    case cancelled = "CANCELLED"
}

public enum CoinActivityType: String {
    case dm = "DM_TRANSACTION"
    case gift = "GIFT"
    case topup = "TOP_UP"
}

class CoinPurchaseDetailView: UIView {
    
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var invoiceContainerStackView: UIStackView!
    @IBOutlet weak var paymentContainerStackView: UIStackView!
    @IBOutlet weak var detailTotalPaymentContainerStackView: UIStackView!
    @IBOutlet weak var recipientContainerStackView: UIStackView!
    
    @IBOutlet weak var coinUsageContainer: UIStackView!
    @IBOutlet weak var coinUsageTitleLabel: UILabel!
    @IBOutlet weak var coinUsageDetailLabel: UILabel!
    
    @IBOutlet weak var noInvoiceLabel: UILabel!
    @IBOutlet weak var totalCoinLabel: UILabel!
    
    @IBOutlet weak var coinPriceLabel: UILabel!
    
    @IBOutlet weak var bankFeeLabel: UILabel!
    @IBOutlet weak var totalPaymentLabel: UILabel!
    
    @IBOutlet weak var paymentNameLabel: UILabel!
    @IBOutlet weak var recipientNameLabel: UILabel!
    @IBOutlet weak var transactionDateLabel: UILabel!
    
    
    
    weak var delegate: CoinPurchaseDetailViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupView(purchaseStatus: CoinPurchaseStatus, type: CoinActivityType) {
        
        switch (purchaseStatus, type) {
        case (.process, _):
            statusLabel.text = "Pembelian koin sedang diproses"
            totalCoinLabel.font = .roboto(.medium, size: 14)
            totalCoinLabel.textColor = .night
            statusImageView.setImage("ic_hourglass_blue")
            
        case (.complete, .topup):
            statusLabel.text = "Beli Koin Berhasil"
            statusImageView.setImage("ic_success_green")
            totalCoinLabel.font = .roboto(.medium, size: 14)
            totalCoinLabel.textColor = .night
            coinUsageContainer.isHidden = true
            recipientContainerStackView.isHidden = true
            
        case (.complete, .dm):
            statusLabel.text = "Koin Digunakan"
            statusImageView.setImage("img_coin_gold")
            paymentContainerStackView.isHidden = true
            invoiceContainerStackView.isHidden = true
            detailTotalPaymentContainerStackView.isHidden = true
            totalCoinLabel.textColor = .ferrariRed
            coinUsageDetailLabel.text = "DM Berbayar"
            
        case (.complete, .gift):
            statusLabel.text = "Koin Digunakan"
            statusImageView.setImage("img_coin_gold")
            paymentContainerStackView.isHidden = true
            invoiceContainerStackView.isHidden = true
            detailTotalPaymentContainerStackView.isHidden = true
            totalCoinLabel.textColor = .ferrariRed
            coinUsageDetailLabel.text = "Live Streaming Gift"
            
        case (.cancelled, _):
            statusLabel.text = "Pembelian Gagal"
            statusImageView.setImage("ic_cancel")
            totalCoinLabel.font = .roboto(.medium, size: 14)
            totalCoinLabel.textColor = .night
            recipientContainerStackView.isHidden = true
            coinUsageContainer.isHidden = true
        }
    }
    
    func setupComponent(item: RemoteCurrencyHistoryDetailData?) {
        noInvoiceLabel.text = item?.invoiceNumber ?? ""
        totalCoinLabel.text = "\(totalCoinLabel.textColor == .night ? "" : "-")\(item?.qty ?? 0)"
        coinPriceLabel.text = item?.totalAmount?.toCurrency()
        bankFeeLabel.text = Double(item?.bankFee ?? 0).toCurrency()
        
        let totalPayment = Double(item?.totalAmount ?? 0) + Double(item?.bankFee ?? 0)
        totalPaymentLabel.text = totalPayment.toCurrency()
        totalPaymentLabel.font = .roboto(.medium, size: 14)
        totalPaymentLabel.textColor = .night
        
        paymentNameLabel.text = item?.storeName ?? ""
        recipientNameLabel.text = item?.recipient ?? "-"
        transactionDateLabel.text = item?.createAt?.toDate(format: "dd MMM yyyy HH:mm:ss")
    }
}
