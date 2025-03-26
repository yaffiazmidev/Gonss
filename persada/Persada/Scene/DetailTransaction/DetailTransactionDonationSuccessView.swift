//
//  DetailTransactionDonationSuccessView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 29/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import UIKit

class DetailTransactionDonationSuccessView: UIView {
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.backgroundColor = .white
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isScrollEnabled = true
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.bounces = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    lazy var loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.color = .primary
        return view
    }()
    
    lazy var paymentCodeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .placeholder
        label.font = UIFont(name: "AirbnbCerealApp-Medium", size: 14)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var paymentCodeView: UIView = {
        let label = UILabel()
        label.text = "Kode Pembayaran Donasi"
        label.textColor = .black
        label.font = UIFont(name: "AirbnbCerealApp-Medium", size: 14)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let view = UIView()
        view.addSubViews([label, paymentCodeLabel])
        label.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor)
        paymentCodeLabel.anchor(top: label.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var donationImageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var donationNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont(name: "AirbnbCerealApp-Medium", size: 14)
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var donationPriceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .placeholder
        label.font = UIFont(name: "AirbnbCerealApp-Medium", size: 14)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var donationView: UIView = {
        let label = UILabel()
        label.text = "Donasi"
        label.textColor = .black
        label.font = UIFont(name: "AirbnbCerealApp-Medium", size: 14)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let view = UIView()
        view.addSubViews([label, donationImageView, donationNameLabel, donationPriceLabel])
        label.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor)
        donationImageView.anchor(top: label.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, paddingTop: 6, width: 76, height: 76)
        donationNameLabel.anchor(top: label.bottomAnchor, left: donationImageView.rightAnchor, right: view.rightAnchor, paddingTop: 6, paddingLeft: 10)
        donationPriceLabel.anchor(top: donationNameLabel.bottomAnchor, left: donationImageView.rightAnchor, right: view.rightAnchor, paddingTop: 8, paddingLeft: 10)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var organizerImageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var organizerNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .Roboto(.medium, size: 14)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var organizerCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .whiteSnow
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let arrow = UIImageView(image: UIImage(named: .get(.iconRightArrow)))
        arrow.contentMode = .scaleAspectFill
        arrow.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubViews([organizerImageView, organizerNameLabel, arrow])
        organizerImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, width: 46, height: 46)
        arrow.anchor(right: view.rightAnchor, paddingRight: 10, width: 16, height: 24)
        arrow.centerYTo(view.centerYAnchor)
        organizerNameLabel.anchor(left: organizerImageView.rightAnchor, right: arrow.leftAnchor, paddingLeft: 10, paddingRight: 10)
        organizerNameLabel.centerYTo(view.centerYAnchor)
        
        return view
    }()
    
    lazy var organizerView: UIView = {
        let label = UILabel()
        label.text = "Penyelenggara"
        label.textColor = .black
        label.font = UIFont(name: "AirbnbCerealApp-Medium", size: 14)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        
        
        let view = UIView()
        view.addSubViews([label, organizerCardView])
        label.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor)
        organizerCardView.anchor(top: label.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 8)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var bankImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var bankView: UIView = {
        let label = UILabel()
        label.text = "Metode Pembayaran"
        label.textColor = .black
        label.font = UIFont(name: "AirbnbCerealApp-Medium", size: 14)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let container = UIView()
        container.backgroundColor = .whiteSnow
        container.layer.cornerRadius = 8
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(bankImageView)
        bankImageView.anchor(top: container.topAnchor, left: container.leftAnchor, bottom: container.bottomAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, width: 48, height: 32)
        
        let view = UIView()
        view.addSubViews([label, container])
        label.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor)
        container.anchor(top: label.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 8)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var paymentSubTotalLabel: UILabel = {
        let label = UILabel()
        label.textColor = .contentGrey
        label.font = .Roboto(.medium, size: 14)
        label.numberOfLines = 1
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var paymentAdminFeeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .contentGrey
        label.font = .Roboto(.medium, size: 14)
        label.numberOfLines = 1
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var paymentTotalLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .Roboto(.bold, size: 14)
        label.numberOfLines = 1
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var paymentDetailView: UIView = {
        let view = UIView()
        view.backgroundColor = .whiteSnow
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let subtotal = UILabel()
        subtotal.text = "Subtotal"
        subtotal.textColor = .contentGrey
        subtotal.font = .Roboto(.medium, size: 14)
        subtotal.numberOfLines = 1
        subtotal.translatesAutoresizingMaskIntoConstraints = false
        
        let adminFee = UILabel()
        adminFee.text = "Biaya Admin"
        adminFee.textColor = .contentGrey
        adminFee.font = .Roboto(.medium, size: 14)
        adminFee.numberOfLines = 1
        adminFee.translatesAutoresizingMaskIntoConstraints = false
        
        let total = UILabel()
        total.text = "Total"
        total.textColor = .black
        total.font = .Roboto(.bold, size: 14)
        total.numberOfLines = 1
        total.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubViews([subtotal, paymentSubTotalLabel, adminFee, paymentAdminFeeLabel, total, paymentTotalLabel])
        subtotal.anchor(top: view.topAnchor, left: view.leftAnchor, paddingTop: 10, paddingLeft: 10)
        paymentSubTotalLabel.anchor(top: view.topAnchor, left: subtotal.rightAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingRight: 10)
        adminFee.anchor(top: subtotal.bottomAnchor, left: view.leftAnchor, paddingTop: 4, paddingLeft: 10)
        paymentAdminFeeLabel.anchor(top: paymentSubTotalLabel.bottomAnchor, left: adminFee.rightAnchor, right: view.rightAnchor, paddingTop: 4, paddingLeft: 10, paddingRight: 10)
        total.anchor(top: adminFee.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, paddingTop: 16, paddingLeft: 10, paddingBottom: 10)
        paymentTotalLabel.anchor(top: paymentAdminFeeLabel.bottomAnchor, left: total.rightAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 10, paddingBottom: 10, paddingRight: 10)
        
        return view
    }()
    
    lazy var reorderButton: PrimaryButton = {
        let button = PrimaryButton(type: .system)
        button.setTitle("Kirim Donasi lagi", for: .normal)
        button.setup(color: .primary, textColor: .white, font: .Roboto(.bold, size: 14))
        return button
    }()
    
    lazy var backButton: PrimaryButton = {
        let button = PrimaryButton(type: .system)
        button.setTitle(.get(.back), for: .normal)
        button.setup(color: .whiteSnow, textColor: .contentGrey, font: .Roboto(.bold, size: 14))
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubViews([paymentCodeView, donationView, organizerView, bankView, paymentDetailView, reorderButton, backButton])
        paymentCodeView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor)
        donationView.anchor(top: paymentCodeView.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 20)
        organizerView.anchor(top: donationView.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 28)
        bankView.anchor(top: organizerView.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 28)
        paymentDetailView.anchor(top: bankView.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 16)
        reorderButton.anchor(top: paymentDetailView.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 50)
        backButton.anchor(top: reorderButton.bottomAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, paddingTop: 12)
        
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.centerXTo(centerXAnchor)
        scrollView.anchor(top: safeAreaLayoutGuide.topAnchor, left: safeAreaLayoutGuide.leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: safeAreaLayoutGuide.rightAnchor)
        contentView.centerXTo(scrollView.centerXAnchor)
        contentView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 20, paddingRight: 20)
        
        addSubview(loadingIndicator)
        loadingIndicator.centerYTo(centerYAnchor)
        loadingIndicator.centerXTo(centerXAnchor)
        loadingIndicator.anchor(width: 20, height: 20)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ data: DetailTransactionOrderItem?){
        scrollView.contentSize = CGSize(width: frame.width, height: organizerView.frame.maxY)
        scrollView.isHidden = data == nil
        
        guard let data = data else {
            loadingIndicator.startAnimating()
            return
        }
        
        loadingIndicator.stopAnimating()
        paymentCodeLabel.text = data.noInvoice
        donationImageView.loadImage(at: data.orderDetail.urlDonationPhoto ?? "")
        donationNameLabel.text = data.orderDetail.donationTitle
        donationPriceLabel.text = data.amount.toMoney()
        organizerNameLabel.text = data.orderDetail.initiatorName
        organizerImageView.loadImage(at: data.orderDetail.urlInitiatorPhoto ?? "")
        bankImageView.image = UIImage(named: data.payment.bank.icon)
        paymentSubTotalLabel.text = data.amount.toMoney()
        paymentAdminFeeLabel.text = 0.toMoney()
        paymentTotalLabel.text = data.amount.toMoney()
    }
}
