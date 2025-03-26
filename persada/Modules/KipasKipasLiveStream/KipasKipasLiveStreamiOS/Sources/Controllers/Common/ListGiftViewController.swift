import UIKit
import KipasKipasTRTC
import KipasKipasLiveStream
import KipasKipasShared

public final class ListGiftViewController: UIViewController, UICollectionViewDelegate {
    
    private lazy var dataSource = makeDataSource()
        
    private let headerView =  UIView() //UIStackView()
    private let userImgView = UIImageView()
    private let levelLabel =  UILabel()
    private let giftPanelView = GiftPanelView()
    private let fakeNavbar = FakeNavBar()
    private let coinView = CoinView()
    public func getCoinBalance() -> Int{
        return coinView.coinBalance
    }
    private(set) var topTextLabel = MarqueeLabel()
    
    private var collectionView: UICollectionView {
        giftPanelView.collectionView
    }
    
    #warning("[BEKA] move this to a protocol or extension")
    private var panNavigation: (UIViewController & PanModalPresentable)? {
        return navigationController as? (UIViewController & PanModalPresentable)
    }
    
    private var gifts: [LiveGift] = []
    private let selection: (LiveGift) -> Void
    
    var onLoadGifts: (() -> Void)?
    var onLoadCoinBalance: (() -> Void)?
    
    var onTapTopUpCoin: (() -> Void)?
    var myPhoto:String = ""
    init(selection: @escaping (LiveGift) -> Void) {
        self.selection = selection

        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        onLoadGifts?()
        
        giftPanelView.coinView.onTap(action: onTapTopUpCoin)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        onLoadCoinBalance?()
        navigationController?.setNavigationBarHidden(true, animated: false)
        panNavigation?.panModalSetNeedsLayoutUpdate()
        panNavigation?.panModalTransition(to: .longForm)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        #warning("[BEKA] remove this")
        giftPanelView.removeGradient()
    }
    
    private func set(_ items: [CellController]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
        snapshot.deleteAllItems()
        snapshot.appendSections([0])
        snapshot.appendItems(items)
        dataSource.apply(snapshot)
    }
    
    func onReceiveGift(_ gift: GiftData, isSelf: Bool) {
        if let index = gifts.firstIndex(where: { $0.id == gift.giftId }) {
            let cell = cellController(forItemAt: index)
            cell?.isLoading = false
            
            if isSelf {
                coinView.coinBalance -= gifts[safe: index]?.price ?? 0
            }
        }
    }
    
    private func cellController(forItemAt index: Int) -> GiftCellController? {
        let controller = dataSource.itemIdentifier(for: .init(item: index, section: 0)) as? GiftCellController
        return controller
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cellController(forItemAt: indexPath.item)?.select()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        cellController(forItemAt: indexPath.item)?.deselect()
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        giftPanelView.gradientLayer.colors = [
            collectionView.topOpacity,
            giftPanelView.opaqueColor,
            giftPanelView.opaqueColor,
            collectionView.bottomOpacity
        ]
    }
}

// MARK: PanModal
extension ListGiftViewController: PanModalPresentable {
    public var panScrollable: UIScrollView? {
        collectionView
    }
    
    public var longFormHeight: PanModalHeight {
        .contentHeight(400)
    }
    
    public var shortFormHeight: PanModalHeight {
        longFormHeight
    }
    
    public var panModalBackgroundColor: UIColor {
        .clear
    }
}

extension ListGiftViewController: ListGiftAdapterDelegate {
    func didFinishRequestList(with gifts: [LiveGift]) {
        self.gifts = gifts
        
        let controllers = gifts.compactMap  {
            return GiftCellController(viewModel: $0, selection: { [weak self] in
                guard let self = self else { return }
                if coinView.coinBalance == 0 || coinView.coinBalance < ($0.price ?? 0) {
                    onTapTopUpCoin?()
                } else {
                    selection($0)
                }
            })
        }
        set(controllers)
    }
    
    func didFinishRequestCoin(with coinBalance: Int) {
        coinView.coinBalance = coinBalance
    }
}

// MARK: UI
private extension ListGiftViewController {
    func configureUI() {
        configureHeaderView()
//        configureFakeNavbar()
        configureCollectionView()
//        configureCoinView()
    }
    
