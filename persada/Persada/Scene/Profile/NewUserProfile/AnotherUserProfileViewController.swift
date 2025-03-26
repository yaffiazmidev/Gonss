//
//  AnotherUserProfileViewController.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 17/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import FeedCleeps
import KipasKipasDirectMessage
import KipasKipasDirectMessageUI
import KipasKipasShared

class AnotherUserProfileViewController: UIViewController, Displayable, NewUserProfileDisplayLogic, NewUserProfileDelegate, AlertDisplayer {
		func updatePage(value: Int) {
				interactor.dataSource.page = value
		}

		
		let mainView: AnotherUserProfileView
		private var presenter: NewUserProfilePresenter!
		private var interactor: NewUserProfileInteractable!
		private var router: NewUserProfileRouting!
		private let disposeBag = DisposeBag()
	var headerView: AnotherUserProfileHeaderView?
	private let hud = CPKProgressHUD.progressHUD(style: .loading(text: nil))
    private let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)

    private var blockedUserStore = KeychainBlockedUserStore()
		
		var actionDismiss : () -> () = {}
    
    var feeds: [Feed] = []
    var callbackUpdateFollowStatus: ((Bool) -> Void)?
    
    var username: String? {
        didSet {
            if let username = username {
                getUserID(with: username) { id in
                    self.setProfile(id: id, type: "user")
                    self.refresh()
                }
            }
        }
    }
    var fromHome: Bool = false
    var timestampStorage: TimestampStorage = TimestampStorage()
    var account: Profile?
    
    required init(mainView: AnotherUserProfileView, dataSource: NewUserProfileModel.DataSource) {
        self.mainView = mainView
        super.init(nibName: nil, bundle: nil)
        interactor = NewUserProfileInteractor(viewController: self, dataSource: dataSource)
        router = NewUserProfileRouter(self)
        presenter = NewUserProfilePresenter(self)
        self.presenter.identifier = "PROFILE_OTHER"
        self.presenter.lastPrepareIndex = 0
        self.setupItems()
    }
    

    private func getUserID(with username: String, completion: @escaping (String) -> Void) {
        let usecase = Injection.init().provideProfileUseCase()
 
        
        usecase.getNetworkProfile(username: username)
            .subscribeOn(self.concurrentBackground)
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] result in
                guard self != nil else { return }
                let data = result.data
                guard let id = data?.id else { return }
                completion(id)
            } onError: { err in
                
            }.disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        let coloredAppearance = UINavigationBarAppearance()
