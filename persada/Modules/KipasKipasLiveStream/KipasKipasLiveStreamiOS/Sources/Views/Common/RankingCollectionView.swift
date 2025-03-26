 

//import Foundation
import UIKit
import Combine
import KipasKipasShared
import KipasKipasLiveStream


final class RankingCollectionView: UICollectionView,UICollectionViewDelegate {
   
    var sendGiftAction: (() -> Void)?
    var privateViewModels: [LiveDailyRankViewModel] = []
    var liveRoomInfo: LiveRoomInfoViewModel?
    
    let ownerInfo:[String:Any] = KKCache.common.readDictionary(key: .roomInfoCache) ?? ["":""]
    private lazy var privateDataSource = makeDataSource()
    private var countdownCancellable: AnyCancellable?
    
    private let refreshCountdownLabel = UILabel()
    
    private var inventedHeader = DailyRankHeaderView()
    private let bottomView = UIView()
    private let stackLabel = UIStackView()
    private(set) var rankLabel = UILabel()
    private(set) var imageView = UIImageView()
    private(set) var nameLabel = UILabel()
    private(set) var descLabel = UILabel()
    private(set) var verifiedIcon = UIImageView()
    
    
    
    var selection: ((String) -> Void)?
    private var topRanks: [LiveDailyRankViewModel] = [] 
//    {
//        didSet {
//            self.reloadData()
//        }
//    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func setup(){
        self.delegate = self
        self.backgroundColor = .white
        self.collectionViewLayout = makeLayout()
        self.dataSource = dataSource
        self.registerCell(DailyRankCell.self)
        self.registerHeader(DailyRankHeaderView.self)
        
        startCountdown()
        setupSuspensionView() 
    }
     
    
    private var header: DailyRankHeaderView? {
        return self.visibleHeaders.first as? DailyRankHeaderView
    }
    
    private func set(_ items: [CellController]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
        snapshot.deleteAllItems()
        snapshot.appendSections([0])
        snapshot.appendItems(items)
        privateDataSource.apply(snapshot)
    }
    
    private func cell(at indexPath: IndexPath) -> CellController? {
        return privateDataSource.itemIdentifier(for: indexPath)
    }
    
    func fixHeader(){
        if privateViewModels.count == 0 || privateViewModels.count > 3 {
             return
        }
        let indexPath:IndexPath = IndexPath(row: 0, section: 0)
        inventedHeader = self.dequeueReusableHeader(at: indexPath)
        inventedHeader.setTopRanks(topRanks, selection: selection ?? { _ in })
        self.superview?.addSubview(inventedHeader)
        inventedHeader.anchors.top.pin(inset: 16+19)
        inventedHeader.anchors.leading.equal(self.anchors.leading)
        inventedHeader.anchors.width.equal(self.anchors.width)
        inventedHeader.anchors.height.equal(150)
    }
     
     func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header: DailyRankHeaderView = collectionView.dequeueReusableHeader(at: indexPath)
        header.setTopRanks(topRanks, selection: selection ?? { _ in })
        fixHeader()
        return header
    }
    
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cell(at: indexPath)?.select()
    }
}

