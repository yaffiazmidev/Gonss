import UIKit
import KipasKipasShared

class DonationHistoryCardCell: UIView {
    
    enum HistoryType {
        case withdrawal
        case donation
        case donationItem
    }
    
    var titleText: String {
        switch historyType {
        case .withdrawal:
            return "Penarikan Dana"
        case .donation:
            return "Dana Terkumpul"
        case .donationItem:
            return "Barang Terkumpul"
        }
    }
    
    var color: UIColor {
        switch historyType {
        case .withdrawal:
            return .watermelon
        case .donation, .donationItem:
            return .azure
        }
    }
    
    var hideBottomStack: Bool {
        switch historyType {
        case .withdrawal:
            return true
        case .donation:
            return false
        case .donationItem:
            return true
        }
    }
    
    var historyType: HistoryType = .donation {
        didSet {
            colorTheme = color
            titleLabel.text = titleText
            progressView.isHidden = historyType == .donationItem
            bottomHorizontalStack.isHidden = hideBottomStack
        }
    }
    
    var onTapHistoryButton: (() -> Void)?
    
    private var colorTheme: UIColor = .azure {
        didSet { updateAppearance() }
    }
    
    private let container = ScrollContainerView()
    
    private let topHorizontalStack = UIStackView()
    
    private(set) var titleLabel = UILabel()
    private(set) var historyButton = UIButton()
    private let  unbrokenUnderline = UIView()
    
    private(set) var amountLabel = InteractiveLabel()
    private(set) var progressView = UIProgressView()
    
    private let bottomHorizontalStack = UIStackView()
    private let adminFeeInfoView = UIStackView()
    
    private let adminFeeTitleLabel = UILabel()
    private let adminFeeInfoLabel = UILabel()
    private(set) var adminFeeLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        configureUI()
    }
    
    private func updateAppearance() {
        titleLabel.textColor = colorTheme
        historyButton.setTitleColor(colorTheme, for: .normal)
        unbrokenUnderline.backgroundColor = historyButton.currentTitleColor
        amountLabel.textColor = colorTheme
        progressView.tintColor = colorTheme
    }
    
    @objc private func historyButtonTapped() {
        onTapHistoryButton?()
    }
}

// MARK: UI
private extension DonationHistoryCardCell {
    func configureUI() {
        layer.cornerRadius = 6
        clipsToBounds = true
        backgroundColor = .snowDrift
        
        configureContainerView()
        configureTopHorizontalStack()
        configureAmountLabel()
        configureProgressView()
        configureBottomHorizontalStack()
    }
    
    func configureContainerView() {
        container.backgroundColor = .clear
        container.spacingBetween = 5
        container.isScrollEnabled = false
        
        addSubview(container)
        container.anchors.edges.pin(insets: 8)
    }
    
    func configureTopHorizontalStack() {
        topHorizontalStack.distribution = .equalSpacing
        topHorizontalStack.alignment = .center
        
        container.addArrangedSubViews(topHorizontalStack)
        
        configureTitleLabel()
        configureHistoryButton()
    }
    
    func configureTitleLabel() {
        titleLabel.textColor = colorTheme
        titleLabel.font = .roboto(.medium, size: 12)
        
        topHorizontalStack.addArrangedSubview(titleLabel)
    }
    
    func configureHistoryButton() {
        historyButton.setTitle("Riwayat", for: .normal)
        historyButton.setTitleColor(colorTheme, for: .normal)
        historyButton.titleLabel?.font = .roboto(.medium, size: 12)
        historyButton.addTarget(self, action: #selector(historyButtonTapped), for: .touchUpInside)
        
        unbrokenUnderline.anchors.height.equal(1)
        unbrokenUnderline.backgroundColor = historyButton.currentTitleColor
        
        historyButton.addSubview(unbrokenUnderline)
        unbrokenUnderline.anchors.bottom.pin(inset: 7)
        unbrokenUnderline.anchors.edges.pin(axis: .horizontal)
        
        topHorizontalStack.addArrangedSubview(historyButton)
    }
    
    func configureAmountLabel() {
        amountLabel.textColor = colorTheme
        amountLabel.font = .roboto(.bold, size: 24)
        
        container.addArrangedSubViews(amountLabel)
    }
    
    func configureProgressView() {
        progressView.tintColor = colorTheme
        progressView.trackTintColor = .gainsboro
        progressView.anchors.height.equal(5)
        
        let spacer = UIView()
        container.addArrangedSubViews(spacer)
        container.addArrangedSubViews(progressView)
    }
    
    func configureBottomHorizontalStack() {
        bottomHorizontalStack.alignment = .top
        bottomHorizontalStack.distribution = .equalSpacing
        
        let spacer = UIView()
        container.addArrangedSubViews(spacer)
        container.addArrangedSubViews(bottomHorizontalStack)
       
        adminFeeInfoView.axis = .vertical
        bottomHorizontalStack.addArrangedSubview(adminFeeInfoView)
        
        configureAdminFeeTitleLabel()
        configureAdminFeeInfoLabel()
        configureAdminFeeLabel()
    }
    
    func configureAdminFeeTitleLabel() {
        adminFeeTitleLabel.text = "Total Biaya Admin"
        adminFeeTitleLabel.textColor = .gravel
        adminFeeTitleLabel.font = .roboto(.medium, size: 12)
        
        adminFeeInfoView.addArrangedSubview(adminFeeTitleLabel)
    }
    
    func configureAdminFeeInfoLabel() {
        adminFeeInfoLabel.text = "Dipotong di awal saat donatur mengirim uang"
        adminFeeInfoLabel.textColor = .boulder
        adminFeeInfoLabel.font = .roboto(.regular, size: 10)
        
        adminFeeInfoView.addArrangedSubview(adminFeeInfoLabel)
    }
    
    func configureAdminFeeLabel() {
        adminFeeLabel.textColor = .brightRed
        adminFeeLabel.font = .roboto(.bold, size: 14)
        adminFeeLabel.textAlignment = .right
        
        bottomHorizontalStack.addArrangedSubview(adminFeeLabel)
    }
}
