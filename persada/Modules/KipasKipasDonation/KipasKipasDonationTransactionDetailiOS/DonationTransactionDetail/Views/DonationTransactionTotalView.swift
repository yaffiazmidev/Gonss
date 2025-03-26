import UIKit
import KipasKipasShared

public class DonationTransacationTotalView: UIView {
    
    private(set) lazy var containerView = UIView()
    private(set) lazy var containerStack = UIStackView()
    private(set) lazy var nominalDonationStack = UIStackView()
    private(set) lazy var feeAdminStack = UIStackView()
    private(set) lazy var totalPaymentStack = UIStackView()
    
    private(set) lazy var nominalDonationTitleLabel = UILabel()
    private(set) lazy var nominalDonationNameLabel = UILabel()
    
    private(set) lazy var feeAdminTitleLabel = UILabel()
    private(set) lazy var feeAdminNameLabel = UILabel()
    
    private(set) lazy var totalPaymentTitleLabel = UILabel()
    private(set) lazy var totalPaymentNameLabel = UILabel()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        UIFont.loadCustomFonts
        configureContainerView()
    }
    
    private func configureContainerView() {
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.anchors.edges.pin()
        
        configureContainerStack()
    }
    
    private func configureContainerStack() {
        containerView.addSubview(containerStack)
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        containerStack.backgroundColor = .white
        containerStack.axis = .vertical
        containerStack.distribution = .fillEqually
        containerStack.anchors.top.equal(containerView.anchors.top)
        containerStack.anchors.leading.equal(containerView.anchors.leading, constant: 12)
        containerStack.anchors.trailing.equal(containerView.anchors.trailing, constant: -12)
        containerStack.anchors.bottom.equal(containerView.anchors.bottom)
        
        configureNominalDonationStack()
        configureFeeAdminStack()
        configureTotalPaymentStack()
    }
    
    private func configureNominalDonationStack() {
        containerStack.addArrangedSubview(nominalDonationStack)
        nominalDonationStack.translatesAutoresizingMaskIntoConstraints = false
        nominalDonationStack.axis = .horizontal
        nominalDonationStack.alignment = .fill
        nominalDonationStack.distribution = .fillEqually
        
        configureNominalDonationTitleLabel()
        configureNominalDonationNameLabel()
    }
    
    private func configureNominalDonationTitleLabel() {
        nominalDonationStack.addArrangedSubview(nominalDonationTitleLabel)
        nominalDonationTitleLabel.textColor = .placeholder
        nominalDonationTitleLabel.textAlignment = .left
        nominalDonationTitleLabel.font = .roboto(.regular, size: 14)
        nominalDonationTitleLabel.text = "Nominal Donasi"
    }
    
    private func configureNominalDonationNameLabel() {
        nominalDonationStack.addArrangedSubview(nominalDonationNameLabel)
        nominalDonationNameLabel.textColor = .black
        nominalDonationNameLabel.textAlignment = .right
        nominalDonationNameLabel.font = .roboto(.regular, size: 14)
    }
    
    private func configureFeeAdminStack() {
        containerStack.addArrangedSubview(feeAdminStack)
        feeAdminStack.axis = .horizontal
        feeAdminStack.alignment = .fill
        feeAdminStack.distribution = .fillEqually
        
        configureFeeAdminTitleLabel()
        configureFeeAdminNameLabel()
    }
    
    private func configureFeeAdminTitleLabel() {
        feeAdminStack.addArrangedSubview(feeAdminTitleLabel)
        feeAdminTitleLabel.textColor = .placeholder
        feeAdminTitleLabel.textAlignment = .left
        feeAdminTitleLabel.font = .roboto(.regular, size: 14)
        feeAdminTitleLabel.text = "Biaya admin"
    }
    
    private func configureFeeAdminNameLabel() {
        feeAdminStack.addArrangedSubview(feeAdminNameLabel)
        feeAdminNameLabel.textColor = .black
        feeAdminNameLabel.textAlignment = .right
        feeAdminNameLabel.font = .roboto(.regular, size: 14)
    }
    
    private func configureTotalPaymentStack() {
        containerStack.addArrangedSubview(totalPaymentStack)
        totalPaymentStack.axis = .horizontal
        totalPaymentStack.alignment = .fill
        totalPaymentStack.distribution = .fillEqually
        
        configureTotalPaymentTitleLabel()
        configureTotalPaymentNameLabel()
    }
    
    private func configureTotalPaymentTitleLabel() {
        totalPaymentStack.addArrangedSubview(totalPaymentTitleLabel)
        totalPaymentTitleLabel.textColor = .placeholder
        totalPaymentTitleLabel.textAlignment = .left
        totalPaymentTitleLabel.font = .roboto(.regular, size: 14)
        totalPaymentTitleLabel.text = "Total Pembayaran"
    }
    
    private func configureTotalPaymentNameLabel() {
        totalPaymentStack.addArrangedSubview(totalPaymentNameLabel)
        totalPaymentNameLabel.textColor = .black
        totalPaymentNameLabel.textAlignment = .right
        totalPaymentNameLabel.font = .roboto(.bold, size: 14)
    }
    
    public func configure(nominal: String, fee: String, total: String) {
        nominalDonationNameLabel.text = nominal
        feeAdminNameLabel.text = fee
        totalPaymentNameLabel.text = total
    }
}
