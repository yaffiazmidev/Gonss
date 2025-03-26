//
//  DetailTransactionDonationExpiredView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 29/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import UIKit

class DetailTransactionDonationExpiredView: UIView {
    lazy var loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.color = .primary
        return view
    }()
    
    lazy var expiredView: UIView = {
        let title = UILabel()
        title.text = "Waktu Habis"
        title.textColor = .contentGrey
        title.font = .Roboto(.medium, size: 14)
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false
        
        let time = UILabel()
        time.text = "00:00"
        time.textColor = .red
        time.font = .Roboto(.medium, size: 26)
        time.textAlignment = .center
        time.translatesAutoresizingMaskIntoConstraints = false
        
        let description = UILabel()
        description.text = "Waktu pembayaran sudah habis, silahkan ulangi transaksi untuk mendapatkan kode pembayaran yang baru."
        description.textColor = .placeholder
        description.font = .Roboto(.medium, size: 14)
        description.numberOfLines = 5
        description.textAlignment = .center
        description.translatesAutoresizingMaskIntoConstraints = false
        
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubViews([title, time, description])
        title.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor)
        time.anchor(top: title.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 14)
        description.anchor(top: time.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 24)
        
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
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubViews([expiredView, reorderButton, backButton])
        backButton.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        reorderButton.anchor(left: view.leftAnchor, bottom: backButton.topAnchor, right: view.rightAnchor, paddingBottom: 12)
        expiredView.anchor(left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 10, paddingRight: 10)
        expiredView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80).isActive = true
//        expiredView.centerYTo(view.centerYAnchor)
        
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubview(contentView)
        contentView.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 20, paddingRight: 20)
        
        addSubview(loadingIndicator)
        loadingIndicator.anchor(width: 20, height: 20)
        loadingIndicator.centerXTo(centerXAnchor)
        loadingIndicator.centerYTo(centerYAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ data: DetailTransactionOrderItem?){
        contentView.isHidden = data == nil
        
        guard let _ = data else {
            loadingIndicator.startAnimating()
            return
        }
        
        loadingIndicator.stopAnimating()
    }
}
