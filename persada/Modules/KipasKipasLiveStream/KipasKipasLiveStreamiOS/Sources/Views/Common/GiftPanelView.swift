import UIKit
import KipasKipasShared

final class GiftPanelView: UIView, UICollectionViewDelegate {
    
    private let container = UIView()
    private(set) var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    
    private let bottomStackView = UIStackView()
    private let bottomView = UIView()
    private let safeAreaView = UIView()
    
    private(set) var gradientLayer = CAGradientLayer()
    private(set) var opaqueColor = UIColor.night.cgColor
    
    private(set) lazy var coinView = CoinView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureFadingLayer()
    }
    
    func removeGradient() {
        container.layer.mask = nil
    }
}

// MARK: UI
private extension GiftPanelView {
    func configureUI() {
        configureBottomStackView()
        configureContainer()
    }
    
    func configureContainer() {
        container.backgroundColor = .clear
        
        addSubview(container)
        container.anchors.top.pin()
        container.anchors.edges.pin(axis: .horizontal)
        container.anchors.bottom.spacing(0, to: bottomStackView.anchors.top)
        
        configureCollectionView()
    }
    
    func configureCollectionView() {
        collectionView.backgroundColor = .gunMetal
        collectionView.registerCell(GiftCell.self)
        
        container.addSubview(collectionView)
        collectionView.anchors.edges.pin()
    }
    
    func configureBottomStackView() {
        bottomStackView.backgroundColor = .clear
        bottomStackView.axis = .vertical
        
        addSubview(bottomStackView)
        bottomStackView.anchors.edges.pin(axis: .horizontal)
        bottomStackView.anchors.bottom.pin()
        
        configureBottomView()
        configureBottomSafeArea()
    }
    
    func configureBottomView() {
        bottomView.backgroundColor = .gunMetal
        
        bottomStackView.addArrangedSubview(bottomView)
        bottomView.anchors.height.equal(50)
        
        configureCoinView()
    }
    
    func configureBottomSafeArea() {
        safeAreaView.backgroundColor = .gunMetal
        
        bottomStackView.addArrangedSubview(safeAreaView)
        safeAreaView.anchors.height.equal(16)
    }
    
    func configureCoinView() {
        coinView.backgroundColor = .mirage
        coinView.coinAmountLabel.text = " Recharge"
        coinView.coinAmountLabel.font = .roboto(.regular, size: 14)
        coinView.layer.cornerRadius = 4
        
        bottomView.addSubview(coinView)
        coinView.anchors.centerY.align()
        coinView.anchors.trailing.pin(inset: 16)
        coinView.anchors.height.equal(28)
        
        let arrow = UIImage(systemName: "chevron.right")
        let imageView = UIImageView(image: arrow)
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFill
        imageView.anchors.width.equal(8)
        imageView.anchors.height.equal(12)
        
        coinView.addViewToStack(imageView)
    }
    
    func configureFadingLayer() {
        gradientLayer.removeFromSuperlayer()
        
        let maskLayer = CALayer()
        maskLayer.frame = bounds
        
        let boundsSize = bounds.size
        
        gradientLayer.frame = CGRect(x: bounds.origin.x, y: 0, width: boundsSize.width, height: boundsSize.height)
        gradientLayer.colors = [opaqueColor, opaqueColor, opaqueColor, opaqueColor]
        gradientLayer.locations = [0, 0.3, 0.7, 1]
        
        maskLayer.addSublayer(gradientLayer)
        
        container.layer.mask = maskLayer
    }
}
