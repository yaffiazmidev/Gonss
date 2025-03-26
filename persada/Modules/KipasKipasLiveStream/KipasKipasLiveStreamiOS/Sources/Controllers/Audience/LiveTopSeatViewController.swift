import UIKit
import KipasKipasTRTC
import KipasKipasLiveStream
import KipasKipasShared
import Combine

public final class LiveTopSeatViewController: UIViewController, UICollectionViewDelegate {
    private var cancellables: Set<AnyCancellable> = []
    private lazy var contentV = UIScrollView()
    private let bottomBtnsView = UIStackView()
     
    var seatId = ""
    var isAnchor = false
 
    var followAnimation : (() -> Void)?
    var followChange : ((Bool) -> Void)?
    private var imageV = UIImageView()
    private let nameL  = MarqueeLabel()
    private let desNameL  = UILabel()
    private let reportBtn = UIButton()
    private let followLabel = UILabel()
    private let natureLabel = UILabel()
    private let followBtn = UIButton()
    private var iconImageV = UIImageView()
    private var remindBtn = UIButton()
     
    private let  previewView = UIView()
            let loadingLabel = UILabel()
    
    lazy var loadingView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.color = .primary
        view.isHidden = true
        return view
    }()
 
    
    #warning("[BEKA] move this to a protocol or extension")
    private var panNavigation: (UIViewController & PanModalPresentable)? {
        return navigationController as? (UIViewController & PanModalPresentable)
    }
     
    private var profile:LiveUserProfile?

    var  onLoadSeatProfile: ((String) -> Void)?
    var onUserImageClicked: ((String) -> Void)?
    var onClickRemind: ((String) -> Void)?
    var onClickFollow: ((String) -> Void)?
    var onClickUnfollow: ((String) -> Void)?
    var onClickReport: (() -> Void)?
    
    private let seatProfileAdapter: SeatProfileAdapter
    
    init(
        seatProfileAdapter: SeatProfileAdapter
    ) { 
        self.seatProfileAdapter = seatProfileAdapter
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.seatProfileAdapter.loadProfile(seatId)
          
        navigationController?.setNavigationBarHidden(true, animated: false)
        panNavigation?.panModalSetNeedsLayoutUpdate()
        panNavigation?.panModalTransition(to: .longForm)
        
        updateUI()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
            self.configureLoadingView()
        })
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
       previewView.removeFromSuperview()
    }
    
    func updateUI(){
        remindBtn.isHidden = isAnchor
        setRankImgView()
        let loginId = UserDefaults.standard.string(forKey: "USER_LOGIN_ID")
        bottomBtnsView.isHidden = seatId == loginId
        nameL.text = "name"
        desNameL.text = "username"
        followLabel.text = "0 followers · 0 following"
        natureLabel.text = ""
        imageV.setImage(with: "", placeholder: .defaultProfileImage)
    }
  
}

// MARK: PanModal
extension LiveTopSeatViewController: PanModalPresentable {
    public var panScrollable: UIScrollView? {
        return contentV
    }
  
    public var longFormHeight: PanModalHeight {
        .contentHeight(310)
    }
    
    public var shortFormHeight: PanModalHeight {
        longFormHeight
    }
    
    public var panModalBackgroundColor: UIColor {
        .clear
    }
}

extension LiveTopSeatViewController: SeatProfileAdapterDelegate{
    func profileResult(_ result: Result<KipasKipasLiveStream.LiveUserProfile, Error>) {
        setLoading(false)
        switch result {
        case .failure:
            return toast()
            
        case let .success(profile):
            guard profile.id != nil else {
                return toast()
            }
            self.profile = profile
            updateUIWithProfile(profile)
        }
        func toast() {
            showToast(with: "User ID tidak ditemukan") { [weak self] in
                self?.dismiss(animated: true)
            }
        }

    }
    
    func updateUIWithProfile(_ profile:LiveUserProfile){
        imageV.setImage(with: profile.photo, placeholder: .defaultProfileImage)
        nameL.text = profile.name
        desNameL.text = profile.username
        followLabel.text = "\(profile.totalFollowers ?? 0) followers · \(profile.totalFollowing ?? 0) following"
        natureLabel.text =  profile.bio // "Self-discipline & positive"
        updateFollowBtn(profile.isFollow ?? false)
        
    }
    
    
    func updateFollowBtn(_ isFollowed: Bool){
        if isFollowed {
            followBtn.setImage(.iconFollowed, for: .normal)
            followBtn.setTitle(" Following", for: .normal)
            followBtn.setTitleColor(.gravel, for: .normal)
            followBtn.backgroundColor = .white
            followBtn.layer.borderWidth = 1
            followBtn.layer.borderColor = UIColor.softPeach.cgColor
            followBtn.isSelected = true
        }else{
            followBtn.setImage(.iconPlus, for: .normal)
            followBtn.setTitle(" Follow", for: .normal)
            followBtn.setTitleColor(.white, for: .normal)
            followBtn.backgroundColor = .watermelon
            followBtn.layer.borderWidth = 0
            followBtn.isSelected = false
        }
    }
     
}