//    MARK: -    UI
extension RankingCollectionView {
    func setupSuspensionView(){
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
            let suspensionView = UIView()
            suspensionView.backgroundColor = .white
            self.superview?.addSubview(suspensionView)
            self.contentInset.top = 16+19
             
            suspensionView.anchors.leading.equal(self.anchors.leading,constant: 16)
            suspensionView.anchors.width.equal(self.anchors.width-32)
            suspensionView.anchors.top.pin(inset: 16)
            suspensionView.anchors.height.equal(19)
            
            let topView = UIView()
            topView.backgroundColor = .white
            suspensionView.addSubview(topView)
            topView.anchors.top.pin(inset: -16)
            topView.anchors.edges.pin(axis:.horizontal)
            topView.anchors.height.equal(16)
            
            
            self.refreshCountdownLabel.text = "Next update: "
            self.refreshCountdownLabel.font = .roboto(.medium, size: 13)
            self.refreshCountdownLabel.textColor = .boulder
            self.refreshCountdownLabel.textAlignment = .center
            suspensionView.addSubview(self.refreshCountdownLabel)
            self.refreshCountdownLabel.anchors.leading.pin()
            self.refreshCountdownLabel.anchors.edges.pin(axis:.vertical)
             
            let rightView  = UIView()
            rightView.backgroundColor = UIColor.init(hexString: "#FDF5E7")
            rightView.layer.cornerRadius = 4
            suspensionView.addSubview(rightView)
            rightView.anchors.trailing.pin()
            rightView.anchors.edges.pin(axis:.vertical)
            
            let  historyLabel = UILabel()
            historyLabel.text = "Ranking history"
            historyLabel.textColor = UIColor.init(hexString: "#F7A541")
            historyLabel.font = .roboto(.medium, size: 10)
            rightView.addSubview(historyLabel)
            historyLabel.anchors.trailing.pin(inset: 7)
            historyLabel.anchors.centerY.align()
            
            let iconImageV = UIImageView()
            iconImageV.image = .iconRankingBadge
            rightView.addSubview(iconImageV)
            iconImageV.anchors.centerY.align()
            iconImageV.anchors.trailing.equal(historyLabel.anchors.leading, constant: -4.5)
            iconImageV.anchors.leading.pin()
        })

        
    }
    
   public func setupSuspensionBottomView(){ 
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
            self.superview?.addSubview(self.bottomView)
            self.contentInset.bottom = 76
            self.bottomView.backgroundColor = .white
            self.bottomView.anchors.leading.equal(self.anchors.leading)
            self.bottomView.anchors.width.equal(self.anchors.width)
            self.bottomView.anchors.bottom.pin()
            self.bottomView.anchors.height.equal(76)
            self.setupContent()
        }) 
    }
    
    func setupContent(){
        let lineLabel = UILabel()
        lineLabel.backgroundColor =  .softPeach
        bottomView.addSubview(lineLabel)
        lineLabel.anchor(top: bottomView.topAnchor,left:bottomView.leftAnchor,right:bottomView.rightAnchor)
        lineLabel.anchors.height.equal(1)
        
        configureRankLabel()
        configureUserImageView()
        
        let button = UIButton()
        button.setTitle("Send Gift")
        button.layer.cornerRadius = 4
        button.backgroundColor = UIColor(hexString: "#FD274A")
        button.titleLabel?.font = .roboto(.bold, size: 12)
        bottomView.addSubview(button)
        button.anchors.trailing.pin(inset: 16)
        button.anchors.centerY.align()
        button.anchors.width.equal(75)
        button.anchors.height.equal(28)
        button.onTap {
            self.sendGiftAction?()
        }
        
        let centerView = UIView()
        bottomView.addSubview(centerView)
        centerView.anchors.leading.equal(imageView.anchors.trailing,constant: 8)
        centerView.anchors.trailing.equal(button.anchors.leading,constant: -12)
        centerView.anchors.centerY.align()
        
        
        nameLabel.text = ownerInfo["name"] as? String //"name"
        nameLabel.font = .roboto(.medium, size: 14)
        nameLabel.textColor = .gravel
        centerView.addSubview(nameLabel)
        nameLabel.anchors.top.pin()
        nameLabel.anchors.leading.pin()
        nameLabel.anchors.trailing.lessThanOrEqual(centerView.anchors.trailing, constant: -14)
         
        verifiedIcon.image = .iconVerified
        verifiedIcon.contentMode = .scaleAspectFit
        
        centerView.addSubview(verifiedIcon)
        verifiedIcon.anchors.width.equal(14)
        verifiedIcon.anchors.height.equal(14)
        verifiedIcon.anchors.leading.equal(nameLabel.anchors.trailing)
        verifiedIcon.anchors.centerY.equal(nameLabel.anchors.centerY)
        verifiedIcon.isHidden = !(ownerInfo["isVerified"] as? Bool ?? false)
        
        descLabel.text = ""
        descLabel.textColor = .ashGrey
        descLabel.font = .roboto(.regular, size: 10)
        centerView.addSubview(descLabel)
        descLabel.anchors.leading.pin()
        descLabel.anchors.trailing.pin()
        descLabel.anchors.top.equal(nameLabel.anchors.bottom,constant: 4)
        descLabel.anchors.bottom.pin()
    }
    
    func configureRankLabel() {
        rankLabel.text = "99+"
        rankLabel.font = .roboto(.regular, size: 16)
        rankLabel.textColor = .ashGrey
        rankLabel.textAlignment = .left
        rankLabel.setContentHuggingPriority(.required, for: .horizontal)
        bottomView.addSubview(rankLabel)
        rankLabel.anchors.leading.pin(inset: 16)
        rankLabel.anchors.centerY.align()
        rankLabel.anchors.width.greaterThanOrEqual(20)
        rankLabel.anchors.width.lessThanOrEqual(28)
    }
    
    func configureUserImageView() {
        imageView.backgroundColor = .whiteSmoke
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        imageView.image = .defaultProfileImage
        imageView.layer.cornerRadius = 24
        imageView.contentMode = .scaleAspectFit
        let img = ownerInfo["photo"] as? String
        imageView.setImage(with: img , placeholder: .defaultProfileImage)
        
        bottomView.addSubview(imageView)
        imageView.anchors.centerY.align()
        imageView.anchors.leading.equal(rankLabel.anchors.trailing,constant: 12)
        imageView.anchors.width.equal(48)
        imageView.anchors.height.equal(48)
    }
       
}

