import UIKit
import KipasKipasLiveStream
import KipasKipasShared

final class AudienceListViewController: UICollectionViewController, NavigationAppearance {
     var audienceShowTips: Bool = false
    private lazy var dataSource = makeDataSource()
    
    
    
    var onLoadAudienceList: ((Int) -> Void)?
    
    private let selection: (String) -> Void
    private let giftAction: () -> Void
    private let faqAction: () -> Void
    
    init(selection: @escaping (String) -> Void,
         giftAction:@escaping ()->Void ,
         faqAction:@escaping ()->Void
    ) {
        self.selection = selection
        self.giftAction = giftAction
        self.faqAction = faqAction
        super.init(collectionViewLayout: UICollectionViewLayout())
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        onLoadAudienceList?(0)
    }
    
    private func set(_ items: [CellController]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
        snapshot.deleteAllItems()
        snapshot.appendSections([0])
        snapshot.appendItems(items)
        
        dataSource.apply(snapshot)
    }
    
    private func cellController(forItemAt indexPath: IndexPath) -> AudienceCellController? {
        let controller = dataSource.itemIdentifier(for: indexPath) as? AudienceCellController
        return controller
    }
    
    private func removeCellController(forItemAt indexPath: IndexPath) {
        cellController(forItemAt: indexPath)?.releaseForReuse()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cellController(forItemAt: indexPath)?.select()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        removeCellController(forItemAt: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView : UICollectionReusableView
        if kind == "UICollectionElementKindSectionFooter" {
             reusableView = collectionView.dequeueReusableFooter(at: indexPath)
            reusableView =   configureFooterUI(reusableView)
        }else {
            reusableView = collectionView.dequeueReusableHeader(at: indexPath)
            reusableView = configureHeaderUI(reusableView)
        }
        
        return reusableView
    }
    
    func configureHeaderUI(_ header:UICollectionReusableView) -> UICollectionReusableView{
         
        header.isHidden = dataSource.isEmpty
        
        let titleLabel = UILabel()
        titleLabel.font = .roboto(.regular, size: 12)
        titleLabel.textColor = .boulder
        titleLabel.text = "Top Viewers"
        
        header.addSubview(titleLabel)
        titleLabel.anchors.leading.pin()
        titleLabel.anchors.centerY.align()
        
        let rightView = UIView()
        header.addSubview(rightView)
        
        let imageV = UIImageView()
        imageV.image = .iconCoin
        rightView .addSubview(imageV)
        imageV.anchors.width.equal(12)
        imageV.anchors.height.equal(12)
        imageV.anchors.centerY.align()
        
        let coinLabel = UILabel()
        coinLabel.text = "Coins"
        coinLabel.font = .roboto(.regular, size: 12)
        coinLabel.textColor = .boulder
        rightView .addSubview(coinLabel)
        
        imageV.anchors.trailing.spacing(2, to: coinLabel.anchors.leading)
        coinLabel.anchors.centerY.align()
        coinLabel.anchors.trailing.pin()
        
        rightView.anchors.centerY.align()
        rightView.anchors.trailing.pin()
        
        return header
    }
    
    func configureFooterUI(_ footer:UICollectionReusableView) -> UICollectionReusableView{
        footer.isHidden = dataSource.isEmpty
         let leftLine = UILabel()
        leftLine.backgroundColor =  .softPeach
        footer.addSubview(leftLine)
        leftLine.anchor(left:footer.leftAnchor)
        leftLine.anchors.height.equal(1)
        leftLine.anchors.width.equal(40)
        leftLine.anchors.centerY.align()
        
        let textLabel = UILabel()
        textLabel.text = "Showing the top 99 viewers who have  their ranking turned on."
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        textLabel.font = .roboto(.regular, size: 13)
        textLabel.textColor = .boulder
         footer.addSubview(textLabel)
        textLabel.anchor(left:leftLine.rightAnchor)
        textLabel.anchors.centerY.align()
        
        let rightLine = UILabel()
        rightLine.backgroundColor =  .softPeach
        footer.addSubview(rightLine)
        rightLine.anchor(left:textLabel.rightAnchor,right:footer.rightAnchor)
        rightLine.anchors.height.equal(1)
        rightLine.anchors.width.equal(40)
        rightLine.anchors.centerY.align()
        
        return footer
    }
     
    
}

// MARK: UI
private extension AudienceListViewController {
    func configureUI() {
        configureNavBar()
        configureCollectionView()
        configureBottomView()
    }
    
    func configureNavBar(){
        setupNavigationBar(
            title: "Top viewers",
            shadowColor: .softPeach
        )
        let tnBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        tnBtn.onTap {   [weak self] in
            self?.faqAction()
        }
        tnBtn.setImage(.iconQuestion, for: .normal)
        let barItem = UIBarButtonItem(customView: tnBtn)
        self.navigationItem.rightBarButtonItem = barItem
    }
    
    func configureCollectionView() { 
        collectionView.contentInset.top = 16
        collectionView.backgroundColor = .white
        collectionView.collectionViewLayout = makeLayout()
        collectionView.dataSource = dataSource
        collectionView.registerCell(AudienceCell.self)
        collectionView.registerHeader(UICollectionReusableView.self)
        collectionView.registerFooter(UICollectionReusableView.self)
    }
    