extension LiveTopSeatViewController: ProfileFollowAdapterDelegate{
//    public func unfollowStatus(_ isFollowed: Bool) {
//        updateFollowBtn(isFollowed)
//    }
    
    public func requestFail() {
        setLoading(false)
    }
    
    public func followStatus(_ isFollowed: Bool){
        setLoading(false)
        updateFollowBtn(isFollowed)
        if isAnchor {
            followChange?(isFollowed)
        }
    } 
}

// loadingView 
private extension LiveTopSeatViewController {
    func setLoading(_ isLoading: Bool) {
        if isLoading {
            previewView.alpha = 0.5
            loadingView.startAnimating()
        } else {
            previewView.alpha = 0
            loadingView.stopAnimating()
        }
    }
    
    func configureLoadingView() {
        appWindow?.addSubview(previewView)
       previewView.backgroundColor = .contentGrey
       previewView.anchors.width.equal(140)
       previewView.anchors.height.equal(140)
       previewView.anchors.center.align()
       previewView.layer.cornerRadius = 24
       previewView.alpha = 0
       previewView.addSubview(loadingView)
        
        previewView.addSubview(loadingView)
        loadingView.anchors.center.align()
        loadingView.anchors.width.equal(32)
        loadingView.anchors.height.equal(32)
         
        loadingLabel.text = "loading"
        loadingLabel.textColor = .white
        previewView.addSubview(loadingLabel)
        loadingLabel.anchors.top.equal(loadingView.anchors.bottom,constant: 5)
        loadingLabel.anchors.centerX.align()
    }
}
  

// MARK: UI
private extension LiveTopSeatViewController {
    
    func configureUI() {
        contentV.backgroundColor = .white
        contentV.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 310)
        view.addSubview(contentV)
        contentV.anchors.edges.pin(insets: 16)
        contentV.anchors.width.equal(view.anchors.width)
          
        imageV.image = .defaultProfileImage
        imageV.layer.masksToBounds = true
        imageV.contentMode = .scaleAspectFit
        imageV.layer.cornerRadius = 63/2
        imageV.backgroundColor = .systemGray4
        contentV.addSubview(imageV)
        imageV.anchors.width.equal(63)
        imageV.anchors.height.equal(63)
        imageV.anchors.leading.pin()
        imageV.anchors.top.pin()
        imageV.onTap {
            self.onUserImageClicked?(self.seatId)
        }
         
        nameL.text = "  "
        nameL.font = .roboto(.bold, size: 24)
        nameL.textColor = .black
        nameL.type = .continuous
        nameL.textAlignment = .left
        nameL.speed = .rate(25)
        nameL.fadeLength = 15.0
        contentV.addSubview(nameL)
        nameL.anchors.leading.spacing(12, to: imageV.anchors.trailing)
        nameL.anchors.top.equal(imageV.anchors.top)
        
        
        desNameL.text = "  "
        desNameL.font = .roboto(.regular, size: 12)
        desNameL.textColor = .ashGrey
        contentV.addSubview(desNameL)
        desNameL.anchors.leading.equal(nameL.anchors.leading)
        desNameL.anchors.top.spacing(3, to: nameL.anchors.bottom)
        
   
        iconImageV.image = .iconTopOne
        contentV.addSubview(iconImageV)
        iconImageV.anchors.leading.equal(nameL.anchors.leading)
        iconImageV.anchors.top.spacing(3, to: desNameL.anchors.bottom)
         
        reportBtn.setCornerBorder(cornerRadius: 14)
        reportBtn.setBackgroundImage(.iconFlag, for: .normal)
        contentV.addSubview(reportBtn)
        reportBtn.anchors.width.equal(28)
        reportBtn.anchors.height.equal(28)
        reportBtn.anchors.top.equal(imageV.anchors.top)
//        reportBtn.anchors.trailing.spacing(50, to: contentV.anchors.trailing )
        reportBtn.anchors.trailing.equal(view.anchors.trailing,constant: -28)
        
        reportBtn.anchors.leading.equal(nameL.anchors.trailing,constant: 8)
        reportBtn.onTap {
            self.onClickReport?()
        }
        
         
        followLabel.text = "0 followers · 0 following"
        followLabel.textColor = .black
        followLabel.font = .roboto(.regular, size: 14)
        contentV.addSubview(followLabel)
        followLabel.anchors.top.equal(imageV.anchors.bottom, constant: 21)
         
         
        natureLabel.textColor = .ashGrey
        natureLabel.font = .roboto(.regular, size: 12)
        natureLabel.numberOfLines = 0
        contentV.addSubview(natureLabel)
        natureLabel.anchors.leading.pin()
        natureLabel.anchors.top.equal(followLabel.anchors.bottom, constant: 5)
        natureLabel.anchors.trailing.equal(view.anchors.trailing,constant: -16)
   
