//
//  DonationCartView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 01/02/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import UIKit
import KipasKipasShared

class DonationCartView: UIView {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Keranjang Donasi Saya"
        label.font = .airbnb(.bold, size: 14)
        label.textColor = .black
        return label
    }()
    
    lazy var closeView: UIView = {
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.image = .iconCommentClose
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(icon)
        icon.centerInSuperview()
        
        return view
    }()
    
    lazy var headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews([titleLabel, closeView])
        titleLabel.centerInSuperview()
        closeView.anchor(top: view.topAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, width: 32, height: 32)
        
        return view
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    lazy var selectCheckbox: KKCheckbox = {
        let view = KKCheckbox()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUsingSFSymbols = true
        view.isThreeState = true
        view.tintColor = .secondary
        
        return view
    }()
    
    lazy var selectView: UIStackView = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Pilih Semua"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .grey
        label.textAlignment = .left
        
        let view = UIStackView(arrangedSubviews: [selectCheckbox, label])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .fillProportionally
        view.spacing = 3
        selectCheckbox.anchor(left: view.leftAnchor, width: 14, height: 14)
        
        return view
    }()
    
    lazy var totalLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Rp 0"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .primary
        label.textAlignment = .left
        return label
    }()
    
    lazy var totalView: UIStackView = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Total : "
        title.textColor = .grey
        title.font = .systemFont(ofSize: 12, weight: .medium)
        
        let view = UIStackView(arrangedSubviews: [title, totalLabel])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        title.anchor(width: title.intrinsicContentSize.width)
        return view
    }()
    
    lazy var summaryView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [selectView, totalView])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 8
        return view
    }()
    
    lazy var donateButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.isUserInteractionEnabled = true
        button.setTitle("Donasikan", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setCornerRadius = 6
        button.titleLabel?.font = .roboto(.bold, size: 14)
        return button
    }()
    
    lazy var footerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.addShadow(with: UIColor(hexString: "#000000", alpha: 0.1))
        view.addSubviews([summaryView, donateButton])
//        summaryView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingTop: 12, paddingLeft: 16, paddingBottom: 12)
//        donateButton.anchor(top: view.topAnchor, left: summaryView.rightAnchor, right: view.rightAnchor, paddingTop: 12, paddingLeft: 32, paddingBottom: 12, paddingRight: 16, width: 108, height: 34)

        summaryView.anchor(top: view.topAnchor, left: view.leftAnchor,
                           paddingTop: 8, paddingLeft: 16,
                           paddingBottom: 6)
        
        donateButton.anchor(top: view.topAnchor, left: summaryView.rightAnchor, right: view.rightAnchor, paddingTop: 8, paddingLeft: 32, paddingBottom: 8, paddingRight: 16, width: 108, height: 34)

        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        donateButtonEnable(false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DonationCartView {
    func donateButtonEnable(_ enable: Bool) {
        if enable {
            donateButton.isEnabled = true
            donateButton.setBackgroundColor(.primary, forState: .normal)
        } else {
            donateButton.isEnabled = false
            donateButton.setBackgroundColor(.primaryDisabled, forState: .normal)
        }
    }
    
    func updateCheckboxState(with status: DonationCartCheckStatus) {
        switch status {
        case .none:
            selectCheckbox.setState(.off)
            selectCheckbox.tintColor = .grey
        case .partial:
            selectCheckbox.setState(.clear)
            selectCheckbox.tintColor = .grey
        case .all:
            selectCheckbox.setState(.on)
            selectCheckbox.tintColor = .secondary
        }
    }
    
    func updateTotal(_ total: Double) {
        let formatter = NumberFormatter()
        formatter.locale = .init(identifier: "id_ID")
        formatter.numberStyle = .currency
        totalLabel.text = formatter.string(from: total as NSNumber)
    }
}