//        coloredAppearance.configureWithOpaqueBackground()
//        coloredAppearance.backgroundColor = .clear
//        navigationController?.navigationBar.standardAppearance = coloredAppearance
//        navigationController?.navigationBar.scrollEdgeAppearance = coloredAppearance
//        navigationController?.navigationBar.backgroundColor = .white
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
        self.mainView.collectionView.reloadData()
	}
		
		override func viewDidLoad() {
				super.viewDidLoad()
            refresh()
			self.mainView.collectionView.delegate = self
			self.mainView.collectionView.dataSource = self
            
            NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateIsFollowFromFolowingFolower(_:)), name: .updateIsFollowFromFolowingFolower, object: nil)

				presenter.errorMessage.asObservable().bind { error in
						if let err = error {
								self.showToast(message: err)
                            self.mainView.refreshControl.endRefreshing()
						}
				}.disposed(by: disposeBag)
            
            presenter.loadingState.drive(onNext: { [weak self] isLoading in
                if isLoading {
                    guard let view = self?.view else { return }
                    self?.hud.show(in: view)
                    return
                } else {
                    self?.hud.dismiss()
                }
            }).disposed(by: disposeBag)

				createRedDotObserver()
		}
		
		func createRedDotObserver(){
            NotificationCenter.default.addObserver(self, selector: #selector(updateRedDot(notification:)), name: .notificationUpdateEmail, object: nil)
			 }
			 
			 @objc
			 func updateRedDot(notification : NSNotification){
					 displayReddot()
			 }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleUpdateIsFollowFromFolowingFolower(_ notification: Notification) {
        guard let object = notification.userInfo as? [String: Any] else { return }
        
//        for (index, element) in feeds.enumerated() {
//            if let accountId = object["accountId"] as? String, accountId == element.account?.id {
//                feeds[index].isFollow = object["isFollow"] as? Bool
//                feeds[index].account?.isFollow = object["isFollow"] as? Bool
//                KKFeedFollow.instance.add(feedId: feeds[index].id ?? "", isFollow: feeds[index].account?.isFollow ?? false)
//            }
//        }
        refresh()
    }

    func displayReddot(){
        self.headerView?.redDot.isHidden = !getEmail().isEmpty
    }

		
		override func loadView() {
				view = mainView
				mainView.delegate = self
				view.backgroundColor = .white
		}
		
		@available(*, unavailable)
		required init?(coder: NSCoder) {
				fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
		}
		
		
		// MARK: - NewUserProfileDisplayLogic
		func displayViewModel(_ viewModel: NewUserProfileModel.ViewModel) {
            switch viewModel {
                
            case .totalPost(let viewModel) :
                self.displayTotalPost(viewModel)
                
            case .profile(let viewModel):
                self.displayProfileHeader(viewModel)
                
            case .totalFollower(let viewModel):
                self.displayFollower(viewModel)
                
            case .totalFollowing(let viewModel):
                self.displayFollowing(viewModel)
                
            case .profilePosts(let viewModel):
                self.displayProfilePosts(viewModel)
                
            case .paginationPosts(let viewModel):
                self.displayPaginationPosts(viewModel)
            case .pictureUploaded(viewModel: let viewModel):
                break
            case let .pictureUpdated(viewModel): break
            case .error(let message):
                self.displayError(message)
            }
		}
    
        func setupItems() {
            self.presenter
                .feedAlreadyShow
                .subscribeOn(self.concurrentBackground)
                .observeOn(MainScheduler.instance)
                .bind { [weak self] feeds in
                    self?.mainView.refreshControl.endRefreshing()
                    self?.addUniqueFeeds(feeds: feeds)
                }.disposed(by: disposeBag)
        }
    
    private func addUniqueFeeds(feeds: [Feed]) {
        if presenter.requestedPage <= 0 {
            self.feeds = []
            self.presenter.prefetchImages(feeds)
            self.displayViewModel(.paginationPosts(viewModel: feeds))
        } else {
            let uniqueFeed = feeds.filter { feed in
                !self.feeds.contains(feed)
            }
            self.presenter.prefetchImages(uniqueFeed)
            self.displayViewModel(.paginationPosts(viewModel: uniqueFeed))
        }
    }
}


