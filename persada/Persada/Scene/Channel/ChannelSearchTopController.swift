//
//  ChannelSearchTopController.swift
//  Persada
//
//  Created by NOOR on 24/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import UIKit
import FeedCleeps

protocol ChannelSearchTopDisplayLogic where Self: UIViewController {
    
    func displayViewModel(_ viewModel: ChannelSearchTopModel.ViewModel)
    func failedSeachTop(message: String)
}

class ChannelSearchTopController: UIViewController, Displayable, ChannelSearchTopDisplayLogic {
    
    let mainView: ChannelSearchTopView
    var interactor: ChannelSearchTopInteractable!
    private var router: ChannelSearchTopRouting!
    var onMoreTapped: (() -> Void)?
    var isLoading: Bool!
    
    required init(mainView: ChannelSearchTopView, dataSource: ChannelSearchTopModel.DataSource) {
        self.mainView = mainView
        self.isLoading = false
        super.init(nibName: nil, bundle: nil)
        interactor = ChannelSearchTopInteractor(viewController: self, dataSource: dataSource)
        router = ChannelSearchTopRouter(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let feeds = ChannelSearchTopSimpleCache.instance.getFeeds, !feeds.isEmpty {
            interactor.dataSource.feeds = feeds
            mainView.collectionView.reloadData()
        }
        
        if let accounts = ChannelSearchTopSimpleCache.instance.getAccounts, !accounts.isEmpty {
            interactor.dataSource.accounts = accounts
            mainView.collectionView.reloadData()
        }
    }
    
    override func loadView() {
        view = mainView
        mainView.collectionView.delegate = self
        mainView.collectionView.dataSource = self
        mainView.updateKind(interactor.dataSource)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
    }
    
    
    // MARK: - ChannelSearchTopDisplayLogic
    func displayViewModel(_ viewModel: ChannelSearchTopModel.ViewModel) {
        DispatchQueue.main.async {
            self.isLoading = false
            switch viewModel {
                
            case .topFeeds(let viewModel):
                print("search top feeds response", viewModel.count)
                self.displayDoTopFeeds(viewModel)
            case .topAccounts(let viewModel):
                print("search top account response", viewModel.count)
                self.displayTopAccounts(viewModel)
            }
        }
    }
    
    func failedSeachTop(message: String) {
        isLoading = false
        interactor.dataSource.feeds = nil
        interactor.dataSource.accounts = nil
        mainView.updateKind(interactor.dataSource)
        DispatchQueue.main.async {
            self.mainView.collectionView.backgroundView = self.mainView.emptyView(self.interactor.dataSource.text)
            self.mainView.collectionView.reloadData()
        }
        
    }
}


// MARK: - ChannelSearchTopViewDelegate
extension ChannelSearchTopController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = indexPath.section
        switch section {
        case 0:
            let cell = collectionView.dequeueReusableCell(ChannelSearchAccountCell.self, for: indexPath)
            
            guard let item = self.interactor.dataSource.accounts?[indexPath.row] else {
                return cell
            }
            
            cell.data = item
            
            return cell
            
        case 1:
            return collectionView.dequeueReusableCell(ChannelSearchTopDividerViewCell.self, for: indexPath)
            
        case 2:
            let cell = collectionView.dequeueReusableCell(ChannelSearchTopItemCell.self, for: indexPath)
            
            guard let items = self.interactor.dataSource.feeds else {
                return cell
            }
            
            cell.data = items[indexPath.row]
            
            return cell
            
        default:
            fatalError("Undefined section")
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isDragging, let items = self.interactor.dataSource.feeds else { return }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height - 500
        if (offsetY > contentHeight - scrollView.frame.height) {
            if !isLoading {
                let page = interactor.page
                if ( (items.count/10) >= page ) {
                    self.isLoading = true
                    self.interactor?.setPage(page + 1)
                    self.interactor?.doRequest(.searchFeed)
                }
            }
        }
    }
}

