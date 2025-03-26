//
//  TransactionDetailOrderView.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 12/05/24.
//

import UIKit
import KipasKipasNotification
import KipasKipasDonationTransactionDetail

protocol ITransactionDetailOrderView: AnyObject {
    func didClickBackButton()
}

class TransactionDetailOrderView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var backButtonContainerStackView: UIStackView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var lastTrackingTitleLabel: UILabel!
    @IBOutlet weak var lastTrackingDescLabel: UILabel!
    
    @IBOutlet weak var customerPhoneNumberLabel: UILabel!
    @IBOutlet weak var customerUsernameLabel: UILabel!
    @IBOutlet weak var customerProfileImageView: UIImageView!
    @IBOutlet weak var shipmentAddressLabel: UILabel!
    @IBOutlet weak var shipmentNotesLabel: UILabel!
    
    @IBOutlet weak var sellerUsernameLabel: UILabel!
    @IBOutlet weak var sellerProfileImageView: UIImageView!
    @IBOutlet weak var productThumbnailImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productQuantityLabel: UILabel!
    
    weak var delegate: ITransactionDetailOrderView?
    
    var item: NotificationTransactionDetailItem? {
        didSet { setupDetailView(with: item) }
    }
    
    var orderItem: DonationTransactionDetailOrderItem? {
        didSet { setupOrder(with: orderItem) }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubViews()
        setupComponent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubViews()
    }
    
    private func initSubViews() {
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: Bundle(for: type(of: self)))
        nib.instantiate(withOwner: self, options: nil)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        addConstraints()
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: containerView.topAnchor),
            bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
    }
    
    func setupComponent() {
        overrideUserInterfaceStyle = .light
        handleOnTapView()
    }
    
    func handleOnTapView() {
        let onTapBackButtonGesture = UITapGestureRecognizer(target: self, action: #selector(handleOnTapBackButton))
        backButtonContainerStackView.isUserInteractionEnabled = true
        backButtonContainerStackView.addGestureRecognizer(onTapBackButtonGesture)
    }
}

extension TransactionDetailOrderView {
    @objc func handleOnTapBackButton() {
        delegate?.didClickBackButton()
    }
}

extension TransactionDetailOrderView {
    
    private func setupDetailView(with item: NotificationTransactionDetailItem?) {
        guard let item = item else { return }
        titleLabel.text = item.titleNavbar()
    }
    
    private func setupOrder(with item: DonationTransactionDetailOrderItem?) {
        guard let item = item else { return }
        
        
    }
}