// MARK: - NewUserProfileViewDelegate
extension AnotherUserProfileViewController: UserProfileHeaderDelegate ,NewUserProfileViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIGestureRecognizerDelegate {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let items = feeds.filter{ $0.isReported == false }
        return items.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AnotherUserProfileView.ViewTrait.cellId, for: indexPath) as! NewUserProfileItemCell
		let row = indexPath.row
        let items = feeds.filter{ $0.isReported == false }
        if(items.count > row) {
            cell.item = items[row].mapToProfileContent()
            cell.decideIcon(feed: items[row])            
        }
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let tempHeaderView = self.headerView {
            return tempHeaderView
        }
		headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: AnotherUserProfileView.ViewTrait.headerId, for: indexPath) as? AnotherUserProfileHeaderView
        
        headerView?.followButton.rx.tap
            .throttle(DispatchTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .bind { [weak self] in
                guard let self = self else { return }
                
                self.headerView?.handleFollowButton()
                if !self.fromHome {
                    let data: [String : Any] = [
                        "accountId" : self.headerView?.item?.id ?? "",
                        "isFollow": self.headerView?.isFollowing ?? false,
                        "name": self.headerView?.item?.name ?? "",
                        "photo": self.headerView?.item?.photo ?? ""
                    ]
                    NotificationCenter.default.post(name: .updateIsFollowFromFolowingFolower, object: nil, userInfo: data)
                } else {
                    self.callbackUpdateFollowStatus?(self.headerView?.isFollowing ?? false)
                }
            }.disposed(by: disposeBag)
        
        presenter.counterProfile.drive { count in
                if let counts = count {
                    self.headerView?.setupCount(count: counts)
                }
        }.disposed(by: disposeBag)
		
		guard let isEnableButtonFollow = self.headerView?.followButton.rx.isEnabled else {
			return headerView!
		}
		
		headerView?.delegate = self
		
		self.presenter.account.drive(onNext: { profile in
			guard let profile = profile else { return }
            self.account = profile
            self.setupSocialMedia(profile)
		}).disposed(by: disposeBag)
		
        headerView?.changeReportAndBlock = { [weak self] in
            guard let self = self else { return }
            
            guard let account = self.presenter._account.value, let externalId = account.id else {
                return
            }
            
            if getIdUser().contains(self.presenter.userId) == true {
                self.router.routeTo(.profileSetting(id: getIdUser(), showNavbar: false, isVerified: false, accountType: account.accountType ?? "USER"))
                return
            }
            self.handleAnotherOptions(self.presenter.userId, account)
        }
        
        headerView?.changeBukaBlock = { [weak self] id in
            self?.blockedUserStore.remove(id)
            self?.refresh()
        }
        
		presenter.fetchingNetwork.map({!$0}).drive(isEnableButtonFollow).disposed(by: disposeBag)
        
        if blockedUserStore.retrieve()?.contains(presenter.userId) == true {
            headerView?.hideBukaBlockButton(hide: false)
        }
        
        if getIdUser().contains(presenter.userId) == true {
            headerView?.followButton.isHidden = true
            headerView?.bukaBlockerButton.isHidden = true
        }
		
		return self.headerView!
	}
	

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
		
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spaceForScreens: CGFloat = 1
        let widthScreenDivideByThree = self.view.frame.size.width / 3 - spaceForScreens
        let heightScreenDivideByThree = (view.frame.size.width / 3) + 40
        
        return CGSize(width: widthScreenDivideByThree, height: heightScreenDivideByThree)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let bioData = self.presenter._account.value?.bio ?? ""
        
        let knownHeight: CGFloat = 220 //from : padding userImage to top, padding bottom, shopMessage button, sosmediView, userImageHeight
        var dynamicHeight: CGFloat = 0
        
        if headerView?.bioLabelTopAnchorToUserImage?.isActive == true {
            dynamicHeight += headerView?.bioLabelTopAnchorToUserImage?.constant ?? 0
        }
        
        if headerView?.shopButtonTopAnchorToBioLabel?.isActive == true {
            dynamicHeight += headerView?.shopButtonTopAnchorToBioLabel?.constant ?? 0
        }
        
        if headerView?.shopButtonTopAnchorToUserImage?.isActive == true {
            dynamicHeight += headerView?.shopButtonTopAnchorToUserImage?.constant ?? 0
        }
        
        if !bioData.isEmpty{
            dynamicHeight += bioData.height(withConstrainedWidth: headerView?.bioLabel.frame.width ?? 0.0, font: headerView?.bioLabel.font ?? .Roboto(.regular, size: 13)) ?? 0.0
        }
        
        let validHeight = knownHeight + dynamicHeight
        return CGSize(width: self.view.frame.width, height: validHeight)
	}

		func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
//            var alreadyxLoadFeeds = feeds.toFeedItem(account: account)
//            let selectedIndex = alreadyLoadFeeds[indexPath.item]
//            alreadyLoadFeeds.remove(at: indexPath.item)
//            alreadyLoadFeeds.insert(selectedIndex, at: 0)
            
            let controller = HotNewsFactory.create(
                by: .profile,
                profileId: feeds[indexPath.item].account?.id ?? "",
                page: presenter.requestedPage + 1,
                selectedFeedId: feeds[indexPath.item].id ?? "",
                alreadyLoadFeeds: feeds.toFeedItem(account: account)
            )
            controller.handleUpdateLikes = { [weak self] feed in
                guard self != nil else { return }
                
                NotificationCenter.default.post(
                    name: Notification.Name("handleUpdateHotNewsCellLikesFromProfileFeed"),
                    object: nil,
                    userInfo: [
                        "postId": feed?.post?.id ?? "",
                        "accountId": feed?.account?.id ?? "",
                        "likes": feed?.likes ?? 0,
                        "isLike": feed?.isLike ?? false
                    ]
                )
            }
            controller.bindNavigationBar("", icon: "iconBack")
            controller.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(controller, animated: true)
		}
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == feeds.count - 1 && presenter.requestedPage < presenter.totalPage {
            presenter.requestedPage += 1
            presenter.getFeed(by: presenter.userId)
        }
    }
		
		func goToShop() {
				guard let id = interactor.dataSource.id else {return}
            router.routeTo(.myShop(id: id, isVerified: presenter._account.value?.isVerified ?? false))
		}

		func setProfile(id: String, type: String) {

				presenter.userId = id
				interactor.setId(id: id)
				interactor.setPage(data: 0)
				interactor.dataSource.type = type
		}
		
		func showOption() {
            router.routeTo(.profileSetting(id: getIdUser(), showNavbar: true, isVerified: false,  accountType: account?.accountType ?? "USER"))
		}
    
    func onTapProfileImage(image: UIImage?) {
        router.routeTo(.donationRankAndBadge(accountId: presenter.userId))
    }
		
	func refresh() {
        let id = presenter.userId
        presenter.getAccountNetwork(id: id)
        presenter.getNetworkCounter(id: id)
        mainView.labelEmptyPlaceholder.text = ""
        mainView.labelEmptyPlaceholder.isHidden = feeds.count > 0
        
        if blockedUserStore.retrieve()?.contains(id) == true {
            mainView.progress.stopAnimating()
            mainView.labelEmptyPlaceholder.text = .get(.userAlreadyBlock)
            mainView.labelEmptyPlaceholder.isHidden = false
            return
        }
        
        presenter.getPostIsCalled = false
        presenter.requestedPage = 0
        presenter.getFeed(by: id)
        displayReddot()
	}
		
		func followers() {
			let id = presenter.userId
			self.router.routeTo(.followers(id: id, showNavbar: true))
		}
		
		func followings() {
			let id = presenter.userId
			self.router.routeTo(.followings(id: id, showNavbar: true))
		}

		func followButton(id: String, isFollowed: Bool) {

				if !isFollowed {
						presenter.unFollowAccount(id: id)
				} else {
						presenter.followAccount(id: id)
				}
		}
    
    func goToStory() {
        
    }
    
    private func handleAnotherOptions( _ accountId: String, _ profile: Profile){
        let vc = AnotherUserProfileOptionsViewController(accountId: accountId, profile: profile)
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }
    
}

