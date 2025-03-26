//
//  DetailTransactionView.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 05/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class DetailTransactionPurchaseView : UIView {
    
    @IBOutlet weak var labelTitleInvoice: UILabel!
    @IBOutlet weak var labelInvoice: UILabel!
    @IBOutlet weak var labelTitlePesanan: UILabel!
    @IBOutlet weak var buttonLihat: UIButton!
    
    @IBOutlet weak var imageProduct: UIImageView!
    
    @IBOutlet weak var labelItemName: UILabel!
    @IBOutlet weak var labelItemPrice: UILabel!
    @IBOutlet weak var labelItemQuantity: UILabel!
    
    @IBOutlet weak var labelTitleNotes: UILabel!
    
    @IBOutlet weak var labelNotes: UILabel!
    
    @IBOutlet weak var labelTitleSendTo: UILabel!
    @IBOutlet weak var labelSendAddress: UILabel!
    
    @IBOutlet weak var labelTitleDurasiPengiriman: UILabel!
    
    @IBOutlet weak var viewDurationBg: UIView!
    @IBOutlet weak var labelExpeditionName: UILabel!
    @IBOutlet weak var labelSendDuration: UILabel!
    @IBOutlet weak var labelSendPrice: UILabel!
    
    @IBOutlet weak var labelTitleStatusPengiriman: UILabel!
    @IBOutlet weak var viewStatusPengirimanBg: UIView!
    @IBOutlet weak var labelStatusMessage: UILabel!
    @IBOutlet weak var imageStatusPengirimanArrow: UIImageView!
    @IBOutlet weak var labelDateAndTime: UILabel!
    
    @IBOutlet weak var viewMetodePembayaranBg: UIView!
    @IBOutlet weak var labelTitleMetodePembayaran: UILabel!
    @IBOutlet weak var imagePaymentLogo: UIImageView!
    @IBOutlet weak var labelAccountNumber: UILabel!
    
    
    @IBOutlet weak var labelTitleSubtotal: UILabel!
    @IBOutlet weak var labelTitleBiayaKirim: UILabel!
    @IBOutlet weak var labelTitleTotal: UILabel!
    
    
    @IBOutlet weak var labelSubtotal: UILabel!
    @IBOutlet weak var labelBiayaKirim: UILabel!
    @IBOutlet weak var labelTotal: UILabel!
    
    @IBOutlet weak var buttonMain: UIButton!
    @IBOutlet weak var buttonSecond: UIButton!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var viewTotalBg: UIView!
    var handler: (() -> Void)?
    var secondaryHandler: (() -> Void)?
    var handlerButtonLihat: (() -> Void)?
    var handlerShipmentTap: (() -> Void)?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func initView(){
        labelTitleInvoice.font = .Roboto(.bold, size: 12)
        labelTitleInvoice.textColor = .black
        labelTitleInvoice.textAlignment = .left
        labelTitleInvoice.numberOfLines = 1
        
        labelInvoice.font = .Roboto(.regular, size: 12)
        labelInvoice.textColor = .grey
        labelInvoice.textAlignment = .left
        labelInvoice.numberOfLines = 1
        
        labelTitlePesanan.font = .Roboto(.bold, size: 12)
        labelTitlePesanan.textColor = .black
        labelTitlePesanan.textAlignment = .left
        labelTitlePesanan.numberOfLines = 1
        
        buttonLihat.setTitleColor(UIColor.primary, for: .normal)
        
        imageProduct.layer.cornerRadius = 8
        imageProduct.clipsToBounds = true
        imageProduct.contentMode = .scaleToFill
        
        labelItemName.font = .Roboto(.bold, size: 12)
        labelItemName.textColor = .black
        labelItemName.textAlignment = .left
        labelItemName.numberOfLines = 0
        
        labelItemPrice.font = .Roboto(.regular, size: 12)
        labelItemPrice.textColor = .grey
        labelItemPrice.textAlignment = .left
        labelItemPrice.numberOfLines = 1
        
        labelItemQuantity.font = .Roboto(.regular, size: 12)
        labelItemQuantity.textColor = .grey
        labelItemQuantity.textAlignment = .left
        labelItemQuantity.numberOfLines = 1
        
        labelTitleNotes.font = .Roboto(.bold, size: 12)
        labelTitleNotes.textColor = .black
        labelTitleNotes.textAlignment = .left
        labelTitleNotes.numberOfLines = 1
        
        labelNotes.font = .Roboto(.regular, size: 12)
        labelNotes.textColor = .grey
        labelNotes.textAlignment = .left
        labelNotes.numberOfLines = 0
        
        labelTitleSendTo.font = .Roboto(.bold, size: 12)
        labelTitleSendTo.textColor = .black
        labelTitleSendTo.textAlignment = .left
        labelTitleSendTo.numberOfLines = 1
        
        labelSendAddress.font = .Roboto(.regular, size: 12)
        labelSendAddress.textColor = .grey
        labelSendAddress.textAlignment = .left
        labelSendAddress.numberOfLines = 0
        
        labelTitleDurasiPengiriman.font = .Roboto(.bold, size: 12)
        labelTitleDurasiPengiriman.textColor = .black
        labelTitleDurasiPengiriman.textAlignment = .left
        labelTitleDurasiPengiriman.numberOfLines = 1
        
        viewDurationBg.layer.backgroundColor = UIColor.whiteSnow.cgColor
        viewDurationBg.layer.cornerRadius = 8
        
        labelExpeditionName.font = .Roboto(.bold, size: 12)
        labelExpeditionName.textColor = .black
        labelExpeditionName.textAlignment = .left
        labelExpeditionName.numberOfLines = 1
        
        labelSendDuration.font = .Roboto(.extraBold, size: 10)
        labelSendDuration.textColor = .black
        labelSendDuration.textAlignment = .left
        labelSendDuration.numberOfLines = 1
        
        labelSendPrice.font = .Roboto(.regular, size: 12)
        labelSendPrice.textColor = .grey
        labelSendPrice.textAlignment = .left
        labelSendPrice.numberOfLines = 1
        
        labelTitleStatusPengiriman.font = .Roboto(.bold, size: 12)
        labelTitleStatusPengiriman.textColor = .black
        labelTitleStatusPengiriman.textAlignment = .left
        labelTitleStatusPengiriman.numberOfLines = 1
        
        viewStatusPengirimanBg.layer.backgroundColor = UIColor.whiteSnow.cgColor
        viewStatusPengirimanBg.layer.cornerRadius = 8
        
        labelStatusMessage.font = .Roboto(.regular, size: 12)
        labelStatusMessage.textColor = .secondary
        labelStatusMessage.textAlignment = .left
        labelStatusMessage.numberOfLines = 0
        
        imageStatusPengirimanArrow.image = UIImage(named: String.get(.iconNavigateNext))
        
        labelDateAndTime.font = .Roboto(.regular, size: 12)
        labelDateAndTime.textColor = .grey
        labelDateAndTime.textAlignment = .left
        labelDateAndTime.numberOfLines = 1
        
        labelTitleMetodePembayaran.font = .Roboto(.bold, size: 12)
        labelTitleMetodePembayaran.textColor = .black
        labelTitleMetodePembayaran.textAlignment = .left
        labelTitleMetodePembayaran.numberOfLines = 1
        
        labelAccountNumber.font = .Roboto(.regular, size: 12)
        labelAccountNumber.textColor = .grey
        labelAccountNumber.textAlignment = .right
        labelAccountNumber.numberOfLines = 1
        
        labelTitleSubtotal.font = .Roboto(.regular, size: 12)
        labelTitleSubtotal.textColor = .black
        labelTitleSubtotal.textAlignment = .left
        labelTitleSubtotal.numberOfLines = 1
        
        labelTitleBiayaKirim.font = .Roboto(.regular, size: 12)
        labelTitleBiayaKirim.textColor = .black
        labelTitleBiayaKirim.textAlignment = .left
        labelTitleBiayaKirim.numberOfLines = 1
        
        labelTitleTotal.font = .Roboto(.bold, size: 12)
        labelTitleTotal.textColor = .black
        labelTitleTotal.textAlignment = .left
        labelTitleTotal.numberOfLines = 1
        
        labelSubtotal.font = .Roboto(.regular, size: 12)
        labelSubtotal.textColor = .black
        labelSubtotal.textAlignment = .left
        labelSubtotal.numberOfLines = 1
        
        labelBiayaKirim.font = .Roboto(.regular, size: 12)
        labelBiayaKirim.textColor = .black
        labelBiayaKirim.textAlignment = .left
        labelBiayaKirim.numberOfLines = 1
        
        labelTotal.font = .Roboto(.bold, size: 12)
        labelTotal.textColor = .black
        labelTotal.textAlignment = .left
        labelTotal.numberOfLines = 1
        
        viewMetodePembayaranBg.layer.backgroundColor = UIColor.whiteSnow.cgColor
        viewMetodePembayaranBg.layer.cornerRadius = 8
        
        viewTotalBg.layer.backgroundColor = UIColor.whiteSnow.cgColor
        viewTotalBg.layer.cornerRadius = 8
        
        buttonMain.titleLabel?.font = .Roboto(.bold, size: 14)
        buttonMain.backgroundColor = .primary
        buttonMain.setTitleColor(.white, for: .normal)
        buttonMain.layer.cornerRadius = 8
        buttonMain.isHidden = true
        buttonMain.addTarget(self, action: #selector(buttonHandler), for: .touchUpInside)
        
        buttonSecond.titleLabel?.font = .Roboto(.bold, size: 14)
        buttonSecond.backgroundColor = .primaryLowTint
        buttonSecond.setTitleColor(.primary, for: .normal)
        buttonSecond.layer.cornerRadius = 8
        buttonSecond.isHidden = true
        buttonSecond.addTarget(self, action: #selector(buttonSecondaryHandler), for: .touchUpInside)
        
        buttonLihat.addTarget(self, action: #selector(buttonLihatHandler), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(shipmentViewTapHandler))
        viewStatusPengirimanBg.isUserInteractionEnabled = true
        viewStatusPengirimanBg.addGestureRecognizer(tap)
    }
    
    static func loadViewFromNib() -> DetailTransactionPurchaseView {
        let bundle = Bundle(for: self)
        let nib = UINib(nibName: "DetailTransactionPurchaseView", bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! DetailTransactionPurchaseView
    }
    
    
    func setupView(product: TransactionProduct) {
        labelInvoice.text = product.noInvoice
        imageProduct.loadImage(at: product.orderDetail?.urlProductPhoto ?? "")
        labelItemName.text = product.orderDetail?.productName
        
        var productType = product.orderDetail?.productType ?? "ORIGINAL"
        if productType.isEmpty {
            productType = "ORIGINAL"
        }
        let price = ( productType == "ORIGINAL" ? product.orderDetail?.productPrice : ((product.orderDetail?.modal ?? 0) + (product.orderDetail?.commission ?? 0)))
        labelItemPrice.text = price?.toMoney()
        
//        labelItemPrice.text = product.orderDetail?.productPrice?.toMoney()
        
        labelItemQuantity.text = "\(product.orderDetail?.quantity ?? 0)x"
        labelNotes.text = product.orderShipment?.notes?.isEmpty == true ? "-" : product.orderShipment?.notes
        let address = "\(product.orderShipment?.destinationLabel ?? ""), \(product.orderShipment?.destinationDetail ?? ""), \(product.orderShipment?.destinationSubDistrict ?? ""), \(product.orderShipment?.destinationCity ?? ""), \(product.orderShipment?.destinationProvince ?? ""), \(product.orderShipment?.destinationPostalCode ?? "")"
        labelSendAddress.text = address
        let courier = product.orderShipment?.courier ?? ""
        let nameService = product.orderShipment?.service ?? ""
        let duration = "\(product.orderShipment?.duration ?? "") hari kerja"
        let cost = product.orderShipment?.cost?.toMoney()
        labelExpeditionName.text = "\(courier) \(nameService)"
        labelSendDuration.text = duration
        labelSendPrice.text = cost
        
        if let vaNumber = product.payment?.paymentAccount?.number {
            labelAccountNumber.text = vaNumber
            switch BankEnum(rawValue: (product.payment?.bank)!) {
            case .BCA:
                imagePaymentLogo.image = UIImage(named: String.get(.iconbca))
            case .PERMATA:
                imagePaymentLogo.image = UIImage(named: String.get(.iconPermataBank))
            case .BNI:
                imagePaymentLogo.image = UIImage(named: String.get(.iconBNIBank))
            case .MANDIRI:
                imagePaymentLogo.image = UIImage(named: String.get(.iconMandiriBank))
            case .BRI:
                imagePaymentLogo.image = UIImage(named: String.get(.iconBRIBank))
            default:
                imagePaymentLogo.image = UIImage(named: String.get(.iconBankLain))
            }
        } else {
            viewMetodePembayaranBg.isHidden = true
            labelTitleMetodePembayaran.isHidden = true
            viewTotalBg.anchor(top: viewStatusPengirimanBg.bottomAnchor, paddingTop: 16)
            labelTitleMetodePembayaran.heightAnchor.constraint(equalToConstant: 0).isActive = true
            viewMetodePembayaranBg.heightAnchor.constraint(equalToConstant: 0).isActive = true
        }
        
        labelSubtotal.text = "\(product.orderDetail?.quantity ?? 0) x \(price?.toMoney() ?? "0")"
        labelBiayaKirim.text = cost
        if let quantity = product.orderDetail?.quantity, let price = price,  let shipmentCost = product.orderShipment?.cost {
            let total = (Double(quantity) * price) + Double(shipmentCost)
            
            labelTotal.text = "\(total.toMoney())"
        }
        
        
        if product.isOrderComplaint ?? false {
            configureButton(firstText: "Sudah mengajukan komplain", secondText: "")
            buttonMain.backgroundColor = .whiteSnow
            buttonMain.setTitleColor(.placeholder, for: .normal)
            buttonMain.isUserInteractionEnabled = false
        }
        hideLoading()
    }
    
    func showLoading(){
        loadingIndicator.startAnimating()
    }
    
    func hideLoading(){
        loadingIndicator.stopAnimating()
    }
    
    func setButton(itemTransaction: OrderCellViewModel) {
        switch (itemTransaction.orderStatus, itemTransaction.paymentStatus, itemTransaction.shipmentStatus) {
        case ("NEW", "WAIT", ""):
            configureButton(firstText: "Bayar Sekarang", secondText: "Lihat Produk")
            return
        case ("NEW", "PAID", ""):
            configureButton(firstText: "Cek Status Pesanan", secondText: "Lihat Produk")
        case ("NEW", "FAILED", ""):
            configureButton(firstText: "Beli Lagi", secondText: "Beli Lagi")
        case ("PROCESS", "PAID", "PACKAGING"):
            configureButton(firstText: "Cek Status Pesanan", secondText: "Lihat Produk")
        case ("PROCESS", "PAID", "SHIPPING"):
            configureButton(firstText: "Cek Status Pesanan", secondText: "Lihat Produk")
        case ("PROCESS", "PAID", "DELIVERED"):
            buttonSecond.backgroundColor = .whiteSnow
            buttonSecond.setTitleColor(.grey, for: .normal)
            configureButton(firstText: "Konfirmasi Pesanan", secondText: "Ajukan Komplain")
        case ("COMPLETE", "SETTLED", "DELIVERED"):
            configureButton(firstText: "", secondText: "")
        case ("CANCELLED", "RETURN", ""):
            configureButton(firstText: "Cek Pengembalian Dana", secondText: "Beli Lagi")
        default:
            configureButton(firstText: "", secondText: "")
        }
        buttonLihat.isHidden = false
    }
    
    func setButton(orderStatus: String, paymentStatus:String, shipmentStatus: String, reviewStatus: String) {
        switch (orderStatus, paymentStatus, shipmentStatus, reviewStatus) {
        case ("NEW", "WAIT", "", "WAIT"):
            configureButton(firstText: "Bayar Sekarang", secondText: "Lihat Produk")
            return
        case ("NEW", "PAID", "", "WAIT"):
            configureButton(firstText: "Cek Status Pesanan", secondText: "Lihat Produk")
        case ("NEW", "FAILED", "", "WAIT"):
            configureButton(firstText: "Beli Lagi", secondText: "Beli Lagi")
        case ("PROCESS", "PAID", "PACKAGING", "WAIT"):
            configureButton(firstText: "Cek Status Pesanan", secondText: "Lihat Produk")
        case ("PROCESS", "PAID", "SHIPPING", "WAIT"):
            configureButton(firstText: "Cek Status Pesanan", secondText: "Lihat Produk")
        case ("PROCESS", "PAID", "DELIVERED", "WAIT"):
            buttonSecond.backgroundColor = .whiteSnow
            buttonSecond.setTitleColor(.grey, for: .normal)
            configureButton(firstText: "Konfirmasi Pesanan", secondText: "Ajukan Komplain")
        case ("COMPLETE", "SETTLED", "DELIVERED", "WAIT"):
            configureButton(firstText: .get(.addReview), secondText: "")
        case ("COMPLETE", "SETTLED", "DELIVERED", "COMPLETE"):
            configureButton(firstText: "", secondText: "")
        case ("CANCELLED", "RETURN", "", "WAIT"):
            configureButton(firstText: "Cek Pengembalian Dana", secondText: "Beli Lagi")
        default:
            configureButton(firstText: "", secondText: "")
        }
        buttonLihat.isHidden = false
    }
    
    func configureButton(firstText: String, secondText: String){
        buttonMain.setTitle(firstText, for: .normal)
        buttonSecond.setTitle(secondText, for: .normal)
        buttonMain.isHidden = firstText == "" ? true : false
        buttonSecond.isHidden = secondText == "" ? true : false
    }
    
    func setupShipmentStatus(date: Int, status: String) {
        let dateFromMillis = Date(timeIntervalSince1970: TimeInterval(date) / 1000)
        let df = DateFormatter()
        df.dateFormat = "dd-MM-yyyy HH:mm"
    
        labelStatusMessage.text = status
        labelDateAndTime.text = df.string(from: dateFromMillis)
    }
    
    @objc
    func buttonHandler(){
        self.handler?()
    }
    
    @objc
    func buttonSecondaryHandler(){
        self.secondaryHandler?()
    }
    
    @objc
    func buttonLihatHandler(){
        self.handlerButtonLihat?()
    }
    
    @objc
    func shipmentViewTapHandler(){
        self.handlerShipmentTap?()
    }
}

enum BankEnum : String {
    case BCA = "bca"
    case OVO = "ovo"
    case MANDIRI = "mandiri"
    case PERMATA = "permata"
    case DANA = "dana"
    case BNI = "bni"
    case BRI = "bri"
    case GOPAY = "gopay"
}
