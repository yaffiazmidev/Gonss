//
//  HomeController+Extension.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 28/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import Combine
import FeedCleeps
import KipasKipasDirectMessage
import KipasKipasDirectMessageUI
import KipasKipasNotificationiOS
import KipasKipasLoginiOS

class PushNotifNavigate: NSObject {
	
	weak var controller : UIViewController?
//    private  var network: FeedNetworkModel? = FeedNetworkModel()
    private  var headerSubscriptions = [AnyCancellable]()
//    private  var timestampStorage: TimestampStorage? = TimestampStorage()
        
	override init() {
		super.init()
	}
//	
//	convenience init(controller: UIViewController) {
//		self.init()
//		self.controller = controller
//	}
	  
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
    
    func cleanNotif(){
        NotificationCenter.default.removeObserver(self)
    }
     
    
    
	func configureNotif() {
        
		/// QRCode
        NotificationCenter.default.addObserver(self, selector: #selector(directFromQR(notification:)), name: .qrNotificationKey, object: nil)
		
		/// Subcomment
		NotificationCenter.default.addObserver(self, selector: #selector(directToSubcomment(_:)), name: .pushNotifForSubcommentId, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(directToSubcomment(_:)), name: .pushNotifForLikeSubcommentId, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(directToSubcomment(_:)), name: .pushNotifForMentionSubcommentId, object: nil)

		
		/// News
		NotificationCenter.default.addObserver(self, selector: #selector(directToNews(_:)), name: .pushNotifForNewsId, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(directToNews(_:)), name: .pushNotifForNewsFeedFeed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(directToNews(_:)), name: .newsDetailUnivLink, object: nil)
		
		/// Feed | Comment
		NotificationCenter.default.addObserver(self, selector: #selector(directToComment(_:)), name: .pushNotifForCommentId, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(directToComment(_:)), name: .pushNotifForLikeFeedId, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(directToComment(_:)), name: .pushNotifForLikeCommentId, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(directToComment(_:)), name: .pushNotifForMentionFeedId, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(directToComment(_:)), name: .pushNotifForMentionCommentId, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(directToSingleFeed(_:)), name: .pushNotifForTrending, object: nil)
		
		/// Profile
		NotificationCenter.default.addObserver(self, selector: #selector(directToUserProfile(_:)), name: .pushNotifForUserProfileId, object: nil)

		/// Shop
		NotificationCenter.default.addObserver(self, selector: #selector(directToShop(_:)), name: .pushNotifForWeightAdjustmentId, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(directToDetailBuyer(_:)), name: .pushNotifForBuyerShopPaymentPaidId, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(directToDetailSeller(_:)), name: .pushNotifForSellerShopPaymentPaidId, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(directToShop(_:)), name: .pushNotifForBannedProductId, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(directToShop(_:)), name: .pushNotifOutOfStock, object: nil)
	}
    
    @objc
    private func directToSingleFeed(_ notification: NSNotification) {
        
        if let feedID = notification.userInfo?["feedID"] as? String {
            
//            presentSingleFeed(for: feedID, showCloseButton: true)
            //            pushOnce(vc, animated: false)
            

//            let targetVc = HotNewsFactory.createSingleFeed(selectedFeedId: feedID,isFromPushFeed: true)
        let targetVc = HotNewsFactory.createHotRoomSingFeed(selectedFeedId: feedID,isFromPushFeed: true) 
            targetVc.bindNavigationBar(icon: "arrowLeftWhite")
            targetVc.hidesBottomBarWhenPushed = true

            guard let currentWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {return}
            if currentWindow.topViewController is LoginOptionsViewController {
                return
            }

                
            self.controller?.dismiss(animated: true) { [weak self] in
                var nav:UINavigationController?
                if let tempNav = self?.controller as? UINavigationController  {
                     nav = tempNav
                }else{
                    nav = self?.controller?.navigationController ?? UINavigationController()
                }
                 
                guard let vcs = nav?.viewControllers else { return }
                if vcs.count >= 2 {
                    if let vc = vcs.last {
                        if vc is HotNewsViewController || vc is HotRoomViewController {
                            var tempVc: [UIViewController] = vcs.dropLast(1)
                            tempVc.append(targetVc)
                            if let nav = self?.controller as? UINavigationController {
                                nav.setViewControllers(tempVc, animated: true)
                            }else{
                                self?.controller?.navigationController?.setViewControllers(tempVc, animated: true)
                            }
                            return
                        }
                    }
                }
//                self?.controller?.show(targetVc, sender: true)
                
                if let nav = self?.controller as? UINavigationController {
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.15, execute: {
                        nav.hidesBottomBarWhenPushed = true
                        nav.pushViewController(targetVc, animated: true)
                    })
                }else{
                    self?.controller?.show(targetVc, sender: true)
                }
                
            }
        }
    }
     
    
    func presentSingleFeed(for feedID: String, showCloseButton: Bool = false) {
        getFeedById(id: feedID) { [weak self] feed in
            guard let self = self else { return }
            let feedVC = FeedFactory.createFeedController(feed: [feed], displaySingle: true, type: .pushNotif, showBottomCommentSectionView: true, isHome: false)
            feedVC.showButtonClose()
            feedVC.viewWillDisappear(true)
            feedVC.viewDidDisappear(true)
            
            let vc = UINavigationController(rootViewController: feedVC)
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            vc.displayShadowToNavBar(status: false)
            
            if let controller = self.controller?.presentedViewController {
                controller.dismiss(animated: true)
            }
            self.controller?.present(vc, animated: true)
        }
    }
    
    private func pushSingleFeed(for feedID: String) {
        getFeedById(id: feedID) { [weak self] feed in
            guard let self = self else { return }
            let vc = FeedFactory.createFeedController(feed: [feed], displaySingle: true, type: .pushNotif, showBottomCommentSectionView: true, isHome: false)
            vc.hidesBottomBarWhenPushed = true
            vc.bindNavigationBar("", true, icon: .get(.arrowLeftWhite))
            self.controller?.show(vc, sender: nil)
        }
    }
    
	
	@objc
	private func directToUserProfile(_ notification: NSNotification) {
		if let username = notification.userInfo?["NotifForUserProfileID"] as? String {
            
            let vc = ProfileRouter.create(username: username)
            vc.bindNavigationBar(
                "",
                icon: "ic_chevron_left_outline_black",
                customSize: .init(width: 20, height: 14),
                contentHorizontalAlignment: .fill,
                contentVerticalAlignment: .fill
            )
            vc.hidesBottomBarWhenPushed = true
            
            if let controller = self.controller?.topMostViewController() as? KipasKipasNotificationiOS.NotificationController {
                controller.navigationController?.setNavigationBarHidden(false, animated: true)
            }
            
            self.controller?.show(vc, sender: nil)
        }
	}
	
	@objc
	private func directToSubcomment(_ notification: NSNotification) {
		if let dataSource = notification.userInfo?["NotifForSubcommentID"] as? SubcommentModel.DataSource {
            
            guard let id = dataSource.id else { return }
            pushSingleFeed(for: id)
		}
		else if let dataSource = notification.userInfo?["NotifForLikeSubcommentID"] as? SubcommentModel.DataSource {
            
            guard let id = dataSource.id else { return }
            pushSingleFeed(for: id)
		} else if let dataSource = notification.userInfo?["NotifForMentionSubcommentID"] as? SubcommentModel.DataSource {
            
            guard let id = dataSource.id else { return }
            pushSingleFeed(for: id)
		}
	}
	
	@objc
	private func directToNews(_ notification: NSNotification) {
        if let id = notification.userInfo?["NewsDetailUnivLink"] as? String {
            let newsController = NewsDetailController(viewModel: NewsDetailViewModel(networkModel: FeedNetworkModel(), id: id, true))
            newsController.bindNavigationBar("", false)

            self.controller?.show(newsController, sender: nil)
        }
		else if let dataSource = notification.userInfo?["NotifForNewsTypeID"] as? String {
			
			let newsController = NewsDetailController(viewModel: NewsDetailViewModel(networkModel: FeedNetworkModel(), id: dataSource))
			newsController.bindNavigationBar("", false)

            self.controller?.show(newsController, sender: nil)
        } else if let dataSource = notification.userInfo?["NotifForNewsFeedFeed"] as? CommentModel.DataSource {
			
			guard let id = dataSource.id else { return }
			let comment = CommentDataSource(id: id)
			let commentController = CommentViewController(commentDataSource: comment)
			commentController.hidesBottomBarWhenPushed = true
			
			commentController.bindNavigationBar(.get(.commenter), false)

            self.controller?.show(commentController, sender: nil)
        }
	}
	
	@objc
	private func directToComment(_ notification: NSNotification) {
		if let dataSource = notification.userInfo?["NotifForFeedID"] as? CommentModel.DataSource {
            
            guard let id = dataSource.id else { return }
            pushSingleFeed(for: id)
            
		}
		else if let dataSource = notification.userInfo?["NotifForMentionCommentID"] as? CommentModel.DataSource {
            
            guard let id = dataSource.id else { return }
            pushSingleFeed(for: id)
            
		} else if let dataSource = notification.userInfo?["NotifForMentionFeedID"] as? CommentModel.DataSource {
            guard let id = dataSource.id
            else { return }
            pushSingleFeed(for: id)
            
		}
		else if let dataSource = notification.userInfo?["NotifForCommentID"] as? CommentModel.DataSource {
            
            guard let id = dataSource.id else { return }
            pushSingleFeed(for: id)
            
		}
		else if let dataSource = notification.userInfo?["NotifForLikeFeedID"] as? CommentModel.DataSource {
            
            guard let id = dataSource.id else { return }
            pushSingleFeed(for: id)


		} else if let dataSource = notification.userInfo?["NotifForFeedShareID"] as? CommentModel.DataSource {
            
            guard let id = dataSource.id else { return }
            pushSingleFeed(for: id)
        
        }
	}
	
	@objc
	func directFromQR(notification: NSNotification){
		if let item  = notification.userInfo?["QRItem"] as? KKQRItem {
            switch item.type {
            case .shop:
                let productController = ProductDetailFactory.createProductDetailController(dataSource: Product())

                productController.idProduct = item.id
                productController.isUnivLink = true
                productController.hidesBottomBarWhenPushed = true
                self.controller?.show(productController, sender: nil)
            case .donation:
                let vc = DonationDetailViewController(donationId: item.id, feedId: "")
                vc.hidesBottomBarWhenPushed = true
                self.controller?.show(vc, sender: nil)
            }
        }

	}
    
    @objc
    private func directToShop(_ notification: NSNotification) {
        if let id  = notification.userInfo?["NotifForWeightAdjutmentID"] as? String {
            let vc = NotificationPenyesuaianHargaViewController(id: id)
            vc.bindNavigationBar(.get(.penyesuaianHarga), false)

            self.controller?.show(vc, sender: nil)

        } else if let id = notification.userInfo?["NotifForBannedProductID"] as? String {
            let bannedController = NotificationBannedController(mainView: NotificationBannedView.loadViewFromNib(), id: id)
            bannedController.bindNavigationBar(.get(.bannedProduct), false)

            self.controller?.show(bannedController, sender: nil)

        } else if let id = notification.userInfo?["NotifForOutOfStock"] as? String {
            let detailController = ProductDetailFactory.createProductDetailController(dataSource: Product(id: id))
            self.controller?.show(detailController, sender: nil)
        }
    }
	
	@objc
	private func directToDetailBuyer(_ notification: NSNotification) {
		if let dataSource = notification.userInfo?["PushNotifForBuyerShopPaymentPaidID"] as? DetailTransactionModel.DataSource {
            let detailController = DetailTransactionPurchaseController(mainView: DetailTransactionPurchaseView.loadViewFromNib(), dataSource: dataSource)
			detailController.bindNavigationBar("", false)

            self.controller?.show(detailController, sender: nil)
        }
	}
	
	@objc
	private func directToDetailSeller(_ notification: NSNotification) {
		if let dataSource = notification.userInfo?["PushNotifForSellerShopPaymentPaidID"] as? DetailTransactionModel.DataSource {
			let detailController = DetailTransactionSalesController(mainView: DetailTransactionSalesView(), dataSource: dataSource)
			detailController.bindNavigationBar("", false)

            self.controller?.show(detailController, sender: nil)

        }
	}
    
    private func getFeedById(id: String, onSuccess: @escaping (Feed) -> ()) {
        let isLogin = getToken() != nil ? true : false
        if isLogin {
            requestFeedById(.postDetail(id: id), onSuccess)
        } else {
            requestFeedById(.postDetailPublic(id: id), onSuccess)
        }
       
    }
    
    private func requestFeedById(_ request: FeedEndpoint,_ onSuccess: @escaping (Feed) -> ()) {
        var network: FeedNetworkModel? = FeedNetworkModel()
        network?.PostDetail(request).sink(receiveCompletion: { [weak self] (completion) in
            guard self != nil else { return }
            switch completion {
            case .failure(let error):
                print(error.localizedDescription)
            case .finished: break
            }
        }) { [weak self] (model: PostDetailResult) in
            guard self != nil else { return }
            if let feed = model.data {
                onSuccess(feed)
            }
        }.store(in: &headerSubscriptions)
    }
}

public extension UIApplication {
    class func topViewController(_ viewController: UIViewController? = UIApplication.shared.currentActiveWindow?.rootViewController) -> UIViewController? {
        
        if let nav = viewController as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        
        if let presented = viewController?.presentedViewController {
            return topViewController(presented)
        }
        return viewController
    }
    
    class func openSetting() {
        guard let url = URL(string: "App-Prefs:root") else {
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    var currentActiveWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes.flatMap { ($0 as? UIWindowScene)?.windows ?? [] }.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