// MARK: DataSource

extension RankingCollectionView {
    func makeDataSource() -> EmptyableDiffableDataSource<Int, CellController> {
        let dataSource: EmptyableDiffableDataSource<Int, CellController>  = .init(
            collectionView: self,
            cellProvider: { collectionView, indexPath, controller in
                controller.view(collectionView, forItemAt: indexPath)
            },
            emptyStateView: EmptyView(
                image: .illustrationTrophy,
                message: "Belum ada Daily Ranking yang bisa ditampilkan",
                horizontalInsets: 100
            )
        )
        dataSource.supplementaryViewProvider = collectionView
        return dataSource
    }
}

// MARK: Privates
extension RankingCollectionView {
    private func startCountdown() {
        countdownCancellable = CountDownTimer(duration: .secondsUntilMidnight, repeats: true)
            .handleEvents(receiveOutput: { [weak self] remaining in
                if remaining.totalSeconds < 0 {
                    self?.stopCountdown()
                    self?.startCountdown()
                }
            })
            .sink(receiveValue: { [weak self] remaining in
                self?.setCountdownText(remaining.outputText)
            })
    }
    
    private func stopCountdown() {
        countdownCancellable?.cancel()
        countdownCancellable = nil
    }
      
    func makeLayout() -> UICollectionViewCompositionalLayout {
        let section = NSCollectionLayoutSection.dailyRanking
        configureHeader(in: section)
        return .init(section: section)
    }
    
    func configureHeader(in section: NSCollectionLayoutSection) {
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(200)
            ),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
//        header.pinToVisibleBounds = true
        section.boundarySupplementaryItems = [header]
    }
    
    func setCountdownText(_ countdown: String) {
        let attributedString = NSMutableAttributedString(
            string: "Next update: ",
            attributes: [
                .font: UIFont.roboto(.medium, size: 13),
                .foregroundColor: UIColor.boulder
            ]
        )
        attributedString.append(.init(
            string: countdown,
            attributes: [
                .font: UIFont.roboto(.medium, size: 13),
                .foregroundColor: UIColor.black
            ]
        ))
        refreshCountdownLabel.attributedText = attributedString
    }
}

// MARK: API
extension RankingCollectionView {
    func setTopRanks(from viewModels: [LiveDailyRankViewModel]) {
        privateViewModels = viewModels
        
        var rankNum = -1
       let userId =  ownerInfo["userId"] as? String
        for (index,model) in privateViewModels.enumerated() {
            if userId == model.userId {
                rankNum = index + 1
            }
        }
        if rankNum == -1 {
            rankLabel.text = "99+"
        }else{
            rankLabel.text = "\(rankNum)"
        }
        
        
        topRanks = Array(viewModels.prefix(3))
        self.reloadData()
    }
    
    func setRegularRanks(from viewModels: [LiveDailyRankViewModel]) {
        let regularRanks = viewModels.dropFirst(3)
        let controllers = regularRanks.compactMap {
            return DailyRankCellController(
                viewModel: $0,
                selection: selection ?? { _ in }
            )
        }
        set(controllers)
        privateDataSource.emptyView?.isHidden = !viewModels.isEmpty && regularRanks.isEmpty
        self.reloadData()
    }
}
