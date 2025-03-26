import UIKit
import KipasKipasShared
import KipasKipasLuckyDraw

public final class WinnerListContainerViewControler: UIViewController {
    
    private let scrollContainer = ScrollContainerView()
    private let mainView = WinnerContainerListView()
    private let closeButton = KKBaseButton()

    private lazy var listController = WinnerListViewController()

    private let winners: [WinnerViewModel]
    
    init(winners: [WinnerViewModel]) {
        self.winners = winners
        super.init(nibName: nil, bundle: nil)
        self.listController.winners = winners
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
}

// MARK: UI
private extension WinnerListContainerViewControler {
    func configureUI() {
        view.backgroundColor = UIColor.systemGray4
        
        configureScrollContainer()
        configureMainView()
        configureListView()
        configureCloseButton()
    }
    
    func configureScrollContainer() {
        scrollContainer.clipsToBounds = true
        scrollContainer.layer.cornerRadius = 10
        view.addSubview(scrollContainer)
        
        let adaptedWidth = adapted(dimensionSize: 310, to: .width)
        scrollContainer.anchors.width.equal(adaptedWidth)
        scrollContainer.anchors.center.align()
    }
    
    func configureMainView() {
        scrollContainer.addArrangedSubViews(mainView)
        scrollContainer.layoutIfNeeded()
        scrollContainer.anchors.height.equal(scrollContainer.contentSize.height)
    }
    
    func configureListView() {
        addChild(listController)
        mainView.listView.addSubview(listController.view)
        listController.view.anchors.edges.pin()
        listController.didMove(toParent: self)
    }
    
    func configureCloseButton() {
        closeButton.backgroundColor = .clear
        closeButton.setImage(UIImage.LuckyDraw.iconX)
        
        view.addSubview(closeButton)
        closeButton.anchors.width.equal(27)
        closeButton.anchors.height.equal(27)
        closeButton.anchors.centerX.align()
        closeButton.anchors.top.spacing(20, to: scrollContainer.anchors.bottom)
    }
}