extension AnotherUserProfileViewController: AnotherUserProfileOptionsDelegate{
    func didReport(accountId: String, profile: Profile) {
        let rvm = ReportAccountViewModel(imageUrl: profile.photo ?? "", accountId: accountId, networkModel: ReportNetworkModel())
        let rc = ReportAccountController(viewModel: rvm)
        rc.changeReportAccount = { [weak self] in
            
            rc.navigationController?.popViewController(animated: false)
            
            self?.blockedUserStore.insert([accountId]) { _ in }
            let reportPVC = ReportPopupViewController(mainView: ReportPopupView())
            
            reportPVC.modalPresentationStyle = .overFullScreen
            reportPVC.mainView.onBackPressed = {
                reportPVC.dismiss(animated: true)
            }
            
            self?.present(reportPVC, animated: true, completion: nil)
        }
        self.navigationController?.pushViewController(rc, animated: true)
    }
    
    func didBlock(accountId: String, profile: Profile) {
        self.presenter.lastPrepareIndex = 0
        self.feeds = []
        self.blockedUserStore.insert([accountId]) { _ in }
        self.headerView?.hideBukaBlockButton(hide: false)
        self.mainView.labelEmptyPlaceholder.text = .get(.userAlreadyBlock)
        self.mainView.labelEmptyPlaceholder.isHidden = false
        
        DispatchQueue.main.async {
            self.mainView.collectionView.reloadData()
        }
    }
    
    func didMessage(accountId: String, profile: Profile) {
        guard let userId = profile.id, !userId.isEmpty else {
            DispatchQueue.main.async {
                KKLoading.shared.hide()
                Toast.share.show(message: "Error: User not found..")
            }
            return
        }
        
        DispatchQueue.main.async {
            KKLoading.shared.hide() {
                let user = TXIMUser(userID: userId, userName: profile.name ?? "", faceURL: profile.photo ?? "", isVerified: profile.isVerified ?? false)
                showIMConversation?(user)
            }
        }
    }
    
    func onNavigateToChannel(channelUrl: String) {
        
    }
    
    func routeToFakeDM(account: Profile) {
        
    }
    
    func leaveFakeDM(accountId: String) {
        
    }
}

// MARK: - Private Zone
private extension AnotherUserProfileViewController {
		
	func displayProfileHeader(_ viewModel: Profile) {
        self.headerView?.configure(viewModel: viewModel)
	}
    
