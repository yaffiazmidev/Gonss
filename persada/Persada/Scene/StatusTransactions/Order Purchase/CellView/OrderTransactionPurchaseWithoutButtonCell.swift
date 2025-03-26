//
//  OrderTransactionPurchaseWithoutButtonCell.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 04/07/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

class OrderTransactionPurchaseWithoutButtonCell: UITableViewCell {

    var item: OrderCellViewModel!
    var handleTransaction: ((String, String, String?) -> Void)?
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var viewBg: UIView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupView() {
        titleLabel.textColor = .black
        titleLabel.font = UIFont.Roboto(.regular, size: 14)
        
        priceLabel.textColor = .contentGrey
        priceLabel.font = UIFont.Roboto(.bold, size: 12)
        priceLabel.numberOfLines = 0
        
        statusLabel.textColor = .secondary
        statusLabel.font = UIFont.Roboto(.medium, size: 10)
        statusLabel.numberOfLines = 0
        
        iconImageView.backgroundColor = .whiteSnow
        iconImageView.layer.cornerRadius = 4
        iconImageView.clipsToBounds = true
        
        viewBg.layer.shadowOffset = CGSize(width: 2, height: 2)
        viewBg.layer.shadowRadius = 2
        viewBg.layer.shadowOpacity = 0.06
        viewBg.layer.cornerRadius = 8
        viewBg.layer.borderColor = UIColor.placeholder.cgColor
        viewBg.layer.borderWidth = 0.1
    }
    
    func setUpCell(item object: OrderCellViewModel, buttonText : String) {
        setupView()
        iconImageView.loadImage(at: object.urlProductPhoto )
        titleLabel.text = object.productName
        if object.productType == "RESELLER" {
            
            let commission = object.amount
//            (object.modal ?? 0) + (object.commission ?? 0)
            
            let attributedText = NSMutableAttributedString(string: "\(commission.toMoney())",
                                                                                      attributes: [NSAttributedString.Key.font: UIFont.Roboto(.regular, size: 12), NSAttributedString.Key.foregroundColor: UIColor.contentGrey ])
            
            attributedText.append(NSMutableAttributedString(string: "   Dijual Reseller",
                                                            attributes: [NSAttributedString.Key.font: UIFont.Roboto(.regular, size: 10), NSAttributedString.Key.foregroundColor: UIColor(hexString: "BBBBBB", alpha: 1) ]))
            
            let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 8
            
            attributedText.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedText.length))
            
            priceLabel.attributedText = attributedText
        } else {
            priceLabel.text = object.amount.toMoney()
        }
        
        self.item = object
        
        if object.orderStatus == "CANCELLED" || object.paymentStatus == "FAILED" {
            statusLabel.textColor = .redError
            statusLabel.text = "Dibatalkan"
        }
        
        switch (object.orderStatus, object.paymentStatus, object.shipmentStatus, object.reviewStatus) {
        case ("NEW", "WAIT", "", ""):
            statusLabel.text = "Menunggu Konfirmasi Pembayaran"
        case ("PROCESS", "PAID", "DELIVERED", ""):
            statusLabel.text = "Pesanan Dikirim"
        case ("NEW", "PAID", "", ""):
            statusLabel.text = "Menunggu Diproses Penjual"
        case ("PROCESS", "PAID", "PACKAGING", ""):
            statusLabel.text = "Pesanan Diproses"
        case ("PROCESS", "PAID", "SHIPPING", ""):
            statusLabel.text = "Pesanan Dikirim"
        case ("PROCESS", "PAID", "DELIVERED", ""):
            statusLabel.text = "Pesanan Telah Diterima"
        case ("COMPLETE", "SETTLED", "DELIVERED", "WAIT"):
            statusLabel.text = .get(.addReview)
        case ("COMPLETE", "SETTLED", "DELIVERED", "COMPLETE"):
            statusLabel.text = "Selesai"
        default:
            break
        }
    }
    
    @objc
    func handleTransactionWhenTappedButton() {
        let itemInvoice = item.orderStatus
        let itemPayment = item.paymentStatus
        let itemStatusLogistic = item.shipmentStatus ?? nil
        self.handleTransaction?(itemInvoice, itemPayment, itemStatusLogistic)
    }
    
}
