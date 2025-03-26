import UIKit
import Combine
import KipasKipasShared
import KipasKipasLiveStream

final class LiveDailyRankingViewController: UIViewController, PanModalPresentable {
     
    private let leftCollectionView = RankingCollectionView(frame:.zero, collectionViewLayout: .init())
    private let rightCollectionView = RankingCollectionView(frame:.zero, collectionViewLayout: .init())
    
    var leftViewModels: [LiveDailyRankViewModel] = []
    var rightViewModels: [LiveDailyRankViewModel] = []
    
    private let dummyNavBar = FakeNavBar()
    
    private let contentView=UIScrollView(frame: .zero)
    private let selectNavBar = UIView()
    private let navBgImageView = UIImageView()
    private let leftNavTitleLabel = UILabel()
    private let rightNavTitleLabel = UILabel()
    
    var isAnchor = false
    var liveRoomInfo: LiveRoomInfoViewModel?
    var selectNavLeft = true {
        didSet {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: { [weak self] in
            self?.updateNavUI()
        })
        }
    }
    private var lineLeftConstraint: NSLayoutConstraint! {
        didSet {
            lineLeftConstraint.isActive = true
//            view.updateConstraints()
        }
    }
      
    var onLoadDailyRank: (() -> Void)?
    var onLoadPopularLive: (() -> Void)?
    var selection: ((String) -> Void)?
    var sendGiftAction: (() -> Void)?
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        onLoadDailyRank?()
        onLoadPopularLive?()
    }
      
    var panScrollable: UIScrollView? {
        return selectNavLeft ? leftCollectionView : rightCollectionView
    }
    
    public var longFormHeight: PanModalHeight {
        return .contentHeight(550)
    }
    
     var shortFormHeight: PanModalHeight {
        return longFormHeight
    }
    
    var anchorModalToLongForm: Bool {
        return true
    }
    
    var allowsExtendedPanScrolling: Bool {
        return true
    }
}

extension LiveDailyRankingViewController : UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == contentView else { return }
        let offsetX = scrollView.contentOffset.x
        let scrollWidth = view.frame.width/2 + 10 - 24
        lineLeftConstraint.constant =  offsetX/view.frame.width * scrollWidth  + 24
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == contentView else { return }
        let offsetX = scrollView.contentOffset.x
        if offsetX >= view.frame.width * 0.8 {
            self.selectNavLeft = false
        }else if offsetX <= view.frame.width * 0.2 {
            self.selectNavLeft = true
        }
        
    }
    
}

// MARK: UI
private extension LiveDailyRankingViewController {
    func configureUI() {
        configureSelectNavBar()
        configureCotentView()
    }
    
    func configureCotentView() {  
        contentView.showsHorizontalScrollIndicator = false
        view.addSubview(contentView)
        contentView.anchors.top.spacing(0, to: selectNavBar.anchors.bottom)
        contentView.anchors.edges.pin(axis: .horizontal)
        contentView.anchors.bottom.pin(inset: view.safeAreaBottom)
        contentView.delegate = self
        contentView.isPagingEnabled = true
        
          
        let hlabel = UILabel()
        contentView.addSubview(hlabel)
        hlabel.anchors.edges.pin()
        hlabel.anchors.height.equal(contentView.anchors.height)
          
        //left
        contentView.addSubview(leftCollectionView)
        leftCollectionView.anchors.top.pin()
        leftCollectionView.anchors.leading.pin()
        leftCollectionView.anchors.bottom.pin()
        leftCollectionView.anchors.width.equal(view.frame.width)
        leftCollectionView.sendGiftAction = sendGiftAction
//        leftCollectionView.selection = selection
         
        //right
        contentView.addSubview(rightCollectionView)
        rightCollectionView.anchors.top.pin()
        rightCollectionView.anchors.leading.equal(leftCollectionView.anchors.trailing)
        rightCollectionView.anchors.trailing.pin()
        rightCollectionView.anchors.bottom.pin()
        rightCollectionView.anchors.width.equal(view.frame.width)
        rightCollectionView.sendGiftAction = sendGiftAction
//        rightCollectionView.selection = selection
        
        if !isAnchor {
            leftCollectionView.setupSuspensionBottomView()
            rightCollectionView.setupSuspensionBottomView()
        }
    }
     
    
    func configureDummyNavbar() {
        dummyNavBar.titleLabel.text = "Daily Ranking"
        dummyNavBar.titleLabel.font = .roboto(.bold, size: 18)
        dummyNavBar.titleLabel.textColor = .black
        dummyNavBar.height = 70
        dummyNavBar.backgroundImage = .backgroundDailyRankHeader
        
        view.addSubview(dummyNavBar)
    }
    
