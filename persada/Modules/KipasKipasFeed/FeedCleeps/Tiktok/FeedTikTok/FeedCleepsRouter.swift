//
//  FeedCleepsRouter.swift
//  FeedCleeps
//
//  Created by PT.Koanba on 18/11/22.
//

import Foundation

public protocol FeedCleepsRouter {
    func onClickShare(item: Feed?)
    func onShowReportPopUp()
    func onClickProfile(id: String, type: String, _ updateFollowStatus: ((Bool) -> Void)?)
    func onClickHashtag(hashtag: String)
    func onShowAuthPopUp(onDismiss: @escaping (() -> Void))
    func onClickComment(id: String, item: Feed, indexPath: IndexPath, autoFocusToField: Bool, identifier: String)
    func onClickProductDetail(id: String, product: Product, item: Feed)
    func onClickLogin()
    func onClickEmptyProfile()
    func onClickProductBg(item: Feed)
    func onClickLike(item: Feed)
    func detailPost(userId: String, item: Feed)
    func onClickDonationCategory(categoryId: String, completion: @escaping ((String) -> Void))
    func onClickDonationCard(item: Feed)
    func onClickFloatingLink(url: String)
    func onClickNewsPortal(url: String, onDismiss: @escaping (() -> Void))
    func onStartPaidMessage(userId: String?, name: String?, avatar: String?, isVerified: Bool?)
}
