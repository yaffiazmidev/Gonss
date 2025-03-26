import UIKit
import KipasKipasShared

final class WinnerContainerListView: UIView {
    private let container = UIView()
    private let stackView = UIStackView()
    
    private let headingContainerView = UIStackView()
    private let headingStackView = UIStackView()
    private let headingLabel = UILabel()
    private let headingGradientView = UIImageView()
    
    let listView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
}

// MARK: UI
private extension WinnerContainerListView {
    func configureUI() {
        configureContainer()
        configureStackView()
        configureHeadingGradientView()
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
        
        configureSpacer(20)
        configureHeadingContainerView()
        configureSpacer(20)
        configureListView()
    }
    
    // MARK: Spacer
    func configureSpacer(_ height: CGFloat) {
        stackView.addArrangedSubview(spacer(height))
    }
    
    // MARK: Heading
    func configureHeadingContainerView() {
        headingContainerView.clipsToBounds = true
        
        stackView.addArrangedSubview(headingContainerView)
        
        configureHeadingStackView()
    }
    
    func configureHeadingStackView() {
        headingStackView.axis = .vertical
        headingStackView.spacing = 5
        
        headingContainerView.addArrangedSubview(headingStackView)
        headingStackView.anchors.center.align()
        
        configureHeadingLabel()
    }
    
    func configureHeadingLabel() {
        headingLabel.text = "Penonton Beruntung"
        headingLabel.font = .roboto(.medium, size: 16)
        headingLabel.textColor = UIColor(hexString: "#960F0F")
        headingLabel.textAlignment = .center
        
        headingStackView.addArrangedSubview(headingLabel)
    }
    
    func configureHeadingGradientView() {
        headingGradientView.image = UIImage.LuckyDraw.headingGradientBackground
        headingGradientView.contentMode = .redraw
        
        container.insertSubview(headingGradientView, at: 0)
        headingGradientView.anchors.top.pin()
        headingGradientView.anchors.edges.pin(axis: .horizontal)
        headingGradientView.anchors.height.equal(96)
    }
    
    func configureListView() {
        listView.backgroundColor = .clear
        
        stackView.addArrangedSubview(listView)
        
        let adaptedHeight = adapted(dimensionSize: 282, to: .height)
        listView.anchors.height.equal(adaptedHeight)
    }
}
