//
//  TransactionEmptyView.swift
//  KipasKipasNotificationiOS
//
//  Created by Rahmat Trinanda Pramudya Amar on 28/03/24.
//

import UIKit
import KipasKipasShared

class TransactionEmptyView: UIView {
    private lazy var imageView: UIImageView = {
        let view = UIImageView(image: .iconTransactionEmpty)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.text = "Transaksi Belum Tersedia"
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.numberOfLines = 0
        label.textAlignment = .center
        
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Belum ada transaksi yang dilakukan saat ini."
        label.textColor = .contentGrey
        label.font = .systemFont(ofSize: 13)
        label.numberOfLines = 0
        label.textAlignment = .center
        
        return label
    }()
    
    // MARK: Function
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configUI()
    }
}

// MARK: - Private Helper
private extension TransactionEmptyView {
    func configUI() {
        backgroundColor = .white
        
        addSubviews([imageView, titleLabel, descriptionLabel])
        
        imageView.anchors.top.equal(anchors.top)
        imageView.anchors.centerX.equal(anchors.centerX)
        
        titleLabel.anchors.top.equal(imageView.anchors.bottom, constant: 16)
        titleLabel.anchors.leading.equal(anchors.leading)
        titleLabel.anchors.trailing.equal(anchors.trailing)
        
        descriptionLabel.anchors.top.equal(titleLabel.anchors.bottom, constant: 16)
        descriptionLabel.anchors.leading.equal(anchors.leading)
        descriptionLabel.anchors.trailing.equal(anchors.trailing)
        descriptionLabel.anchors.bottom.equal(anchors.bottom)
    }
}