    func setupSocialMedia(_ viewModel: Profile) {
        if let socialMedias = viewModel.socialMedias {
            for socialMedia in socialMedias {
                switch socialMedia.socialMediaType {
                case SocialMediaType.instagram.rawValue:
                    self.headerView?.iconsSocmedView.dataSource[0] = SocialMedia(socialMediaType: SocialMediaType.instagram.rawValue, urlSocialMedia: socialMedia.urlSocialMedia ?? "")
                    self.headerView?.iconsSocmedView.handlerInstagram = {
                        if let urlSocMed = socialMedia.urlSocialMedia {
                            self.router.routeTo(.socialMedia(url: urlSocMed))
                        }
                    }
                    self.headerView?.iconsSocmedView.collectionView.reloadData()
                case SocialMediaType.tiktok.rawValue:
                    self.headerView?.iconsSocmedView.dataSource[1] = SocialMedia(socialMediaType: SocialMediaType.tiktok.rawValue, urlSocialMedia: socialMedia.urlSocialMedia ?? "")
                    self.headerView?.iconsSocmedView.handlerTiktok = {
                        if let urlSocMed = socialMedia.urlSocialMedia {
                            self.router.routeTo(.socialMedia(url: urlSocMed))
                        }
                    }
                    self.headerView?.iconsSocmedView.collectionView.reloadData()
                case SocialMediaType.wikipedia.rawValue:
                    self.headerView?.iconsSocmedView.dataSource[2] = SocialMedia(socialMediaType: SocialMediaType.wikipedia.rawValue, urlSocialMedia: socialMedia.urlSocialMedia ?? "")
                    self.headerView?.iconsSocmedView.handlerWikipedia = {
                        if let urlSocMed = socialMedia.urlSocialMedia {
                            self.router.routeTo(.socialMedia(url: urlSocMed))
                        }
                    }
                    self.headerView?.iconsSocmedView.collectionView.reloadData()
                case SocialMediaType.facebook.rawValue:
                    self.headerView?.iconsSocmedView.dataSource[3] = SocialMedia(socialMediaType: SocialMediaType.facebook.rawValue, urlSocialMedia: socialMedia.urlSocialMedia ?? "")
                    self.headerView?.iconsSocmedView.handlerFacebook = {
                        if let urlSocMed = socialMedia.urlSocialMedia {
                            self.router.routeTo(.socialMedia(url: urlSocMed))
                        }
                    }
                    self.headerView?.iconsSocmedView.collectionView.reloadData()
                case SocialMediaType.twitter.rawValue:
                    self.headerView?.iconsSocmedView.dataSource[4] = SocialMedia(socialMediaType: SocialMediaType.twitter.rawValue, urlSocialMedia: socialMedia.urlSocialMedia ?? "")
                    self.headerView?.iconsSocmedView.handlerTwitter = {
                        if let urlSocMed = socialMedia.urlSocialMedia {
                            self.router.routeTo(.socialMedia(url: urlSocMed))
                        }
                    }
                    self.headerView?.iconsSocmedView.collectionView.reloadData()
                default:
                    break
                }
                    
            }
        }
    }
	
	func displayFollower(_ viewModel: TotalFollow) {
        headerView?.configureFollowers(value: viewModel)
	}
	
	func displayFollowing(_ viewModel: TotalFollow) {
        headerView?.configureFollowing(value: viewModel)
	}

	func displayTotalPost(_ viewModel: TotalFollow) {
        mainView.progress.stopAnimating()
        mainView.labelEmptyPlaceholder.isHidden = viewModel.data ?? 0 > 0
        mainView.labelEmptyPlaceholder.text = viewModel.data ?? 0 > 0 ? "" : .get(.emptyUserProfilePost)
        
        headerView?.configurePost(value: viewModel)
	}
	
	func displayProfilePosts(_ viewModel: [Feed]) {
        feeds = viewModel
        
        mainView.labelEmptyPlaceholder.isHidden = viewModel.count > 0
        mainView.labelEmptyPlaceholder.text = viewModel.count > 0 ? "" : .get(.emptyUserProfilePost)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.mainView.collectionView.refreshControl?.endRefreshing()
            self.mainView.collectionView.reloadData()
        }
	}
	
	func displayPaginationPosts(_ viewModel: [Feed]) {
        mainView.progress.stopAnimating()
        feeds.append(contentsOf: viewModel)
        self.mainView.collectionView.reloadData()
        if presenter.getPostIsCalled {
            mainView.labelEmptyPlaceholder.isHidden = self.feeds.count > 0
            mainView.labelEmptyPlaceholder.text = self.feeds.count > 0 ? "" : .get(.emptyUserProfilePost)
        }
	}
    
    func displayError(_ message: String) {
        Toast.share.show(message: message)
    }
}