    func configureSelectNavBar(){
        view.addSubview(selectNavBar)
        selectNavBar.anchors.leading.pin()
        selectNavBar.anchors.top.pin()
        selectNavBar.anchors.trailing.pin()
        selectNavBar.anchors.height.equal(56)
    
        navBgImageView.image = .navBgDaily
        selectNavBar.addSubview(navBgImageView)
        navBgImageView.anchors.edges.pin()
        
        
        selectNavBar.addSubview(leftNavTitleLabel)
        leftNavTitleLabel.anchors.leading.pin()
        leftNavTitleLabel.anchors.top.pin()
        leftNavTitleLabel.anchors.bottom.pin()
        leftNavTitleLabel.anchors.trailing.equal(selectNavBar.anchors.centerX)
        leftNavTitleLabel.text = "Daily Ranking"
        leftNavTitleLabel.textColor = .black
        leftNavTitleLabel.font = .roboto(.bold, size: 14)
        leftNavTitleLabel.textAlignment = .center
         
        
        selectNavBar.addSubview(rightNavTitleLabel)
        rightNavTitleLabel.anchors.trailing.pin()
        rightNavTitleLabel.anchors.top.pin()
        rightNavTitleLabel.anchors.bottom.pin()
        rightNavTitleLabel.anchors.leading.equal(selectNavBar.anchors.centerX)
        rightNavTitleLabel.text = "Popular LIVE"
        rightNavTitleLabel.textColor = .ashGrey
        rightNavTitleLabel.font = .roboto(.bold, size: 14)
        rightNavTitleLabel.textAlignment = .center
        
        
        let navLineViw = UIView()
        navLineViw.backgroundColor = .black
        selectNavBar.addSubview(navLineViw)
        let w = (view.frame.width-20-24-24)/2
        navLineViw.anchors.width.equal(w)
        navLineViw.anchors.height.equal(2)
        navLineViw.anchors.bottom.pin(inset: 2)
        lineLeftConstraint = navLineViw.anchors.leading.pin(inset: 24)
        
        
        
        leftNavTitleLabel.onTap { [weak self] in
            self?.selectNavLeft = true
        }
        
        rightNavTitleLabel.onTap { [weak self] in
            self?.selectNavLeft = false
        }
    }
    
    
    func updateNavUI(){
        if self.selectNavLeft  {
            self.navBgImageView.image = .navBgDaily
            self.lineLeftConstraint.constant = 24
            self.contentView.contentOffset = CGPoint(x: 0, y: 0)
            self.leftNavTitleLabel.textColor = .black
            self.rightNavTitleLabel.textColor = .ashGrey
        }else{
            self.navBgImageView.image = .navBgLive
            self.lineLeftConstraint.constant =  (self.view.frame.width )/2 + 10
            self.contentView.contentOffset = CGPoint(x: Double(self.view.frame.width), y: 0)
            self.rightCollectionView.reloadData()
            self.leftNavTitleLabel.textColor = .ashGrey
            self.rightNavTitleLabel.textColor = .black
        }
    }
    
}
 
 
// MARK: API
extension LiveDailyRankingViewController {
    func setTopRanks(from viewModels: [LiveDailyRankViewModel]) { 
        leftViewModels = viewModels
        leftCollectionView.selection = { userId in
            self.selection?(userId)
        }
        leftCollectionView.setTopRanks(from: viewModels)
    }
    
    func setRegularRanks(from viewModels: [LiveDailyRankViewModel]) {
        
        leftCollectionView.setRegularRanks(from: viewModels)
    }
    
    func setPopularTopRanks(from viewModels: [LiveDailyRankViewModel]) {
        rightViewModels = viewModels
        rightCollectionView.selection = { userId in
            self.selection?(userId)
        }
        rightCollectionView.setTopRanks(from: viewModels)
    }
    
    func setPopularRegularRanks(from viewModels: [LiveDailyRankViewModel]) {
        rightCollectionView.setRegularRanks(from: viewModels)
    }
    
}

  
