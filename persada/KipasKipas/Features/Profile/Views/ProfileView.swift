//
//  ProfileView.swift
//  KipasKipasProfileUI
//
//  Created by DENAZMI on 22/12/23.
//

import UIKit
import FeedCleeps
import KipasKipasShared

enum ProfileTabMenu {
    case post
    case showcase
}

protocol ProfileViewDelegate: AnyObject {
    func handleLoadMore()
    func handleTapSetting()
    func didClickShopButton(user: RemoteUserProfileData?)
    func didRefreshPage()
    func didTapProfilePicture(with image: UIImage?)
    func didClickVisitor()
    func didClickAddYours()
    func didClickTotalLikes()
    func didClickShare()
    func didClickTotalFollower()
    func didClickTotalFollowing()
    func didClickDirectMessage()
    func didClickYourOrders()
}

public class ProfileView: UIView {
    
    @IBOutlet weak var badgedProfileImageView: BadgedProfileImageView!
    @IBOutlet weak var bioLabel: ActiveLabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var menuContainerView: UIView!
    @IBOutlet weak var totalFollowerLabel: UILabel!
    @IBOutlet weak var totalFollowingLabel: UILabel!
    @IBOutlet weak var totalLikesLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var verifiedIconImageView: UIImageView!
    @IBOutlet weak var followContainerStackView: UIStackView!
    @IBOutlet weak var headerContainerStackView: UIStackView!
    @IBOutlet weak var myShopContainerStackView: UIStackView!
    @IBOutlet weak var messageContainerStackView: UIStackView!
    @IBOutlet weak var recomUserContainerStackView: UIStackView!
    @IBOutlet weak var addFriendContainerStackView: UIStackView!
    @IBOutlet weak var tabMenuSlideIndicatorX: NSLayoutConstraint!
    @IBOutlet weak var editProfileContainerStackView: UIStackView!
    @IBOutlet weak var alreadyFollowContainerStackView: UIStackView!
    
    @IBOutlet weak var followIconImage: UIImageView!
    @IBOutlet weak var tabMenuSlideIndicatorWidth: NSLayoutConstraint!
    @IBOutlet weak var menuContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tabMenuShowcaseButton: UIButton!
    @IBOutlet weak var bioContainerStackView: UIStackView!
    @IBOutlet weak var postGridButton: UIButton!
    @IBOutlet weak var sendMessageIconImageView: UIImageView!
    @IBOutlet weak var showcaseButtonContainerStackView: UIStackView!
    @IBOutlet weak var yourOrdersButtonContainerStackView: UIStackView!
    @IBOutlet weak var addYoursContainerStackView: UIStackView!
    @IBOutlet weak var likesContainerStackView: UIStackView!
    @IBOutlet weak var followersContainerStackView: UIStackView!
    @IBOutlet weak var followingContainerStackView: UIStackView!
    @IBOutlet weak var badgeImageView: UIImageView!
    @IBOutlet weak var levelBadgeLabel: UILabel!
    @IBOutlet weak var badgeStackView: UIStackView!
    @IBOutlet weak var contentContainerStackView: UIStackView!
    @IBOutlet weak var addYoursStackView: UIStackView!
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = .roboto(.bold, size: 18)
        return label
    }()
    
    lazy var settingButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "iconMenuProfile"))
                button.contentMode = .center
        button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.addTarget(self, action: #selector(handleDidTapSettingButton), for: .touchUpInside)
        return button
    }()
    
    lazy var visitorsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "iconStepOutline"))
                button.contentMode = .center
        button.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.addTarget(self, action: #selector(didClickVisitorButton), for: .touchUpInside)
        return button
    }()
    
    lazy var notifButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_notif_outline_black"))
                button.contentMode = .center
        button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.isHidden = true // hide, remove if need to show again!
//        button.addTarget(self, action: #selector(handleDidTapSettingButton), for: .touchUpInside)
        return button
    }()
    
    lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_share_outline_black"))
                button.contentMode = .center
        button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.addTarget(self, action: #selector(didClickShareButton), for: .touchUpInside)
        return button
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.tintColor = .primary
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refresh
    }()
    
    weak var delegate: ProfileViewDelegate?
    
    var previousTap: Int = 0
    var viewControllerList: [UIViewController] = []
    var lastContentOffset = CGPoint(x: 0, y: 0)
    let pageViewController = UIPageViewController(transitionStyle: .scroll, 
                                                  navigationOrientation: .horizontal, options: nil)
    var userId: String = ""
    
    var selectedTabMenu: ProfileTabMenu = .post {
        didSet {
            updateSlideMenuIndicatorLocation(tab: selectedTabMenu)
        }
    }
    
    var posts: [RemoteFeedItemContent] = [] {
        didSet {
            updatePagesHeight()
        }
    }
    
    var products: [ShopViewModel] = [] {
        didSet {
            updatePagesHeight()
        }
    }
    
    var user: RemoteUserProfileData? {
        didSet {
            setupHeader(user: user)
            refreshControl.endRefreshing()
        }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        scrollView.refreshControl = refreshControl
        scrollView.delegate = self
        
        verifiedIconImageView.isHidden = true
        levelBadgeLabel.isHidden = true

        myShopContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didClickShopButton(user: self.user)
        }
        
        badgedProfileImageView.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didTapProfilePicture(with: self.badgedProfileImageView.userImage)
        }
        