    func configureBottomView(){
        guard audienceShowTips else { return }
        collectionView.contentInset.bottom = 82
        let footer = UIView()
        footer.backgroundColor = UIColor(hexString: "#FAFAFA")
        collectionView.superview?.addSubview(footer)
        let safeHeight = self.view.safeAreaBottom
        footer.anchors.height.equal(82)
        footer.anchors.bottom.equal(collectionView.anchors.bottom,constant: -safeHeight)
        footer.anchors.leading.equal(collectionView.anchors.leading)
        footer.anchors.trailing.equal(collectionView.anchors.trailing)
        
        if safeHeight > 0 {
            let view = UIView()
            view.backgroundColor = UIColor(hexString: "#FAFAFA")
            collectionView.superview?.addSubview(view)
            view.anchor(left:collectionView.leftAnchor, bottom: collectionView.bottomAnchor,right: collectionView.rightAnchor)
            view.anchors.height.equal(safeHeight)
        }
        
        let lineLabel = UILabel()
        lineLabel.backgroundColor =  .softPeach
        footer.addSubview(lineLabel)
        lineLabel.anchor(top: footer.topAnchor,left:footer.leftAnchor,right:footer.rightAnchor)
        lineLabel.anchors.height.equal(1)
        
        let imageV = UIImageView()
        imageV.image = .iconMedal
        footer .addSubview(imageV)
        imageV.anchors.width.equal(40)
        imageV.anchors.height.equal(40)
        imageV.anchors.centerY.align()
        imageV.anchors.leading.pin(inset: 14)
        
        let titleLabel = UILabel()
        titleLabel.font = .roboto(.regular, size: 13)
        titleLabel.textColor = .gravel
        titleLabel.numberOfLines = 0
        titleLabel.text = "Send a Gift and have a chance to get a badge and be shown at the top of the LIVE"
        titleLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        footer.addSubview(titleLabel)
        titleLabel.anchors.centerY.align()
        titleLabel.anchors.leading.spacing(2, to: imageV.anchors.trailing)
        
        let giftBtn = UIButton()
        giftBtn.setTitle("Gift")
        giftBtn.titleLabel?.font = .roboto(.bold, size: 14)
        giftBtn.layer.cornerRadius = 4
        giftBtn.backgroundColor = UIColor(hexString: "#FD274A")
        footer.addSubview(giftBtn)
        giftBtn.anchors.centerY.align()
        giftBtn.anchors.width.equal(50)
        giftBtn.anchors.height.equal(30)
        giftBtn.anchors.leading.spacing(2, to: titleLabel.anchors.trailing)
        giftBtn.anchors.trailing.equal(footer.anchors.trailing, constant: -14)
        giftBtn.onTap {
            self.giftAction()
        }
    }
     
}

 

// MARK: DataSource
private extension AudienceListViewController {
    func makeDataSource() -> EmptyableDiffableDataSource<Int, CellController> {
        let dataSource: EmptyableDiffableDataSource<Int, CellController>  = .init(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, controller in
                controller.view(collectionView, forItemAt: indexPath)
            },
            emptyStateView: EmptyView(message: "Belum ada penonton")
        )
        dataSource.supplementaryViewProvider = collectionView(_:viewForSupplementaryElementOfKind:at:)
        return dataSource
    }
}

// MARK: Layout
private extension AudienceListViewController {
    func makeLayout() -> UICollectionViewCompositionalLayout {
        let section = NSCollectionLayoutSection.audienceList
        configureHeader(in: section)
        configureFooter(in: section)
        return .init(section: section)
    }
    
    func configureHeader(in section: NSCollectionLayoutSection) {
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(20)
            ),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top,
            absoluteOffset: .init(x: 0, y: -16)
        )
        section.boundarySupplementaryItems = [header]
    }
    
    func configureFooter(in section: NSCollectionLayoutSection) {
        let footer = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(82)
            ),
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: .bottom,
            absoluteOffset: .init(x: 0, y: 0)
        )
        section.boundarySupplementaryItems += [footer]
    }
}
  

extension AudienceListViewController: LiveStreamAudienceListAdapterDelegate {
    func didFinishRequestCoin(with coinBalance: Int) { }
    
    func didFinishRequestTopSeats(with topSeats: [LiveTopSeat]) {}
    func didFinishRequestClassicGift(with gifts: [LiveGift]){}
    
    func didFinishRequest(with audiences: [LiveStreamAudience]) {
        var isReward = false
        if audiences.count > 0 && audiences[0].totalCoin ?? 0 > 0 {
            isReward = true
        }
        
        let controllers = audiences.map {
            return AudienceCellController(
                userId: String($0.id ?? 0) ,
                name: $0.name ?? "" ,
                image: $0.photo ?? "" ,
                totalCoin: $0.totalCoin ?? 0,
                isReward: isReward,
                selection: selection
            )
        }
        set(controllers)
    }
}
