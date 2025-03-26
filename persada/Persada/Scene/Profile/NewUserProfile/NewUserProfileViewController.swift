//
//  NewUserProfileViewController.swift
//  Persada
//
//  Created by monggo pesen 3 on 19/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import UIKit
import ContextMenu
import RxSwift
import RxCocoa
import RxDataSources
import FeedCleeps
import Kingfisher
import KipasKipasDirectMessage
import KipasKipasDirectMessageUI
import KipasKipasShared

let notificationStoryData = Notification.Name("com.kipaskipas.storyData")
let notificationStoryRead = Notification.Name("com.kipaskipas.storyRead")

protocol NewUserProfileDisplayLogic where Self: UIViewController {
    
    func displayViewModel(_ viewModel: NewUserProfileModel.ViewModel)
}

protocol NewUserProfileDelegate {
    func updatePage(value: Int)
}

class NewUserProfileViewController: UIViewController, Displayable, NewUserProfileDisplayLogic, NewUserProfileDelegate {
    
    private var interactor: NewUserProfileInteractable!
    private var router: NewUserProfileRouting!
    private let disposeBag = DisposeBag()
    let mainView: NewUserProfileView
    var presenter: NewUserProfilePresenter!
    var headerView: UserProfileHeaderView?
    var feeds: [Feed] = []
    private let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)

    private let handleDeleteFeed = Notification.Name(rawValue: "com.kipaskipas.deleteFeed")
    
    required init(mainView: NewUserProfileView, dataSource: NewUserProfileModel.DataSource) {
        self.mainView = mainView
        super.init(nibName: nil, bundle: nil)
        interactor = NewUserProfileInteractor(viewController: self, dataSource: dataSource)
        router = NewUserProfileRouter(self)
        presenter = NewUserProfilePresenter(self)
        self.presenter.identifier = "PROFILE_SELF"
        self.setupItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(onProfileUpdated(notification:)), name: .notificationUpdateProfile, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = false
//        refresh()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.mainView.collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerObserver()
        handleViewDidLoad()
        presenter.userId = getIdUser()
    }
    
    fileprivate func handleReddotCondition() {
        
    }
    
    private func registerObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDelete(notification:)), name: handleDeleteFeed, object: nil)
    }
    
    @objc
    func handleDelete(notification: NSNotification){
        if let index = indexFeedByIdFromNotification(notification) {
            removeFeedAt(index)
        }
    }
    
    private func indexFeedByIdFromNotification(_ notification: NSNotification) -> Int? {
        if let dict = notification.userInfo as NSDictionary? {
            if let id = dict["id"] as? String{
                var idx: Int?
                for feed in feeds {
                    if feed.id == id {
                        idx = feeds.firstIndex(of: feed)
                        break
                    }
                }
                return idx
            }
        }
        return nil
    }
    
    private func removeFeedAt(_ index: Int){
        let indexPath = IndexPath(row: index, section: 0)
//        self.mainView.collectionView.reloadData()

        mainView.collectionView.performBatchUpdates({
            self.mainView.collectionView.deleteItems(at: [indexPath])
            self.feeds.remove(at: index)
        }, completion: {
            (finished: Bool) in
            self.mainView.collectionView.reloadItems(at: self.mainView.collectionView.indexPathsForVisibleItems)
        })
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc
    func onProfileUpdated(notification: NSNotification?) {
        self.feeds.removeAll()
        self.mainView.collectionView.reloadData()
       refresh()
    }
    
    private func handleViewDidLoad() {
        mainView.collectionView.delegate = self
        mainView.collectionView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateRedDot(notification:)), name: .notificationUpdateEmail, object: nil)
        
        presenter.errorMessage.asObservable().bind { error in
            if let err = error {
                self.showLongToast(message: err)
            }
            self.mainView.refreshControl.endRefreshing()
        }.disposed(by: disposeBag)
        
        refresh()
    }
    
    @objc func handleNotificationDeleteFeed(notification : NSNotification) {
        guard let feedID = notification.userInfo?["feedID"] as? String else { return }
        feeds = feeds.filter({ $0.id != feedID })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.mainView.collectionView.reloadData()
        }
    }
    @objc func updateRedDot(notification : NSNotification){
        displayReddot()
    }
    
    func displayReddot() {
        headerView?.redDot.isHidden = !getEmail().isEmpty
    }
    
    func updatePage(value: Int) {
        interactor.dataSource.page = value
    }
    
    func displayViewModel(_ viewModel: NewUserProfileModel.ViewModel) {
        switch viewModel {
        case .totalPost(let viewModel) :
            displayTotalPost(viewModel)
        case .profile(let viewModel):
            displayProfileHeader(viewModel)
        case .totalFollower(let viewModel):
            displayFollower(viewModel)
        case .totalFollowing(let viewModel):
            displayFollowing(viewModel)
        case .profilePosts(let viewModel):
            displayProfilePosts(viewModel)
        case .paginationPosts(let viewModel):
            displayPaginationPosts(viewModel)
        case .pictureUploaded(let viewModel):
            displayUploadedPicture(viewModel)
        case let .pictureUpdated(viewModel):
            displayUpdatedPicture(viewModel)
        case let .error(message):
            displayError(message)
        }
    }
    
    func setupItems() {
        self.presenter
            .feedAlreadyShow
            .subscribeOn(self.concurrentBackground)
            .observeOn(MainScheduler.instance)
            .bind { [weak self] feeds in
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
extension NewUserProfileViewController {
    
    func onBack(title: String) {
        print(title)
    }
        
    func displayProfileHeader(_ viewModel: Profile) {
        headerView?.configure(viewModel: viewModel)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.mainView.collectionView.refreshControl?.endRefreshing()
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
        self.mainView.labelEmptyPlaceholder.isHidden = viewModel.data ?? 0 > 0
        headerView?.configurePost(value: viewModel)
    }
    
    func displayProfilePosts(_ viewModel: [Feed]) {
        addFeed(viewModel)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.mainView.collectionView.reloadData()
            self.mainView.labelEmptyPlaceholder.isHidden = self.feeds.count > 0
            self.mainView.collectionView.refreshControl?.endRefreshing()
            self.mainView.collectionView.isUserInteractionEnabled = true
        }
    }
    
    func displayPaginationPosts(_ viewModel: [Feed]) {
        mainView.progress.stopAnimating()
        addFeed(viewModel)
        self.mainView.collectionView.reloadData()
        if presenter.getPostIsCalled {
            self.mainView.labelEmptyPlaceholder.isHidden = self.feeds.count > 0
        }
        
    }
    
    private func addFeed(_ viewModel: [Feed]) {
        self.feeds.append(contentsOf: viewModel)
    }
    
    private func displayError(_ message: String) {
        KKLoading.shared.hide {
            Toast.share.show(message: message)
        }
    }
    
    private func displayUploadedPicture(_ viewModel: ResponseMedia) {
        KKLoading.shared.hide()
        if let url = viewModel.url {
            interactor.requestProfile(.updatePicture(id: presenter.userId, url: url))
            DispatchQueue.main.async { KKLoading.shared.show() }
        }
    }
    
    private func displayUpdatedPicture(_ viewModel: String) {
        DispatchQueue.main.async {
            KKLoading.shared.hide()
            self.headerView?.userImageView.userImageView.kf.setImage(with: URL(string: viewModel), placeholder: UIImage(named: .get(.iconPersonWithCornerRadius)))
            NotificationCenter.default.post(name: .notificationUpdateProfile, object: nil)
        }
    }
}

extension NewUserProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feeds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewUserProfileView.ViewTrait.cellId, for: indexPath) as! NewUserProfileItemCell
        if(feeds.count > indexPath.row) {
            cell.item = feeds[indexPath.row].mapToProfileContent()
            cell.decideIcon(feed: feeds[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: NewUserProfileView.ViewTrait.headerId, for: indexPath) as? UserProfileHeaderView
        headerView?.delegate = self
        
        headerView?.optionIconButton.onTap(action: { [weak self] in
            guard let self = self else { return }
            self.router.routeTo(.profileSetting(id: getIdUser(), showNavbar: false, isVerified: self.presenter._account.value?.isVerified ?? false, accountType:  self.presenter._account.value?.accountType ?? "USER"))
        })
        
        headerView?.iconShopButton.onTap(action: { [weak self] in
            guard let self = self else { return }
            let id = self.presenter.userId
            self.router.routeTo(.myShop(id: id, isVerified: self.presenter._account.value?.isVerified ?? false))
        })
        
        headerView?.messageButton.onTap(action: { [weak self] in
            guard let self = self else { return }
            
            showDirectMessage?()
        })
        
        guard let profile = self.presenter._account.value, let isEnableButtonFollow = self.headerView?.messageButton.rx.isEnabled else {
            return headerView!
        }
        
        self.presenter.account.drive(onNext: { profile in
            guard let profile = profile else { return }
            self.headerView?.configure(viewModel: profile)
            self.setupSocialMedia(profile)
        }).disposed(by: disposeBag)
        
        presenter.counterProfile.drive { count in
            if let counts = count {
                self.headerView?.setupCount(count: counts)
            }
        }.disposed(by: disposeBag)
        
        presenter.fetchingNetwork.map({!$0}).drive(isEnableButtonFollow).disposed(by: disposeBag)
        displayReddot()
        return self.headerView!
    }
}

