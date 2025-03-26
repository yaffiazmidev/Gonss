//
//  InformationListPriceHistoryTableViewCell.swift
//  KipasKipas
//
//  Created by iOS Dev on 21/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class InformationListPriceHistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countPriceTitleLabel: UILabel!
    @IBOutlet weak var countPriceLabel: UILabel!
    @IBOutlet weak var adjustmentTitleLabel: UILabel!
    @IBOutlet weak var adjustmentPriceLabel: UILabel!
    @IBOutlet weak var aboutAdjustmentShippingStackView: UIStackView!
    @IBOutlet weak var adjustmenLabelStackView: UIStackView!
    @IBOutlet weak var penyesuaianOngkirLabel: UILabel!
    @IBOutlet weak var aboutAdjustmentStackView: UIStackView!
    @IBOutlet weak var aboutPenyesuaianView: UIView!
    
    var type: TypeHistoryTransaction = .transaction
    var action: (() -> ())?
    
    var paymentDetail: HistoryTransactionDetailItem? {
        didSet {
            guard let paymentDetail = paymentDetail as? PaymentDetailModel else { return }
            switch type {
            case .transaction, .commission, .reseller:
                titleLabel.text = "Pembayaran"
                countPriceTitleLabel.text = "Total Harga Barang"
                countPriceLabel.text = "\(paymentDetail.totalHargaBarang.toMoney())"
                adjustmentTitleLabel.text = "Penyesuaian Ongkir"
                if let paymentCost = paymentDetail.penyesuaianOngkir {
                    bringSubviewToFront(aboutPenyesuaianView)
                    adjustmentPriceLabel.text = "- \(paymentCost.toMoney())"
                    adjustmentPriceLabel.textColor = UIColor(hexString: "E70000")
                    aboutAdjustmentShippingStackView.isHidden = false
                    adjustmenLabelStackView.isHidden = false
                } else {
                    aboutAdjustmentShippingStackView.isHidden = true
                    adjustmentPriceLabel.text = 0.toMoney()
                }
            default:
                titleLabel.text = "Detail Refund"
            }
            
        }
    }
    
    var paymentDetailRefund: HistoryTransactionDetailItem? {
        didSet {
            guard let paymentDetailRefund = paymentDetailRefund as? PaymentRefundModel else { return }
            titleLabel.text = "Detail Refund"
            countPriceTitleLabel.text = "Harga Barang"
            countPriceLabel.text = "\(paymentDetailRefund.hargaBarang?.toMoney() ?? "")"
            aboutAdjustmentShippingStackView.isHidden = true
            if let _ = paymentDetailRefund.shipmentInitial {
                adjustmentTitleLabel.text = "Penyesuaian"
                adjustmentPriceLabel.text =  "-\(paymentDetailRefund.shipmentCostFinal?.toMoney() ?? "")"
                adjustmentPriceLabel.textColor = UIColor(hexString: "E70000")
            } else {
                adjustmentTitleLabel.text = "Ongkos Kirim"
                adjustmentPriceLabel.text = "\(paymentDetailRefund.shipmentCostFinal?.toMoney() ?? "")"
                adjustmentPriceLabel.textColor = UIColor(hexString: "4A4A4A")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        aboutPenyesuaianView.onTap {
            self.action?()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
