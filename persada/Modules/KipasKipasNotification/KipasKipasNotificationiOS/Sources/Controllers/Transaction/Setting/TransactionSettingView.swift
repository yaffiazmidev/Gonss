//
//  TransactionSettingView.swift
//  KipasKipasNotificationiOS
//
//  Created by Rahmat Trinanda Pramudya Amar on 27/03/24.
//

import UIKit
import KipasKipasShared

protocol TransactionSettingViewDelegate: AnyObject {
    func didTapClose()
    func didSwitch(for item: TransactionViewSwitch, isOn: Bool)
}

enum TransactionViewSwitch {
    case activity
    case review
    case promotion
}

class TransactionSettingView: UIView {
    
    weak var delegate: TransactionSettingViewDelegate?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Pengaturan Notifikasi"
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    private lazy var closeView: UIView = {
        let image = UIImageView(image: .iconCloseWhite?.withTintColor(.black))
        image.translatesAutoresizingMaskIntoConstraints = false
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(image)
        
        image.anchors.size.equal(.init(width: 12, height: 12))
        image.anchors.centerX.equal(view.anchors.centerX)
        image.anchors.centerY.equal(view.anchors.centerY)
        
        return view
    }()
    
    private lazy var headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews([titleLabel, closeView])
        
        titleLabel.anchors.centerX.equal(view.anchors.centerX)
        titleLabel.anchors.centerY.equal(view.anchors.centerY)
        closeView.anchors.top.equal(view.anchors.top)
        closeView.anchors.bottom.equal(view.anchors.bottom)
        closeView.anchors.trailing.equal(view.anchors.trailing)
        closeView.anchors.size.equal(.init(width: 24, height: 24))
        
        return view
    }()
    
    private lazy var dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .whiteSmoke
        return view
    }()
    
    private lazy var activityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Aktifitas dan pemberitahuan"
        label.textColor = .grey
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 1
        label.textAlignment = .left
        
        return label
    }()
    
    private lazy var activitySwitch: UISwitch = {
        let button = UISwitch(frame: .init(x: 0, y: 0, width: 44, height: 26))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.onTintColor = .init(hexString: "#0BE09B")
        button.isOn = true
        
        return button
    }()
    
    private lazy var activityView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews([activityLabel, activitySwitch])
        
        activitySwitch.anchors.top.equal(view.anchors.top)
        activitySwitch.anchors.trailing.equal(view.anchors.trailing)
        activitySwitch.anchors.bottom.equal(view.anchors.bottom)
        
        activityLabel.anchors.centerY.equal(view.anchors.centerY)
        activityLabel.anchors.leading.equal(view.anchors.leading)
        activityLabel.anchors.trailing.equal(activitySwitch.anchors.leading, constant: -12)
        
        return view
    }()
    
    private lazy var reviewLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Review produk dan survey"
        label.textColor = .grey
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 1
        label.textAlignment = .left
        
        return label
    }()
    
    private lazy var reviewSwitch: UISwitch = {
        let button = UISwitch(frame: .init(x: 0, y: 0, width: 44, height: 26))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.onTintColor = .init(hexString: "#0BE09B")
        button.isOn = true
        
        return button
    }()
    
    private lazy var reviewView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews([reviewLabel, reviewSwitch])
        
        reviewSwitch.anchors.top.equal(view.anchors.top)
        reviewSwitch.anchors.trailing.equal(view.anchors.trailing)
        reviewSwitch.anchors.bottom.equal(view.anchors.bottom)
        
        reviewLabel.anchors.centerY.equal(view.anchors.centerY)
        reviewLabel.anchors.leading.equal(view.anchors.leading)
        reviewLabel.anchors.trailing.equal(reviewSwitch.anchors.leading, constant: -12)
        
        return view
    }()
    
    private lazy var promotionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Promosi"
        label.textColor = .grey
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 1
        label.textAlignment = .left
        
        return label
    }()
    
    private lazy var promotionSwitch: UISwitch = {
        let button = UISwitch(frame: .init(x: 0, y: 0, width: 44, height: 26))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.onTintColor = .init(hexString: "#0BE09B")
        button.isOn = true
        
        return button
    }()
    
    private lazy var promotionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews([promotionLabel, promotionSwitch])
        
        promotionSwitch.anchors.top.equal(view.anchors.top)
        promotionSwitch.anchors.trailing.equal(view.anchors.trailing)
        promotionSwitch.anchors.bottom.equal(view.anchors.bottom)
        
        promotionLabel.anchors.centerY.equal(view.anchors.centerY)
        promotionLabel.anchors.leading.equal(view.anchors.leading)
        promotionLabel.anchors.trailing.equal(promotionSwitch.anchors.leading, constant: -12)
        
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews([activityView, reviewView, promotionView])
        
        activityView.anchors.leading.equal(view.anchors.leading)
        activityView.anchors.trailing.equal(view.anchors.trailing)
        activityView.anchors.top.equal(view.anchors.top)
        
        reviewView.anchors.leading.equal(view.anchors.leading)
        reviewView.anchors.trailing.equal(view.anchors.trailing)
        reviewView.anchors.top.equal(activityView.anchors.bottom, constant: 24)
        
        promotionView.anchors.leading.equal(view.anchors.leading)
        promotionView.anchors.trailing.equal(view.anchors.trailing)
        promotionView.anchors.top.equal(reviewView.anchors.bottom, constant: 24)
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configUI()
    }
}

