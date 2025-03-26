import UIKit
import KipasKipasShared

final class CoinView: UIView {
    
    var coinBalance: Int = 0 {
        didSet {
            coinAmountLabel.text = String(max(0, coinBalance))
        }
    }
    
    private let coinStack = UIStackView()
    private(set) var coinImageView = UIImageView()
    private(set) var coinAmountLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    private func configureUI() {
        coinStack.spacing = 2
        coinStack.alignment = .center
        
        coinImageView.image = .iconCoin
        coinStack.addArrangedSubview(coinImageView)
        coinImageView.anchors.width.equal(12)
        coinImageView.anchors.height.equal(12)
        
        coinAmountLabel.font = .roboto(.regular, size: 10)
        coinAmountLabel.textColor = .white
        coinStack.addArrangedSubview(coinAmountLabel)
        
        addSubview(coinStack)
        coinStack.anchors.edges.pin(axis: .vertical)
        coinStack.anchors.edges.pin(insets: 6, axis: .horizontal)
    }
    
    func addViewToStack(_ view: UIView) {
        coinStack.addArrangedSubview(view)
    }
}

final class GiftCell: UICollectionViewCell {
    
    var setSelected: Bool = false {
        didSet {
            set(setSelected)
            layoutIfNeeded()
        }
    }
    
    var isLoading: Bool = false {
        didSet {
            setLoadingUI(isLoading)
        }
    }
    
    private let container = UIView()
    private let stack = UIStackView()
    
    private(set) var giftImageView = UIImageView()
    private(set) var giftNameLabel = UILabel()
    
    private(set) var coinView = CoinView()
    
    private(set) var sendButton = KKLoadingButton()
    private(set) var loadingView = MaterialLoadingIndicator()
    
    private var giftImageDimension: CGFloat = 50 {
        didSet {
            giftImageWidth.constant = giftImageDimension
            giftImageHeight.constant = giftImageDimension
        }
    }
    
    private var giftImageWidth: NSLayoutConstraint! {
        didSet {
            giftImageWidth.isActive = true
        }
    }
    
    private var giftImageHeight: NSLayoutConstraint! {
        didSet {
            giftImageHeight.isActive = true
        }
    }
    
    private lazy var gradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 0.088, green: 0.088, blue: 0.088, alpha: 1).cgColor,
            UIColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 0.1).cgColor
        ]
        layer.locations = [0, 1]
        layer.startPoint = CGPoint(x: 0.25, y: 0.5)
        layer.endPoint = CGPoint(x: 0.75, y: 0.5)
        layer.transform = CATransform3DMakeAffineTransform(.init(a: 0, b: 1, c: -0.9, d: 0, tx: 1, ty: 0))
        layer.cornerRadius = 8
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        configureUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setSelected = false
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.bounds = container.bounds
        gradientLayer.position = container.center
        
        if setSelected {
            container.layer.insertSublayer(gradientLayer, at: 0)
        } else {
            gradientLayer.removeFromSuperlayer()
        }
    }
    
    private func set(_ isSelected: Bool) {
        if isSelected {
            giftImageView.transform = .init(translationX: 0, y: -20)
            coinView.transform = .init(translationX: 0, y: -10)
            giftNameLabel.isHidden = true
            sendButton.isHidden = false
            giftImageDimension = 60
            
        } else {
            giftImageView.transform = .identity
            coinView.transform = .identity
            giftNameLabel.isHidden = false
            sendButton.isHidden = true
            giftImageDimension = 50
        }
    }
    
    private func setLoadingUI(_ isLoading: Bool) {
        if isLoading {
            loadingView.isHidden = false
            loadingView.startAnimating()
            sendButton.isEnabled = false
        } else {
            loadingView.stopAnimating()
            loadingView.isAnimating = false
            loadingView.isHidden = true
            sendButton.isEnabled = true
        }
    }
}

// MARK: UI
private extension GiftCell {
    func configureUI() {
        configureContainer()
        configureStack()
        configureLoadingView()
    }
    
    func configureContainer() {
        contentView.addSubview(container)
        container.anchors.edges.pin()
    }
    
    func configureStack() {
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .equalSpacing
        
        container.addSubview(stack)
        stack.anchors.edges.pin()
        
        configureGiftImageView()
        configureGiftNameLabel()
        configureGiftCoin()
        configureSendButton()
    }
    
    func configureGiftImageView() {
        giftImageView.contentMode = .scaleAspectFill
        
        stack.addArrangedSubview(giftImageView)
        giftImageHeight = giftImageView.anchors.height.equal(giftImageDimension)
        giftImageWidth = giftImageView.anchors.width.equal(giftImageDimension)
    }
    
    func configureGiftNameLabel() {
        giftNameLabel.textAlignment = .center
        giftNameLabel.font = .roboto(.regular, size: 10)
        giftNameLabel.textColor = .white
        
        stack.addArrangedSubview(giftNameLabel)
    }
    
    func configureGiftCoin() {
        stack.addArrangedSubview(coinView)
    }
    
    func configureSendButton() {
        sendButton.setTitle("Kirim")
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.font = .roboto(.bold, size: 14)
        sendButton.setBackgroundColor(.watermelon, for: .normal)
        sendButton.setBackgroundColor(UIColor.watermelon.withAlphaComponent(0.5), for: .disabled)
        sendButton.clipsToBounds = true
        sendButton.layer.cornerRadius = 8
        sendButton.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        sendButton.isHidden = true
        
        stack.addArrangedSubview(sendButton)
        sendButton.anchors.width.equal(contentView.anchors.width)
        sendButton.anchors.height.equal(contentView.anchors.height * 0.25)
    }
    
    func configureLoadingView() {
        loadingView.color = UIColor.watermelon.withAlphaComponent(0.7)
        loadingView.lineWidth = 4
        loadingView.backgroundColor = .clear
        
        container.addSubview(loadingView)
        container.bringSubviewToFront(loadingView)
        
        loadingView.anchors.top.pin()
        loadingView.anchors.edges.pin(axis: .horizontal)
        loadingView.anchors.height.equal(container.anchors.height * 0.75)
    }
}
