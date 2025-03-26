import UIKit
import KipasKipasShared
import KipasKipasLuckyDraw

public final class PrizeClaimViewController: UIViewController {
    
    private let notificationView = PrizeClaimNotificationView()
    private let mainView = PrizeClaimView()
    private let scrollContainer = ScrollContainerView()
    private let closeButton = KKBaseButton()
    
    private let selfAccountId: String
    private let viewModel: GiftBoxViewModel
    
    // MARK: Initializers
    init(
        selfAccountId: String,
        viewModel: GiftBoxViewModel
    ) {
        self.selfAccountId = selfAccountId
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    // MARK: Overridens
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureData()
        
//        let attributedMessage = NSAttributedString(string: "Selamat! Anda telah memenangkan satu unit iPhone dari sendy Blogger!", attributes: [:])
//        notificationView.setMessage(attributedMessage)
//        notificationView.setBackgroundImage(UIImage.LuckyDraw.notificationGradientBackground)
//        notificationView.setTintColor(.white)
    }
    
    // MARK: Privates
    private func configureData() {
        let winnerUserIds = viewModel.winners.map { String($0.id) }
        
        if winnerUserIds.contains(selfAccountId) {
            mainView.configure(with: viewModel)
        } else {
            mainView.configureUnlucky()
        }
    }
    
    @objc private func didTapCloseButton() {
        forceDismiss()
    }
}

// MARK: UI
private extension PrizeClaimViewController {
    func configureUI() {
        view.backgroundColor = .clear
        
        configureScrollContainer()
        configureMainView()
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
    
    func configureCloseButton() {
        closeButton.backgroundColor = .clear
        closeButton.setImage(UIImage.LuckyDraw.iconX)
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        
        view.addSubview(closeButton)
        closeButton.anchors.width.equal(27)
        closeButton.anchors.height.equal(27)
        closeButton.anchors.centerX.align()
        closeButton.anchors.top.spacing(20, to: scrollContainer.anchors.bottom)
    }
}