//        profileImageView.onTap { [weak self] in
//            guard let self = self else { return }
//            self.delegate?.didTapProfilePicture(with: self.profileImageView.image)
//        }
        
        addYoursContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didClickAddYours()
        }
        
        likesContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didClickTotalLikes()
        }
        
        followingContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didClickTotalFollowing()
        }
        
        followersContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didClickTotalFollower()
        }
        
        messageContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didClickDirectMessage()
        }
        
        yourOrdersButtonContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didClickYourOrders()
        }
    }
    
    private func setupHeader(user: RemoteUserProfileData?) {
        guard let user = user else { return }
        verifiedIconImageView.isHidden = true
        levelBadgeLabel.isHidden = true
        
        let itSelf = user.id == getIdUser()
        let isFollow = user.isFollow == true
        showcaseButtonContainerStackView.isHidden = itSelf
        yourOrdersButtonContainerStackView.isHidden = !itSelf
        sendMessageIconImageView.isHidden = !isFollow
        followContainerStackView.isHidden = isFollow ? true : itSelf
        alreadyFollowContainerStackView.isHidden = itSelf ? true : !isFollow
        messageContainerStackView.isHidden = itSelf
        editProfileContainerStackView.isHidden = !itSelf
        myShopContainerStackView.isHidden = !itSelf
        addFriendContainerStackView.isHidden = true /*!itSelf*/
        recomUserContainerStackView.isHidden = true /*itSelf*/
        badgeStackView.isHidden = !(user.donationBadge?.isShowBadge ?? false)
        
        usernameLabel.text = "@\(user.username ?? "")"
        bioLabel.text = user.bio ?? ""
        bioContainerStackView.isHidden = user.bio?.isEmpty == true
        totalFollowerLabel.text = user.totalFollowers?.formatViews()
        totalFollowingLabel.text = user.totalFollowing?.formatViews()
        totalLikesLabel.text = user.totalFeedLikes?.formatViews()
        verifiedIconImageView.isHidden = user.isVerified == false
        // profileImageView.load(at: user?.photo ?? "", placeholder: .defaultProfileImageLargeCircle)
        
        //badgedProfileImageView.userImageView.load(at: user?.photo ?? "", placeholder: .defaultProfileImageLargeCircle)
        badgedProfileImageView.userImageView.loadImage(at: user.photo ?? "", .w360, emptyImageName: "iconProfilePlaceholder" )
        badgedProfileImageView.rank = user.donationBadge?.globalRank ?? 0
        badgedProfileImageView.hideRibbon = user.donationBadge?.isShowBadge == false
        
        badgeImageView.load(at: user.donationBadge?.url ?? "" , placeholder: nil)
        levelBadgeLabel.text = "\(user.donationBadge?.level ?? 0)"
    }
    
    func rightBarButtonItems() -> [UIBarButtonItem] {
        let itSelf = userId == getIdUser()
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = 24
        return [
            UIBarButtonItem(customView: itSelf ? settingButton : shareButton),
            space,
            UIBarButtonItem(customView: itSelf ? visitorsButton : notifButton)
        ]
    }
    
    public func calculateRowHeight(numberOfData: Int, dataPerRow: Int, rowHeight: CGFloat) -> CGFloat {
        let totalRows = CGFloat(ceil(Double(numberOfData) / Double(dataPerRow))) // Round up to whole rows
        let totalHeight = totalRows * rowHeight
        return totalHeight + totalRows
    }
    
    private func updateSlideMenuIndicatorLocation(tab: ProfileTabMenu) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                self.postGridButton.tintColor = tab == .post ? .black : .grey
                self.tabMenuShowcaseButton.tintColor = tab == .showcase ? .black : .grey
                
                if tab == .post {
                    self.tabMenuSlideIndicatorX.constant = (UIScreen.main.bounds.width / 4) - (self.tabMenuSlideIndicatorWidth.constant / 2)
                } else {
                    let centerRightPointIndicator = (UIScreen.main.bounds.width / 4) - (self.tabMenuSlideIndicatorWidth.constant / 2)
                    self.tabMenuSlideIndicatorX.constant = (UIScreen.main.bounds.width / 2) + centerRightPointIndicator
                }
                self.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func didClickTabMenuPostButton(_ sender: Any) {
        selectedTabMenu = .post
        pageViewController.setViewControllers([viewControllerList[0]], direction: previousTap > 0 ? .reverse : .forward, animated: true, completion: nil)
        previousTap = 0
        updateSlideMenuIndicatorLocation(tab: .post)
        updatePagesHeight()
    }
    
    @IBAction func didClickTabMenuShowcaseButton(_ sender: Any) {
        selectedTabMenu = .showcase
        pageViewController.setViewControllers([viewControllerList[1]], direction: previousTap > 1 ? .reverse : .forward, animated: true, completion: nil)
        previousTap = 1
        updateSlideMenuIndicatorLocation(tab: .showcase)
        updatePagesHeight()
    }
    
    @objc private func handleDidTapSettingButton() {
        delegate?.handleTapSetting()
    }
    
    @objc private func handleRefresh() {
        refreshControl.beginRefreshing()
        delegate?.didRefreshPage()
    }
    
    @objc private func didClickVisitorButton() {
        delegate?.didClickVisitor()
    }
    
    @objc private func didClickShareButton() {
        delegate?.didClickShare()
    }
}

