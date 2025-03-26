import UIKit
import KipasKipasShared
import KipasKipasLuckyDraw
import KipasKipasImage

final class PrizeClaimView: UIView {
    private let container = UIView()
    private let stackView = UIStackView()
    
    private let headingContainerView = UIImageView()
    private let headingStackView = UIStackView()
    private let headingLabel = UILabel()
    private let productNameLabel = UILabel()
    
    private let imageView = UIImageView()
    
    private let buttonStackView = UIStackView()
    private let winnersButton = KKBaseButton()
    private let arrowView = UIImageView()
    
    private let claimButton = KKBaseButton()
    
    // MARK: Overridens
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    // MARK: API
    func configure(with viewModel: GiftBoxViewModel) {
        headingLabel.text = "Selamat!"
        headingLabel.textColor = UIColor(hexString: "#960F0F")
        productNameLabel.text = viewModel.giftName
        headingContainerView.image = UIImage.LuckyDraw.headingGradientBackground
        claimButton.setTitle("Klaim Hadiah")
        
        KipasKipasImage.fetchImage(with: .init(url: viewModel.photoURL), into: imageView)
    }
    
    func configureUnlucky() {
        headingLabel.text = "Sayang sekali!"
        headingLabel.textColor = UIColor(hexString: "#292929")
        imageView.image = UIImage.LuckyDraw.giftBoxHeartIllustration
        productNameLabel.text = "Memberikan Anda keberuntungan~"
        headingContainerView.image = UIImage.LuckyDraw.headingGradientGrayBackground
        claimButton.setTitle("Mengerti")
    }
}

// MARK: UI
private extension PrizeClaimView {
    func configureUI() {
        configureContainer()
        configureStackView()
    }
    
    func configureContainer() {
        container.backgroundColor = .white
        container.clipsToBounds = true
        
        addSubview(container)
        container.anchors.edges.pin()
    }
    
    func configureStackView() {
        stackView.axis = .vertical
        
        container.addSubview(stackView)
        stackView.anchors.edges.pin()
        
        configureHeadingContainerView()
    }
    
    // MARK: Spacer
    func configureSpacer(_ height: CGFloat) {
        stackView.addArrangedSubview(spacer(height))
    }
    
    // MARK: Heading
    func configureHeadingContainerView() {
        headingContainerView.contentMode = .redraw
        headingContainerView.clipsToBounds = true
        
        stackView.addArrangedSubview(headingContainerView)
        headingContainerView.anchors.height.equal(96)
        
        configureHeadingStackView()
    }
    
    func configureHeadingStackView() {
        headingStackView.axis = .vertical
        headingStackView.spacing = 5
        
        headingContainerView.addSubview(headingStackView)
        headingStackView.anchors.center.align()
        
        configureHeadingLabel()
        configureSubheadingLabel()
        configureImageView()
        configureSpacer(27)
        configureButtonStackView()
        configureSpacer(12)
        configureClaimButton()
        configureSpacer(22)
    }
    
    func configureHeadingLabel() {
        headingLabel.font = .roboto(.bold, size: 18)
        headingLabel.textAlignment = .center
        
        headingStackView.addArrangedSubview(headingLabel)
    }
    
    func configureSubheadingLabel() {
        productNameLabel.font = .roboto(.regular, size: 15)
        productNameLabel.textColor = .boulder
        productNameLabel.textAlignment = .center
        
        headingStackView.addArrangedSubview(productNameLabel)
    }
    
    // MARK: Image
    func configureImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear
        
        let adaptedDimension = adapted(dimensionSize: 110, to: .width)
        let container = spacer(adaptedDimension)
        container.addSubview(imageView)
        
        imageView.anchors.width.equal(adaptedDimension)
        imageView.anchors.edges.pin(axis: .vertical)
        imageView.anchors.center.align()
        
        stackView.addArrangedSubview(container)
    }
    
    // MARK: Winners Button
    func configureButtonStackView() {
        buttonStackView.alignment = .center
        
        let container = spacer(14)
        container.addSubview(buttonStackView)
        
        let adaptedWidth = adapted(dimensionSize: 115, to: .width)
        buttonStackView.anchors.width.equal(adaptedWidth)
        buttonStackView.anchors.edges.pin(axis: .vertical)
        buttonStackView.anchors.center.align()
        
        stackView.addArrangedSubview(container)
        
        configureWinnersButton()
        configureArrowView()
    }
    
    func configureWinnersButton() {
        winnersButton.setTitle("Lihat Pemenang")
        winnersButton.font = .roboto(.regular, size: 12)
        winnersButton.setTitleColor(.boulder, for: .normal)
        
        buttonStackView.addArrangedSubview(winnersButton)
    }
    
    func configureArrowView() {
        arrowView.backgroundColor = .clear
        arrowView.image = .iconArrowRightGrey?.withTintColor(.boulder)
        arrowView.contentMode = .scaleAspectFit
        
        buttonStackView.addArrangedSubview(arrowView)
        
        arrowView.anchors.width.equal(7)
        arrowView.anchors.height.equal(10)
    }
    
    // MARK: Claim Button
    func configureClaimButton() {
        claimButton.font = .roboto(.bold, size: 15)
        claimButton.setTitleColor(.white, for: .normal)
        claimButton.backgroundColor = .watermelon
        claimButton.layer.cornerRadius = 8
        
        let container = spacer(44)
        container.addSubview(claimButton)
        
        claimButton.anchors.edges.pin(axis: .vertical)
        claimButton.anchors.edges.pin(insets: 25, axis: .horizontal)
        
        stackView.addArrangedSubview(container)
    }
}
