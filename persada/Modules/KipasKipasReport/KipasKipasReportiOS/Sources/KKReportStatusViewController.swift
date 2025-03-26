import UIKit
import KipasKipasShared

public final class KKReportStatusViewController: UIViewController {
    
    private let container = ScrollContainerView()
    private let imageView = UIImageView()
    private let headingLabel = UILabel()
    private let subheadingLabel = UILabel()
    
    private let buttonContainer = ScrollContainerView()
    private(set) public var blockButton = KKBaseButton()
    private(set) public var backButton = KKBaseButton()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
}

// MARK: UI
private extension KKReportStatusViewController {
    func configureUI() {
        view.backgroundColor = .white
        view.addSubview(container)
        view.addSubview(buttonContainer)
        
        configureContainer()
        configureButtonContainer()
        addBottomSafeAreaPaddingView(height: 24)
    }
    
    func configureContainer() {
        container.isCentered = true
        container.alignment = .center
        container.isScrollEnabled = false
        container.contentInsetAdjustmentBehavior = .never
        
        container.anchors.top.pin()
        container.anchors.edges.pin(axis: .horizontal)
        container.anchors.bottom.spacing(0, to: buttonContainer.anchors.top)
        
        configureImageView()
        configureHeadingLabel()
        configureSubheadingLabel()
    }
    
    func configureImageView() {
        imageView.image = .illustrationThumbOk
        container.addArrangedSubViews(imageView)
        
        imageView.anchors.width.equal(100)
        imageView.anchors.height.equal(90)
    }
    
    func configureHeadingLabel() {
        headingLabel.font = .airbnb(.bold, size: 14)
        headingLabel.textAlignment = .center
        headingLabel.text = "Terimakasih atas laporan yang kamu berikan"
        headingLabel.textColor = .black
        headingLabel.numberOfLines = 2
        
        let spacer = UIView()
        spacer.anchors.height.equal(22)
        container.addArrangedSubViews(spacer)
        
        container.addArrangedSubViews(headingLabel)
        headingLabel.anchors.width.equal(view.bounds.width * 0.50)
    }
    
    func configureSubheadingLabel() {
        subheadingLabel.font = .airbnb(.medium, size: 10)
        subheadingLabel.textAlignment = .center
        subheadingLabel.text = "Laporan kamu sangat membantu dalam menciptakan sosial media yang positif."
        subheadingLabel.textColor = .boulder
        subheadingLabel.numberOfLines = 2
        
        let spacer = UIView()
        spacer.anchors.height.equal(8)
        container.addArrangedSubViews(spacer)
        
        container.addArrangedSubViews(subheadingLabel)
        subheadingLabel.anchors.width.equal(view.bounds.width * 0.50)
    }
    
    func configureButtonContainer() {
        buttonContainer.isCentered = true
        buttonContainer.paddingLeft = 20
        buttonContainer.paddingRight = 20
        buttonContainer.spacingBetween = 12
        
        view.addSubview(buttonContainer)
        buttonContainer.anchors.top.spacing(0, to: container.anchors.bottom)
        buttonContainer.anchors.bottom.pin(inset: safeAreaInsets.bottom(default: 24))
        buttonContainer.anchors.edges.pin(axis: .horizontal)
       
        configureBlockButton()
        configureBackButton()
    }
    
    func configureBlockButton() {
        blockButton.font = .roboto(.bold, size: 14)
        blockButton.layer.cornerRadius = 4
        blockButton.backgroundColor = .watermelon
        blockButton.setTitleColor(.white, for: .normal)
       
        buttonContainer.addArrangedSubViews(blockButton)
        blockButton.anchors.height.equal(40)
    }
    
    func configureBackButton() {
        backButton.font = .roboto(.bold, size: 14)
        backButton.layer.cornerRadius = 4
        backButton.backgroundColor = .snowDrift
        backButton.setTitle("Kembali", for: .normal)
        backButton.setTitleColor(.gravel, for: .normal)
        backButton.layer.borderColor = UIColor.softPeach.cgColor
        backButton.layer.borderWidth = 1.0
        
        buttonContainer.addArrangedSubViews(backButton)
        backButton.anchors.height.equal(40)
    }
}

// TODO: Move this to shared scope
private extension UIEdgeInsets {
    func bottom(default inset: CGFloat) -> CGFloat {
        return bottom > 0 ? bottom : inset
    }
}