    func configureHeaderView(){
//        headerView.spacing = 6
//        headerView.alignment = .center
        headerView.backgroundColor = .gunMetal
        view.addSubview(headerView)
         
        headerView.anchors.height.equal(44)
        headerView.anchors.top.equal(view.anchors.top)
        headerView.anchors.leading.equal(view.anchors.leading)
        headerView.anchors.trailing.equal(view.anchors.trailing)
         
       
        let userView = UIView()
        headerView.addSubview(userView)
        userView.anchors.leading.spacing(12, to: headerView.anchors.leading)
        userView.anchors.centerY.equal(headerView.anchors.centerY)
        
        userImgView.layer.cornerRadius = 14
        userImgView.layer.masksToBounds = true
        userView.addSubview(userImgView) 
        userImgView.setImage(with: myPhoto, placeholder: .defaultProfileImageSmall)
        userImgView.anchors.width.equal(28)
        userImgView.anchors.height.equal(28)
        userImgView.anchors.edges.pin()
//        userImgView.anchors.top.equal(userView.anchors.top)
//        userImgView.anchors.leading.equal(userView.anchors.leading)
//        userImgView.anchors.trailing.equal(userView.anchors.trailing)
        //    MARK: - Reserved for the next version
//        levelLabel.text = "0"
//        levelLabel.textColor = .white
//        levelLabel.font = .roboto(.medium, size: 6)
//        levelLabel.textAlignment = .center
//        levelLabel.backgroundColor =  UIColor(hexString: "#ACACAC")
//        levelLabel.layer.cornerRadius = 3
//        levelLabel.layer.masksToBounds = true
//        userView.addSubview(levelLabel)
//        levelLabel.anchors.centerX.equal(userView.anchors.centerX)
//        levelLabel.anchors.height.equal(9)
//        levelLabel.anchors.width.greaterThanOrEqual(17)
//        levelLabel.anchors.bottom.spacing(3, to: userImgView.anchors.bottom)
//        levelLabel.anchors.bottom.spacing(0, to: userView.anchors.bottom)
//        levelLabel.isHidden = true
        
        topTextLabel.font = .roboto(.medium, size: 12)
        topTextLabel.textColor = UIColor(hexString: "#DDDDDD")
        topTextLabel.type = .continuous
        topTextLabel.textAlignment = .left
        topTextLabel.speed = .rate(15)
        topTextLabel.fadeLength = 15.0
        topTextLabel.text = "Send a Gift to activate your gifter level and rewards"
        headerView.addSubview(topTextLabel)
        topTextLabel.anchors.centerY.equal(headerView.anchors.centerY)
        topTextLabel.anchors.leading.spacing(8, to: userView.anchors.trailing)
        
//        let rightBtn = UIButton()
//        rightBtn.setImage(.iconRight, for: .normal)
//        headerView.addArrangedSubview(rightBtn)
//        rightBtn.anchors.trailing.spacing(12, to: headerView.anchors.trailing)
//        rightBtn.anchors.height.equal(40)
//        rightBtn.anchors.width.equal(40)
        
        coinView.coinAmountLabel.text = " 0"
        headerView.addSubview(coinView)
        coinView.anchors.trailing.spacing(-12, to: headerView.anchors.trailing)
        coinView.anchors.leading.spacing(8, to: topTextLabel.anchors.trailing)
        coinView.anchors.centerY.equal(headerView.anchors.centerY)
        coinView.coinAmountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
         
        let lineLabel = UILabel()
        lineLabel.backgroundColor = UIColor(hexString: "#ACACAC",alpha: 0.5)
        view.addSubview(lineLabel)
        lineLabel.anchor(left:view.leftAnchor,right:view.rightAnchor)
        lineLabel.anchors.top.spacing(-1, to: headerView.anchors.bottom)
        lineLabel.anchors.height.equal(1)
    }
    
    func configureCollectionView() {
        collectionView.backgroundColor = .gunMetal
        collectionView.collectionViewLayout = makeLayout()
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        collectionView.registerCell(GiftCell.self)
        
        view.addSubview(giftPanelView)
        giftPanelView.anchors.top.spacing(0, to: headerView.anchors.bottom)
        giftPanelView.anchors.edges.pin(axis: .horizontal)
        giftPanelView.anchors.bottom.pin()
    }
    
    func configureFakeNavbar() {
        fakeNavbar.titleLabel.text = "Gift Panel"
        fakeNavbar.titleLabel.font = .roboto(.regular, size: 14)
        fakeNavbar.titleLabel.textColor = .white
        fakeNavbar.titleLabel.textAlignment = .left
        fakeNavbar.backgroundColor = .gunMetal
        fakeNavbar.height = 41
        fakeNavbar.separatorView.backgroundColor = .gravel
        
        view.addSubview(fakeNavbar)
    }
    
    func configureCoinView() {
//        coinView.coinAmountLabel.text = " 0"
//        
//        fakeNavbar.addSubview(coinView)
//        coinView.anchors.centerY.align()
//        coinView.anchors.trailing.pin(inset: 16)
    }
}

// MARK: DataSource
private extension ListGiftViewController {
    func makeDataSource() -> EmptyableDiffableDataSource<Int, CellController> {
        let dataSource: EmptyableDiffableDataSource<Int, CellController>  = .init(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, controller in
                controller.view(collectionView, forItemAt: indexPath)
            },
            emptyStateView: EmptyView(message: "Belum ada gift")
        )
        return dataSource
    }
}

// MARK: Layout
private extension ListGiftViewController {
    func makeLayout() -> UICollectionViewCompositionalLayout {
        return .init(section: .listGift)
    }
}