        let typeView = UIStackView()
        typeView.alignment = .bottom
        typeView.spacing = 8
        contentV.addSubview(typeView)
        typeView.anchors.top.spacing(21, to: natureLabel.anchors.bottom)
        typeView.anchors.height.equal(61)
        
        
        let leftBgView = UIView()
        leftBgView.backgroundColor = UIColor(hexString: "#F0EFFF")
        leftBgView.layer.cornerRadius = 8
        typeView.addArrangedSubview(leftBgView)
        leftBgView.anchors.width.equal(110)
        leftBgView.anchors.height.equal(46)
        
        let badgeImgView = UIImageView()
        badgeImgView.image = .iconBadge
        leftBgView.addSubview(badgeImgView)
        badgeImgView.anchors.centerY.equal(leftBgView.anchors.top)
        badgeImgView.anchors.leading.equal(leftBgView.anchors.leading,constant: 12)
        
        let levelLabel = UILabel()
        levelLabel.text = "Lv. 15"
        levelLabel.font = .roboto(.medium, size: 12)
        levelLabel.textColor = UIColor(hexString: "#595DFE")
        leftBgView.addSubview(levelLabel)
        levelLabel.anchors.centerX.equal(badgeImgView.anchors.centerX)
        levelLabel.anchors.top.equal(badgeImgView.anchors.bottom,constant: 8)
        
        
        let rightBgView = UIView()
        rightBgView.backgroundColor = UIColor(hexString: "#EFF0F8")
        rightBgView.layer.cornerRadius = 8
        typeView.addArrangedSubview(rightBgView)
        rightBgView.anchors.width.equal(leftBgView.anchors.width)
        rightBgView.anchors.height.equal(leftBgView.anchors.height)
        
        let memberImgView = UIImageView()
        memberImgView.image = .iconMember
        rightBgView.addSubview(memberImgView)
        memberImgView.anchors.centerY.equal(rightBgView.anchors.top)
        memberImgView.anchors.leading.equal(rightBgView.anchors.leading,constant: 12)
        
        let memberLabel = UILabel()
        memberLabel.text = "Member"
        memberLabel.font = .roboto(.medium, size: 12)
        memberLabel.textColor = .boulder
        rightBgView.addSubview(memberLabel)
        memberLabel.anchors.centerX.equal(memberImgView.anchors.centerX)
        memberLabel.anchors.top.equal(memberImgView.anchors.bottom,constant: 8)
         
        bottomBtnsView.spacing = 8
        contentV.addSubview(bottomBtnsView)
        bottomBtnsView.anchors.leading.equal(view.anchors.leading,constant: 16)
        bottomBtnsView.anchors.trailing.equal(view.anchors.trailing,constant: -16)
        bottomBtnsView.anchors.top.spacing(21, to: typeView.anchors.bottom)
        bottomBtnsView.anchors.height.equal(40)
          
        remindBtn.setBackgroundImage(.btnDefault, for: .normal)
        bottomBtnsView.addArrangedSubview(remindBtn)
        remindBtn.anchors.height.equal(40)
        remindBtn.anchors.width.equal(46)
        remindBtn.onTap {
            let str = "@\(self.profile?.name ?? "") "
            self.onClickRemind?(str) 
        }
           
        followBtn.setTitle(" Follow", for: .normal)
        followBtn.backgroundColor = .watermelon
        followBtn.layer.cornerRadius = 8
        followBtn.titleLabel?.font = .roboto(.medium, size: 14)
        followBtn.setTitleColor(.white, for: .normal)
        followBtn.setImage(.iconPlus, for: .normal)
        bottomBtnsView.addArrangedSubview(followBtn)
        
        followBtn.onTap { 
            
            if(!self.followBtn.isSelected){
                self.setLoading(true)
                if self.isAnchor {
                    self.followAnimation?()
                }
                self.onClickFollow?(self.seatId)
            }else{
                let alertController = UIAlertController(title: "Unfollow \(self.profile?.name ?? "")?", message: "", preferredStyle: .actionSheet)
                let sureAction = UIAlertAction(title: "Unfollow", style: .default) { (action) in
                    self.setLoading(true)
                    self.onClickUnfollow?(self.seatId)
                    if self.isAnchor {
                        self.followAnimation?()
                    }
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                alertController.addAction(sureAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func setRankImgView(){
        let topSeats:[Any] =  KKCache.common.readArray(key: .topSeatsCache) ?? [""]
        iconImageV.image = UIImage(named: "")
        for (index,topSeat) in topSeats.enumerated(){
            let str:String = topSeat as! String
            if (str == seatId){
                switch index {
                case 0:
                    iconImageV.image = .iconTopOne
                case 1:
                    iconImageV.image = .iconTopTwo
                case 2:
                    iconImageV.image = .iconTopThree
                default:
                    iconImageV.image = UIImage(named: "")
                }
            }
        }
    }
}
 