extension ChannelSearchTopController: DENCollectionViewDelegateLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let section = indexPath.section
        switch section{
        case 0: return CGSize(width: collectionView.frame.width, height: 46)
        case 1: return CGSize(width: collectionView.frame.width, height: 1)
        case 2:
            let item = self.interactor.dataSource.feeds?[indexPath.row].post?.medias?.first
            let heightImage = Double(item?.metadata?.height ?? "") ?? 1028
            let widthImage = Double(item?.metadata?.width ?? "") ?? 1028
            let width = collectionView.frame.size.width
            let scaler = width / widthImage
            let percent = Double((10 - ((indexPath.row % 4) + 1))) / 10
            var height = heightImage * scaler
            if height > 500 {
                height = 500
            }
            height = (height * percent) + 100
            return CGSize(width: width, height: height)
        default: return collectionView.frame.size
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            guard let items = interactor.dataSource.accounts else {
                return 0
            }
            
            if items.count > 4 {
                return 4
            } else {
                return items.count
            }
            
        case 1:
            guard let accounts = interactor.dataSource.accounts, let feeds = interactor.dataSource.feeds, !(accounts.isEmpty) && !(feeds.isEmpty) else {
                return 0
            }
            
            return 1
            
        case 2:
            guard let items = interactor.dataSource.feeds else {
                return 0
            }
            
            return items.count
            
        default:
            fatalError("Unexpected section in collection view")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let section = indexPath.section
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let view = collectionView.dequeueReusableCustomHeaderView(with: ChannelHeaderView.self, indexPath: indexPath)
            if section == 0 {
                view.label.text = "Top Account"
            }
            if section == 2 {
                view.label.text = "Popular About " + (interactor.dataSource.text ?? "")
            }
            return view
            
        case UICollectionView.elementKindSectionFooter:
            let view = collectionView.dequeueReusableCustomFooterView(with: ChannelSearchTopFooterView.self, indexPath: indexPath)
            if section == 0 {
                view.label.text = "Lihat lebih banyak"
                view.label.onTap {
                    self.onMoreTapped?()
                }
            }
            return view
        default:
            fatalError("Unexpected viewForSupplementaryElementOfKind in collection view")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = indexPath.section
        switch section{
        case 0:
            guard let item = interactor.dataSource.accounts, let id = item[indexPath.row].id else {
                return
            }
            
            router.routeTo(.showProfile(id: id, isSeleb: item[indexPath.row].isSeleb ?? false))
        case 2:
            
            /*
             guard let items = interactor.dataSource.feeds else {
                return
            }
            
            router.routeTo(.showFeed(index: indexPath.row, feeds: items, requestedPage: interactor.page + 1, searchText: interactor.dataSource.text ?? "", onClickLike: { [weak self] feed in
                guard let self = self else { return }
                
                self.interactor.dataSource.feeds![indexPath.row] = feed
                self.mainView.collectionView.reloadItems(at: [IndexPath(row: indexPath.row, section: 0)])
            }))
             */
            
            let feeds = interactor.dataSource.feeds
            let item = interactor.dataSource.feeds?[indexPath.item]
            
            let vc = HotNewsFactory.create(
                by: .searchTop,
                profileId: getIdUser(),
                page: interactor.page,
                selectedFeedId: item?.id ?? "",
                alreadyLoadFeeds: feeds?.toFeedItem(account: item?.account) ?? [],
                searchKeyword: interactor.dataSource.text ?? ""
            )
            vc.bindNavigationBar(icon: .get(.arrowLeftWhite))
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: false)
            
        default: return
        }
    }
}

// MARK: - Private Zone
private extension ChannelSearchTopController {
    func displayDoTopFeeds(_ viewModel: [Feed]) {
        if (self.interactor.dataSource.feeds ?? []).isEmpty{
            self.interactor.dataSource.feeds = viewModel
        }else {
            self.interactor.dataSource.feeds?.append(contentsOf: viewModel)
        }
        
        isEmptyData()
        self.mainView.updateKind(self.interactor.dataSource)
    }
    
    func displayTopAccounts(_ viewModel: [SearchAccount]) {
        self.interactor.dataSource.accounts = viewModel
        isEmptyData()
        self.mainView.updateKind(self.interactor.dataSource)
    }
    
    
    func isEmptyData() {
        if interactor.dataSource.feeds?.count ?? 0 <= 0 && interactor.dataSource.accounts?.count ?? 0 <= 0 && interactor.dataSource.text != "" {
            mainView.collectionView.backgroundView = mainView.emptyView(interactor.dataSource.text)
        } else {
            mainView.collectionView.backgroundView = nil
        }
        DispatchQueue.main.async { self.mainView.collectionView.reloadData() }
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
                feedType: .searchTop,
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
