//
//  CommentActionHandler.swift
//  KipasKipas
//
//  Created by PT.Koanba on 27/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import KipasKipasShared

final class CommentSectionRouter {
    private weak var viewController : UIViewController? = nil
    
    init(_ viewController: UIViewController?) {
        self.viewController = viewController
    }
    
    func routeToProfile(_ id: String,_ type: String) {
        let controller =  AnotherUserProfileViewController(mainView: AnotherUserProfileView(), dataSource: NewUserProfileModel.DataSource(id: id, type: type))
        controller.setProfile(id: id, type: type)
        controller.bindNavigationBar("", true)
        
        viewController?.navigationController?.pushViewController(controller, animated: true)
    }
    
    func shared(_ text: String, url: String) {
        let item = CustomShareItem(message: text, type: .content, assetUrl: url, accountId: "")
        let vc = KKShareController(mainView: KKShareView(), item: item)
        viewController?.present(vc, animated: true, completion: nil)
    }
    
    func routeToHashtag(hashtag: String){
//        let hashtagVC = HashtagListViewController()
//        hashtagVC.hashtag = hashtag
//        hashtagVC.hidesBottomBarWhenPushed = true
//        viewController?.navigationController?.pushViewController(hashtagVC, animated: true)
    }
    
    func routeToBrowser(url: String) {
        let browserController = BrowserController(url: url, type: .general)
        viewController?.navigationController?.pushViewController(browserController, animated: true)
    }
    
    func routeToShop(id: String) {
        if id == getIdUser() {
            let storeController = MyProductFactory.createMyProductController()
            storeController.hidesBottomBarWhenPushed = true
            viewController?.navigationController?.pushViewController(storeController, animated: false)
        } else {
            var profile = Profile.emptyObject()
            profile.id = id
            let storeController = AnotherProductFactory.createAnotherProductController(account: profile)
            storeController.hidesBottomBarWhenPushed = true
            viewController?.navigationController?.pushViewController(storeController, animated: false)
        }
    }
    
    func routeToProductDetail(productID: String){
        var product = Product()
        product.id = productID
        let detailController = ProductDetailFactory.createProductDetailController(dataSource: product)
            detailController.hidesBottomBarWhenPushed = true
        viewController?.navigationController?.pushViewController(detailController, animated: true)
    }
    
    func routeToSubComment(userID: String, userType: String, postID: String, commentID: String, dataStore: CommentHeaderCellViewModel, commentAdded: @escaping (Int) -> ()){
        
        let subCommentVC = SubcommentViewController()
        let subcommentDataSource = SubcommentModel.SubcommentDataSource(
            id: commentID, postId: postID,
            commentHeader: SubcommentModel.SubcommentHeader(userId: userID,
                                                            userType: userType,
                                                            description: dataStore.description,
                                                            date: dataStore.date,
                                                            username: dataStore.username,
                                                            imageUrl: dataStore.imageUrl),
            subcomments: [])
        subCommentVC.viewModel = SubcommentViewModel(subcommentDataSource: subcommentDataSource,
                                                     feedNetwork: FeedNetworkModel(),
                                                     profileNetwork: ProfileNetworkModel())
        subCommentVC.bindNavigationBar(.get(.commenter))
        viewController?.navigationController?.pushViewController(subCommentVC, animated: true)
    }
    
    func routeToEmptyProfile(){
        let controller = EmptyUserProfileViewController()
        controller.bindNavigationBar("", true)
        viewController?.navigationController?.pushViewController(controller, animated: true)
    }
    
    func presentReportSheet(id: String, accountId: String, imageUrl: String, reportType: ReportType){
        let controller = ReportFeedController(viewModel: ReportFeedViewModel(id: id, imageUrl: imageUrl, accountId: accountId, networkModel: ReportNetworkModel()))
        controller.delegate = viewController as? ReportFeedDelegate
        controller.viewModel?.reportType = reportType
        DispatchQueue.main.async {
            self.viewController?.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
