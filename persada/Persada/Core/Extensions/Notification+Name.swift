//
//  Notification+Name.swift
//  Persada
//
//  Created by Muhammad Noor on 14/06/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let updateIsFollowFromFolowingFolower = Notification.Name("updateIsFollowFromFolowingFolower")
	static let showUploadProgressBar = Notification.Name("showUploadProgressBar")
	static let showOnboardingView = Notification.Name("showOnboardingView")
    static let callbackWhenActiveProduct = Notification.Name("callbackWhenActiveProduct")
    static let notificationUpdateEmail = Notification.Name("com.kipaskipas.emailUpdated")
    static let notificationUpdateProfile = Notification.Name("com.kipaskipas.updateProfile")
    static let notifyRemoveDataAfterDelete = Notification.Name("notifyRemoveDataAfterDelete")
    static let notifyUpdateCounterTransaction = Notification.Name("com.kipaskipas.updateCounterTranssaction")
    static let notifyCounterTransaction = Notification.Name("com.kipaskipas.counterTransaction")
    static let notifyUpdateCounterSocial = Notification.Name("com.kipaskipas.updateCounterSocial")
    static let notifyCounterSocial = Notification.Name("com.kipaskipas.counterSocial")
    static let notifyWillEnterForeground = Notification.Name("com.kipaskipas.notifyWillEnterForeground")
    static let notifyWillEnterForegroundFeed = Notification.Name("com.kipaskipas.notifyWillEnterForegroundFeed")
    static let notifyReloadChannelSearch = Notification.Name("com.kipaskipas.reloadChannelSearchContent")
    static let showOnboardingViewAfterDeleteAccount = Notification.Name("showOnboardingViewAfterDeleteAccount")
    static let refreshTokenFailedToComplete = Notification.Name("refreshTokenFailedToComplete")
    static let pushNotifForkeyboard = Notification.Name("pushNotifForkeyboard")
    static let newsDetailUnivLink = Notification.Name("com.kipaskipas.newsDetailUnivLink")
    static let pushNotifForNewsFeedFeed = Notification.Name(rawValue: "PushNotifForNewsFeedFeed")
    static let pushNotifForNewsId = Notification.Name(rawValue: "PushNotifForNewsID")
    static let pushNotifForLikeFeedId = Notification.Name(rawValue: "PushNotifForLikeFeedID")
    static let pushNotifForCommentId = Notification.Name(rawValue: "PushNotifForCommentID")
    static let pushNotifForLikeCommentId = Notification.Name(rawValue: "PushNotifForLikeCommentID")
    static let pushNotifForSubcommentId = Notification.Name(rawValue: "PushNotifForSubcommentID")
    static let pushNotifForLikeSubcommentId = Notification.Name(rawValue: "PushNotifForLikeSubcommentID")
    static let pushNotifForUserProfileId = Notification.Name(rawValue: "PushNotifForUserProfileID")
    static let pushNotifForWeightAdjustmentId = Notification.Name(rawValue: "PushNotifForWeightAdjustmentID")
    static let pushNotifForBannedProductId = Notification.Name(rawValue: "PushNotifForBannedProductId")
    static let pushNotifForMentionFeedId = Notification.Name(rawValue: "PushNotifForMentionFeedID")
    static let pushNotifForMentionCommentId = Notification.Name(rawValue: "PushNotifForMentionCommentID")
    static let pushNotifForMentionSubcommentId = Notification.Name(rawValue: "PushNotifForMentionSubcommentID")
    static let pushNotifForBuyerShopPaymentPaidId = Notification.Name(rawValue: "PushNotifForBuyerShopPaymentPaidID")
    static let pushNotifForSellerShopPaymentPaidId = Notification.Name(rawValue: "PushNotifForSellerShopPaymentPaidID")
    static let qrNotificationKey = Notification.Name(rawValue: "qrNotificationKey")
    static let handleUpdateExploreContent = NSNotification.Name("handleUpdateExploreContent")
    static let handleUpdateFeed = Notification.Name(rawValue: "com.kipaskipas.updateFeed")
    static let handleReportFeed = Notification.Name(rawValue: "com.kipaskipas.reportFeed")
    static let handleDeleteFeed = Notification.Name(rawValue: "com.kipaskipas.deleteFeed")
    static let updateMyLatestFeed = Notification.Name(rawValue: "com.kipaskipas.updateMyLatestFeed")
    static let handleReportComment = Notification.Name(rawValue: "com.kipaskipas.reportComment")
    static let pushNotifForTrending = Notification.Name(rawValue: "pushNotifForTrending")
    static let pushNotifOutOfStock = Notification.Name(rawValue: "pushNotifOutOfStock")
    static let clearFeedCleepsData = Notification.Name(rawValue: "com.kipaskipas.clearFeedCleepsData")
    static let updateDonationCampaign = Notification.Name(rawValue: "updateDonationCampaign")
    static let updateFollowingTab = Notification.Name(rawValue: "updateFollowingTab")
    static let shouldResumePlayer = Notification.Name(rawValue: "shouldResumePlayer")
    static let shouldPausePlayer = Notification.Name(rawValue: "shouldPausePlayer")
}