private extension Array where Element == Feed {
    func toFeedItem(account: Profile?) -> [FeedItem] {
        return compactMap({ content in
            
            let mediasThumbnail = content.post?.medias?.first?.thumbnail.map({
                FeedThumbnail(small: $0.small, large: $0.large, medium: $0.medium)
            })

            let feedMetadata = content.post?.medias?.first?.metadata.map({
                FeedMetadata(duration: $0.duration, width: $0.width, height: $0.height)
            })
            
            let medias = content.post?.medias?.compactMap({
                FeedMedia(id: $0.id, url: $0.url, vodUrl: $0.vodUrl, metadata: feedMetadata, thumbnail: mediasThumbnail
                          , type: $0.type)
            })

//            let medias = content.post?.medias?.compactMap({
//                FeedMedia(id: $0.id, url: $0.url, vodUrl: $0.vodUrl, thumbnail: mediasThumbnail, type: $0.type)
//            })
            
            let donationCategory = content.post?.donationCategory.map({
                FeedDonationCategory(id: $0.id, name: $0.name)
            })
            
            let productMeasurement = content.post?.product?.measurement.map({
                FeedProductMeasurement(weight: $0.weight, length: $0.length, height: $0.height, width: $0.width)
            })
            
            let productMedias = content.post?.product?.medias?.compactMap({
                FeedMedia(id: $0.id, url: $0.url, vodUrl: $0.vodUrl, thumbnail: mediasThumbnail, type: $0.type)
            })
            
            let product = content.post?.product.map({
                FeedProduct(
                    accountId: $0.accountId,
                    description: $0.postProductDescription,
                    generalStatus: $0.generalStatus,
                    id: $0.id,
                    isDeleted: $0.isDeleted,
                    measurement: productMeasurement,
                    medias: productMedias,
                    name: $0.name,
                    price: $0.price,
                    sellerName: $0.sellerName,
                    sold: $0.sold,
                    productPages: $0.productPages,
                    reasonBanned: $0.reasonBanned
                )
            })
            
            let post = content.post.map({
                FeedPost(
                    id: $0.id,
                    description: $0.postDescription,
                    medias: medias,
                    title: $0.title,
                    targetAmount: $0.targetAmount,
                    amountCollected: $0.amountCollected,
                    donationCategory: donationCategory,
                    product: product,
                    floatingLink: $0.floatingLink,
                    floatingLinkLabel: $0.floatingLinkLabel,
                    siteName: $0.siteName,
                    siteLogo: $0.siteLogo, 
                    levelPriority: $0.levelPriority, 
                    isDonationItem: $0.isDonationItem
                )
            })
            
            let account = content.account.map({
                FeedAccount(
                    id: $0.id,
                    username: $0.username,
                    isVerified: $0.isVerified,
                    name: $0.name,
                    photo: $0.photo,
                    accountType: $0.accountType,
                    urlBadge: $0.urlBadge,
                    isShowBadge: $0.isShowBadge,
                    isFollow: account?.isFollow,
                    chatPrice: $0.chatPrice
                )
            })
            
            let item = FeedItem(
                id: content.id,
                likes: content.likes,
                isLike: content.isLike,
                account: account,
                post: post,
                typePost: content.typePost,
                comments: content.comments,
                trendingAt: 0,
                feedType: .profile,
                createAt: content.createAt
            )
            
            let mediaWithVodUrl = content.post?.medias?.filter({ $0.vodUrl != nil }).first
            let mediaWithoutVodUrl = content.post?.medias?.filter({ $0.url?.hasPrefix(".mp4") == true || $0.url?.hasPrefix(".m3u8") == true }).first
            let media = medias?.first
            
            if content.typePost == "donation" {
                item.videoUrl = mediaWithVodUrl?.vodUrl ?? mediaWithoutVodUrl?.url ?? ""
            } else {
                item.videoUrl = media?.playURL ?? ""
            }
            
            if let mediaThumbnail = media?.thumbnail?.large {
                
                let imageThumbnailOSS = ("\(mediaThumbnail)?x-oss-process=image/format,jpg/interlace,1/resize,w_360")
                
                item.coverPictureUrl = imageThumbnailOSS
                //print("***imageThumbnailOSS", imageThumbnailOSS)
            }
            
            item.duration = "\(media?.metadata?.duration ?? 0)"
            
            return item
        })
    }
}