extension NewUserProfileViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let userID = feeds.first?.account?.id
//        let profileDetail = FeedFactory.createFeedProfileController(requestedPage: self.presenter.requestedPage + 1, totalPage: 0, feed: [], userID: "\(userID ?? "")", type: .profile(isSelf: true), showBottomCommentSectionView: true) { [weak self] feed in
//            guard let self = self else { return }
//            self.feeds[indexPath.row] = feed
//            self.mainView.collectionView.reloadItems(at: [IndexPath(row: indexPath.row, section: 0)])
//        } onClickComment: { [weak self] index, count in
//            guard let self = self else { return }
//            self.feeds[indexPath.row].comments = count
//            self.mainView.collectionView.reloadItems(at: [IndexPath(row: indexPath.row, section: 0)])
//        }
//
//        feeds.forEach { kipasFeed in
//            var feed = FeedItemMapper.map(feed: kipasFeed)
//            feed.account?.isFollow = true
//            profileDetail.setupItems(feed: feed)
//        }
//        profileDetail.showFromStartIndex(startIndex: indexPath.row)
//        profileDetail.bindNavigationBar("" , true, icon: .get(.arrowLeftWhite))
//        navigationController?.displayShadowToNavBar(status: false)
//        
//        profileDetail.hidesBottomBarWhenPushed = true
//        navigationController?.pushViewController(profileDetail, animated: true)
        