// MARK: - Internal Helper
extension TransactionSettingView {
    func `switch`(for item: TransactionViewSwitch, isOn: Bool, animated: Bool) {
        switch item {
        case .activity:
            activitySwitch.setOn(isOn, animated: animated)
        case .review:
            reviewSwitch.setOn(isOn, animated: animated)
        case .promotion:
            promotionSwitch.setOn(isOn, animated: animated)
        }
    }
}

// MARK: - Private Helper
private extension TransactionSettingView {
    func configUI() {
        addSubviews([headerView, dividerView, containerView])
        
        headerView.anchors.leading.equal(anchors.leading, constant: 16)
        headerView.anchors.trailing.equal(anchors.trailing, constant: -16)
        headerView.anchors.top.equal(anchors.top, constant: 12)
        
        dividerView.anchors.leading.equal(anchors.leading)
        dividerView.anchors.trailing.equal(anchors.trailing)
        dividerView.anchors.top.equal(headerView.anchors.bottom, constant: 12)
        dividerView.anchors.height.equal(1)
        
        containerView.anchors.leading.equal(anchors.leading, constant: 16)
        containerView.anchors.trailing.equal(anchors.trailing, constant: -16)
        containerView.anchors.top.equal(dividerView.anchors.bottom, constant: 16)
        containerView.anchors.bottom.equal(anchors.bottom, constant: -16)
        
        setupOnTap()
    }
    
    func setupOnTap() {
        closeView.onTap { [weak self] in
            self?.delegate?.didTapClose()
        }
        
        activitySwitch.addTarget(self, action: #selector(didSwitchActivity), for: .valueChanged)
        reviewSwitch.addTarget(self, action: #selector(didSwitchReview), for: .valueChanged)
        promotionSwitch.addTarget(self, action: #selector(didSwitchPromotion), for: .valueChanged)
    }
    
    @objc func didSwitchActivity(sender: UISwitch) {
        delegate?.didSwitch(for: .activity, isOn: sender.isOn)
    }
    
    @objc func didSwitchReview(sender: UISwitch) {
        delegate?.didSwitch(for: .review, isOn: sender.isOn)
    }
    
    @objc func didSwitchPromotion(sender: UISwitch) {
        delegate?.didSwitch(for: .promotion, isOn: sender.isOn)
    }
}
