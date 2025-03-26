//
//  OrderTransactionPurchaseWithButtonCell.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 04/07/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

class OrderTransactionPurchaseWithButtonCell: UITableViewCell {

    var item: OrderCellViewModel!
    
    var handleTransaction: ((String, String, String?) -> Void)?
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var viewBg: UIView!
    @IBOutlet weak var buttonAction: PrimaryButton!
    
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
        
        buttonAction.titleLabel?.font = .Roboto(.bold, size: 14)
        buttonAction.layer.cornerRadius = 4
        buttonAction.addTarget(self, action: #selector(handleTransactionWhenTappedButton), for: .touchUpInside)
        buttonAction.isUserInteractionEnabled = true
    }
    
    func setUpCell(item object: OrderCellViewModel, buttonText : String) {
        
        iconImageView.loadImage(at: object.urlProductPhoto )
        titleLabel.text = object.productName
        priceLabel.text = "\(object.amount.toMoney())"
        
        if buttonText.isEmpty {
            buttonAction.isHidden = true
        } else {
            buttonAction.setTitle(buttonText, for: .normal)
        }
        if object.orderStatus == "CANCELLED" || object.paymentStatus == "FAILED" {
            statusLabel.textColor = .redError
            statusLabel.text = "Dibatalkan"
        }
        
        self.item = object
        setupView()
        
        
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
        case ("COMPLETE", "SETTLED", "DELIVERED", "COMPLETE"):
            statusLabel.text = "Selesai"
        case ("COMPLETE", "SETTLED", "DELIVERED", "WAIT"):
            statusLabel.text = "Selesai"
        default:
            break
        }

        if object.isOrderComplaint {
            buttonAction.setTitle("Sudah mengajukan Komplain", for: .normal)
            buttonAction.backgroundColor = .whiteSnow
            buttonAction.setTitleColor(.placeholder, for: .normal)
            buttonAction.isUserInteractionEnabled = false
        }
        
        if object.reviewStatus == "COMPLETE" {
            buttonAction.isEnabled = false
            buttonAction.backgroundColor = .whiteSnow
            buttonAction.setTitleColor(.grey, for: .normal)
        }else{
            buttonAction.isEnabled = true
            buttonAction.backgroundColor = .primary
            buttonAction.setTitleColor(.white, for: .normal)
        }
    }
    
    @objc
    func handleTransactionWhenTappedButton() {
        let itemCourier = item.courier
        let itemOrderId = item.id
        let itemStatusLogistic = item.shipmentStatus ?? nil
        self.handleTransaction?(itemCourier, itemOrderId, itemStatusLogistic)
    }
    
}