//        var alreadyLoadFeeds = feeds.toFeedItem()
//        let selectedIndex = alreadyLoadFeeds[indexPath.item]
//        alreadyLoadFeeds.remove(at: indexPath.item)
//        alreadyLoadFeeds.insert(selectedIndex, at: 0)
        
        let controller = HotNewsFactory.create(
            by: .profile,
            profileId: feeds[indexPath.item].account?.id ?? "", 
            page: presenter.requestedPage + 1,
            selectedFeedId: feeds[indexPath.item].id ?? "",
            alreadyLoadFeeds: feeds.toFeedItem()
        )
        controller.bindNavigationBar("", icon: "iconBack")
        controller.hidesBottomBarWhenPushed = true
        controller.handleUpdateFeeds = { [weak self] feeds in
            guard let self = self else { return }
            
//            for (index, element) in self.feeds.enumerated() {
//                feeds.forEach { feed in
//                    if element.id == feed.id {
//                        self.feeds[index].comments = feed.comments
//                    }
//                }
//            }
            
            self.feeds.enumerated().forEach { (index, element) in
                self.feeds[index].comments = feeds.first(where: { $0.id == element.id })?.comments
            }
            
        }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == feeds.count - 1 && presenter.requestedPage < presenter.totalPage {
            presenter.requestedPage += 1
            presenter.getFeed(by: presenter.userId)
        }
    }
}

extension NewUserProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets { .zero }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { 1 }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { 1 }
   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spaceForScreens: CGFloat = 1
        let widthScreenDivideByThree = view.frame.size.width / 3 - spaceForScreens
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
}

extension NewUserProfileViewController: UserProfileHeaderDelegate, NewUserProfileViewDelegate, UIGestureRecognizerDelegate {
    func goToShop() {
//        guard let id = interactor.dataSource.id else {
//            return
//        }
//        let id = interactor.dataSource.id ?? ""
//        router.routeTo(.myShop(id: id, showNavbar: true))
    }
    