extension ProfileView: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = viewControllerList.firstIndex(of: viewController) else { return nil }
        let previousIndex = vcIndex - 1
        guard previousIndex >= 0 else { return nil }
        guard viewControllerList.count > previousIndex else { return nil }
        return viewControllerList[previousIndex]
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = viewControllerList.firstIndex(of: viewController) else { return nil }
        let nextIndex = vcIndex + 1
        guard viewControllerList.count != nextIndex else { return nil }
        guard viewControllerList.count > nextIndex else { return nil }
        return viewControllerList[nextIndex]
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard completed else { return }
        guard let currentViewController = pageViewController.viewControllers?.first else { return }
        guard let index = viewControllerList.firstIndex(of: currentViewController) else { return }
        
        selectedTabMenu = index == 0 ? .post : .showcase
        
        DispatchQueue.main.async {
            self.updatePagesHeight()
            
            let point = self.headerContainerStackView.frame
            guard self.lastContentOffset.y > point.height else { return }
            self.scrollView.setContentOffset(CGPoint(x: point.origin.x, y: point.height), animated: false)
        }
    }
    
    func getProductHeight(by item: ShopViewModel) -> CGFloat {
        let heightImage = item.metadataHeight ?? 1028
        let widthImage = item.metadataWidth ?? 1028
        let width = scrollView.frame.size.width - 4
        let scaler = width / widthImage
        guard let index = products.firstIndex(where: { $0.id == item.id }) else { return 0.0 }
        let percent = Double((10 - ((index % 3) + 1))) / 10
        var height = heightImage * scaler
        if height > 500 {
            height = 500
        }
        height = (height * percent) + 200
        return height
    }
}

extension ProfileView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0.0 {
            lastContentOffset = scrollView.contentOffset
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let frameHeight = scrollView.frame.size.height
            
            if offsetY > (contentHeight - frameHeight - 40) {
                print("Load more")
                delegate?.handleLoadMore()
            }
        }
    }
}

// MARK: - Handler for Update Height
private extension ProfileView {
    func emptyHeight() -> CGFloat {
        return UIScreen.main.bounds.height - headerContainerStackView.frame.height // Perlu di update
    }
    
    private func updatePagesHeight() {
        switch selectedTabMenu {
        case .post:
            let postTabMenuHeight = calculateRowHeight(numberOfData: posts.count, dataPerRow: 3, rowHeight: 185)
            menuContainerHeightConstraint.constant = posts.isEmpty ? emptyHeight() : postTabMenuHeight
            layoutIfNeeded()
            
        case .showcase:
            let productGenap = products.enumerated().filter({ $0.offset % 2 == 0 }).map({ $0.element })
            let productGanjil = products.enumerated().filter({ $0.offset % 2 == 1 }).map({ $0.element })
            
            let productGenapTotalHeight = productGenap.compactMap({ getProductHeight(by: $0) })
            let productGenapHeight = CGFloat(Int(productGenapTotalHeight.reduce(0, +))) / 2
            
            let productGanjilTotalHeight = productGanjil.compactMap({ getProductHeight(by: $0) })
            let productGanjilHeight = CGFloat(Int(productGanjilTotalHeight.reduce(0, +))) / 2
            
            let finalHight = productGenapHeight >= productGanjilHeight ? productGenapHeight : productGanjilHeight
            
            menuContainerHeightConstraint.constant = products.isEmpty ? emptyHeight() : finalHight
            layoutIfNeeded()
        }
    }
}
