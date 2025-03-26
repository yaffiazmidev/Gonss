//
//  TransactionDetailDonationView.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 12/05/24.
//

import UIKit
import KipasKipasNotification
import KipasKipasDonationTransactionDetail

protocol ITransactionDetailDonationView: AnyObject {
    func didClickBackButton()
    func didClickPayNowButton(url: String)
    func didClickInitiatorProfile(id: String)
    func didCopy(value: String)
    func didClickGroupOrder(item: DonationTransactionDetailGroupItem?)
}

class TransactionDetailDonationView: UIView {

    @IBOutlet weak var initiatorContainerStack: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var backButtonContainerStackView: UIStackView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var initiatorProfileImageView: UIImageView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var donationTitleLabel: UILabel!
    @IBOutlet weak var initiatorNameLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var groupOrderContainerStack: UIStackView!
    @IBOutlet weak var groupOrderCountLabel: UILabel!
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var paymentMethodLabel: UILabel!
    @IBOutlet weak var paymentDetailContainerStack: UIStackView!
    @IBOutlet weak var transactionNumberContainerStack: UIStackView!
    @IBOutlet weak var transactionNumberLabel: UILabel!
    @IBOutlet weak var payNowLabel: UILabel!
    @IBOutlet weak var confirmationContainerStack: UIStackView!
    @IBOutlet weak var transactionNumberCopyIconImageView: UIImageView!
    
    weak var delegate: ITransactionDetailDonationView?
    
    var item: NotificationTransactionDetailItem? {
        didSet { setupView(with: item) }
    }
    
    var orderItem: DonationTransactionDetailOrderItem? {
        didSet { setupDonationOrder(with: orderItem) }
    }
    
    var groupOrderItem: DonationTransactionDetailGroupItem?

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
        configureUI()
        handleOnTapView()
    }
    
    func handleOnTapView() {
        let onTapBackButtonGesture = UITapGestureRecognizer(target: self, action: #selector(handleOnTapBackButton))
        backButtonContainerStackView.isUserInteractionEnabled = true
        backButtonContainerStackView.addGestureRecognizer(onTapBackButtonGesture)
        
        let onTapPayNowButtonGesture = UITapGestureRecognizer(target: self, action: #selector(handleOnTapPayNowButton))
        payNowLabel.isUserInteractionEnabled = true
        payNowLabel.addGestureRecognizer(onTapPayNowButtonGesture)
        
        let onTapInitiatorProfileGesture = UITapGestureRecognizer(target: self, action: #selector(handleOnTapInitiatorProfile))
        initiatorContainerStack.isUserInteractionEnabled = true
        initiatorContainerStack.addGestureRecognizer(onTapInitiatorProfileGesture)
        
        let onTapTransactionNumberCopyIconProfileGesture = UITapGestureRecognizer(target: self, action: #selector(handleOnTapTransactionNumberCopy))
        transactionNumberContainerStack.isUserInteractionEnabled = true
        transactionNumberContainerStack.addGestureRecognizer(onTapTransactionNumberCopyIconProfileGesture)
        
        let onTapGroupOrderContainerStackGesture = UITapGestureRecognizer(target: self, action: #selector(handleOnTapGroupOrder))
        groupOrderContainerStack.isUserInteractionEnabled = true
        groupOrderContainerStack.addGestureRecognizer(onTapGroupOrderContainerStackGesture)
    }
}

extension TransactionDetailDonationView {
    @objc func handleOnTapGroupOrder() {
        delegate?.didClickGroupOrder(item: groupOrderItem)
    }
    
    @objc func handleOnTapTransactionNumberCopy() {
        delegate?.didCopy(value: orderItem?.payment.paymentAccount.number ?? "")
    }
    
    @objc func handleOnTapInitiatorProfile() {
        delegate?.didClickInitiatorProfile(id: orderItem?.orderDetail.initiatorId ?? "")
    }
    
    @objc func handleOnTapPayNowButton() {
        delegate?.didClickPayNowButton(url: orderItem?.orderDetail.urlPaymentPage ?? "")
    }
    
    @objc func handleOnTapBackButton() {
        delegate?.didClickBackButton()
    }
}

extension TransactionDetailDonationView {
    
    func configureUI() {
        overrideUserInterfaceStyle = .light
        
        initiatorProfileImageView.image = .defaultProfileImageSmall
        thumbnailImageView.image = .emptyProfilePhoto
        payNowLabel.layer.cornerRadius = 2
        thumbnailImageView.layer.cornerRadius = 2
        thumbnailImageView.layer.borderWidth = 1
        thumbnailImageView.layer.borderColor = UIColor(hexString: "#BBBBBB").cgColor
        groupOrderContainerStack.isHidden = true
        paymentDetailContainerStack.isHidden = true
        subtitleLabel.isHidden = false
        confirmationContainerStack.isHidden = true
    }
    
    private func setupView(with item: NotificationTransactionDetailItem?) {
        guard let item = item else { return }
        
        
        switch (item.status, item.paymentStatus) {
        case ("NEW", "WAIT"):
            titleLabel.text = "Menunggu Pembayaran"
            subtitleLabel.text = "Segera lakukan pembayaran sebelum transaksi kadaluarsa."
            confirmationContainerStack.isHidden = false
        case ("COMPLETE", "PAID"):
            titleLabel.text = "Donasi Terkirim"
            subtitleLabel.text = "Terimakasih, donasi kamu sangat berguna bagi mereka yang membutuhkan."
            
        case ("CANCELLED", "EXPIRED"):
            titleLabel.text = "Pembayaran expired"
            subtitleLabel.isHidden = true
            
        default:
            titleLabel.text = "Donasi"
            subtitleLabel.isHidden = true
        }
    }
    
    private func setupDonationOrder(with item: DonationTransactionDetailOrderItem?) {
        guard let item = item else { return }
        
        let paymentAccount = item.payment.paymentAccount
        paymentDetailContainerStack.isHidden = paymentAccount.name.isEmpty && paymentAccount.number.isEmpty
        transactionNumberContainerStack.isHidden = paymentAccount.number.isEmpty
        paymentMethodLabel.text = paymentAccount.name.uppercased()
        transactionNumberLabel.text = paymentAccount.number
        
        donationTitleLabel.text = item.orderDetail.donationTitle
        amountLabel.text = item.amount.toCurrency()
        subtotalLabel.text = item.amount.toCurrency()
        totalLabel.text = item.amount.toCurrency()
        initiatorNameLabel.text = item.orderDetail.initiatorName
        initiatorProfileImageView.loadProfileImage(from: item.orderDetail.urlInitiatorPhoto, size: .w40)
        thumbnailImageView.loadImageWithOSS(from: item.orderDetail.urlDonationPhoto, size: .w240)
    }
}