    func setProfile(id: String, type: String) {
        presenter.userId = id
        interactor.setId(id: id)
        interactor.setPage(data: 0)
        interactor.dataSource.type = type
    }
    
    func showOption() {
//        router.routeTo(.profileSetting(id: getIdUser(), showNavbar: false))
    }
    
    @objc func refresh() {
        self.presenter.lastPrepareIndex = 0
        guard ReachabilityNetwork.isConnectedToNetwork() else {
            presenter._errorMessage.accept("No internet available, please check your WIFI or Data connection")
            mainView.collectionView.refreshControl?.endRefreshing()
            return
        }
        
        handleReddotCondition()
        let id = getIdUser()
        presenter._fetchingNetwork.accept(false)
        presenter.getAccountNetwork(id: id)
        presenter.getNetworkCounter(id: id)
        
        presenter.getPostIsCalled = false
        presenter.requestedPage = 0
        presenter.getFeed(by: id)
    }
    
    func followers() {
        let id = presenter.userId
        router.routeTo(.followers(id: id, showNavbar: false))
    }
    
    func followings() {
        let id = presenter.userId
        router.routeTo(.followings(id: id, showNavbar: false))
    }
    
    func followButton(id: String, isFollowed: Bool) {
        !isFollowed ? presenter.unFollowAccount(id: id) : presenter.followAccount(id: id)
    }
    
    func onTapProfileImage(image: UIImage?) {
        router.routeTo(.pictureOptions(picture: image,delegate: self))
    }
}

private extension NewUserProfileViewController {
    @objc func updateFollowers(notif: NSNotification) {
        if let followers = notif.userInfo?["followers"] as? Int {
            let validData =  TotalFollow(code: "", data: followers, id: "", message: "")
            headerView?.configureFollowers(value: validData)
        }
    }
    
    @objc func updateFollowing(notif: NSNotification) {
        if let followers = notif.userInfo?["following"] as? Int {
            let validData = TotalFollow(code: "", data: followers, id: "", message: "")
            headerView?.configureFollowing(value: validData)
        }
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
    
    private func handleSelectedMedia(with item: KKMediaItem) {
        router.routeTo(.cropPicture(item: item, delegate: self))
    }
}

// MARK: - ProfilePictureOptionsDelegate
extension NewUserProfileViewController: ProfilePictureOptionsDelegate {
    func didTapPicture(image: UIImage?) {
        router.routeTo(.picturePreview(picture: image))
    }
    
    func didTapCamera() {
        router.routeTo(.openCamera(onMediaSelected: handleSelectedMedia))
    }
    
    func didTapLibrary() {
        router.routeTo(.openLibrary(delegate: self))
    }
    
    func didTapDonationBadge() {
        router.routeTo(.donationRankAndBadge(accountId: presenter.userId))
    }
}

// MARK: - KKMediaPickerDelegate
extension NewUserProfileViewController: KKMediaPickerDelegate {
    func didPermissionRejected() {
        KKMediaPicker.showAlertForAskPhotoPermisson(in: self)
    }
    
    func didLoading(isLoading: Bool) {
        if isLoading {
            KKLoading.shared.show()
        } else {
            KKLoading.shared.hide()
        }
    }
    
    func didSelectMedia(media item: KKMediaItem) {
        handleSelectedMedia(with: item)
    }
    
    func displayError(message: String) {
        
    }

}

// MARK: - ProfilePictureCropDelegate
extension NewUserProfileViewController: ProfilePictureCropDelegate {
    func didCropped(media item: KKMediaItem) {
        interactor.requestProfile(.uploadPicture(item))
        KKLoading.shared.show()
    }
}

private extension Array where Element == Feed {
    func toFeedItem() -> [FeedItem] {
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
                    isFollow: $0.isFollow,
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
            
            let media = medias?.first
            item.videoUrl = media?.playURL ?? ""
            
            if let mediaThumbnail = media?.thumbnail?.large {
                
                let imageThumbnailOSS = ("\(mediaThumbnail)?x-oss-process=image/format,jpg/interlace,1/resize,w_240")
                
                item.coverPictureUrl = imageThumbnailOSS
                //print("***imageThumbnailOSS", imageThumbnailOSS)
            }
            
            item.duration = "\(media?.metadata?.duration ?? 0)"
            
            return item
        })
    }
}
