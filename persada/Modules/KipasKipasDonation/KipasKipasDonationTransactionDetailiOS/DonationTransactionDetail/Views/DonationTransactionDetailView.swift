import UIKit
import KipasKipasShared

public class DonationTransactionDetailView: UIView {
    
    private(set) lazy var containerView = UIView()
    private(set) lazy var containerStack = UIStackView()
    private(set) lazy var scrollView = UIScrollView()
    lazy var codePaymentView = DonationTransacationTitleView()
    lazy var donationView = DonationTransactionPriceView()
    lazy var fundraisingView = DonationTransacationTitleVerifiedView()
    lazy var receiverView = DonationTransacationTitleView()
    lazy var paymentMethodView = DonationTransacationBankView()
    lazy var totalView = DonationTransacationTotalView()
    private(set) lazy var buttonStack = UIStackView()
    lazy var donateAgainButton = UIButton()
    lazy var payNowButton = UIButton()
    
    var heightConstraintDonationView: NSLayoutConstraint?
    var heightDonation: CGFloat = 110 {
        didSet {
            heightConstraintDonationView?.constant = heightDonation
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        UIFont.loadCustomFonts
        backgroundColor = .white
        configureScrollView()
    }
    
    private func configureScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        scrollView.backgroundColor = .whiteSnow
        scrollView.anchors.top.equal(self.safeAreaLayoutGuide.anchors.top)
        scrollView.anchors.edges.pin(axis: .horizontal)
        scrollView.anchors.bottom.pin()
        scrollView.anchors.centerX.equal(self.anchors.centerX)
        
        configureContainerView()
        configureButtonStack()
    }
    
    private func configureContainerView() {
        scrollView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.anchors.centerX.equal(scrollView.anchors.centerX)
        containerView.anchors.top.equal(scrollView.anchors.top, constant: 8)
        containerView.anchors.leading.equal(scrollView.anchors.leading)
        containerView.anchors.bottom.equal(scrollView.anchors.bottom)
        containerView.anchors.trailing.equal(scrollView.anchors.trailing)
        
        configureContainerStack()
    }
    
    private func configureContainerStack() {
        containerView.addSubview(containerStack)
        containerStack.spacing = 8
        containerStack.axis = .vertical
        containerStack.alignment = .fill
        containerStack.distribution = .fill
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        containerStack.anchors.edges.pin()
        
        configureCodePaymentView()
        configurePriceView()
        configureFundraisingView()
        configureReceiverView()
        configurePaymentMethodView()
        configureTotalPaymentView()
    }
    
    private func configureCodePaymentView() {
        codePaymentView.translatesAutoresizingMaskIntoConstraints = false
        codePaymentView.backgroundColor = .white
        containerStack.addArrangedSubview(codePaymentView)
        codePaymentView.anchors.height.equal(40)
    }
   
    private func configurePriceView() {
        donationView.translatesAutoresizingMaskIntoConstraints = false
        donationView.backgroundColor = .white
        containerStack.addArrangedSubview(donationView)
        heightConstraintDonationView = donationView.heightAnchor.constraint(equalToConstant: heightDonation)
        heightConstraintDonationView?.isActive = true
    }
    
    private func configureFundraisingView() {
        fundraisingView.translatesAutoresizingMaskIntoConstraints = false
        fundraisingView.backgroundColor = .white
        containerStack.addArrangedSubview(fundraisingView)
        fundraisingView.anchors.height.equal(40)
    }
    
    private func configureReceiverView() {
        receiverView.translatesAutoresizingMaskIntoConstraints = false
        receiverView.backgroundColor = .white
        containerStack.addArrangedSubview(receiverView)
        receiverView.anchors.height.equal(40)
        receiverView.isHidden = true
    }
    
    private func configurePaymentMethodView() {
        containerStack.addArrangedSubview(paymentMethodView)
        paymentMethodView.translatesAutoresizingMaskIntoConstraints = false
        paymentMethodView.backgroundColor = .white
        paymentMethodView.anchors.height.equal(40)
    }
    
    private func configureTotalPaymentView() {
        containerStack.addArrangedSubview(totalView)
        totalView.translatesAutoresizingMaskIntoConstraints = false
        totalView.backgroundColor = .white
        totalView.anchors.height.equal(heightDonation)
    }
    
    private func configureButtonStack() {
        addSubview(buttonStack)
        
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .vertical
        buttonStack.alignment = .fill
        buttonStack.distribution = .fill
        buttonStack.anchors.bottom.equal(anchors.bottom, constant: -20)
        buttonStack.anchors.leading.equal(anchors.leading, constant: 20)
        buttonStack.anchors.trailing.equal(anchors.trailing, constant: -20)
        buttonStack.anchors.height.equal(44)
        
        configureDonateAgainButton()
        configurePayNowButton()
    }
    
    private func configureDonateAgainButton() {
        buttonStack.addArrangedSubview(donateAgainButton)
        donateAgainButton.translatesAutoresizingMaskIntoConstraints = false
        donateAgainButton.setTitle("Kirm Donasi Lagi")
        donateAgainButton.isHidden = true
        donateAgainButton.layer.cornerRadius = 4
        donateAgainButton.backgroundColor = .primary
        donateAgainButton.titleLabel?.font = .roboto(.bold, size: 14)
    }
    
    private func configurePayNowButton() {
        buttonStack.addArrangedSubview(payNowButton)
        payNowButton.translatesAutoresizingMaskIntoConstraints = false
        payNowButton.setTitle("Bayar Sekarang")
        payNowButton.layer.cornerRadius = 4
        payNowButton.isHidden = true
        payNowButton.titleLabel?.font = .roboto(.bold, size: 14)
        payNowButton.backgroundColor = .primary
    }
}
