import UIKit
import KipasKipasShared
import KipasKipasDirectMessage
import KipasKipasDirectMessageUI

enum PushNotificationDestination {
    case profile(username: String?, userId: String?)
    case singleFeed(feedId: String?)
    case donationTransaction(orderId: String)
    case donationDetail(donationId: String)
    case live
}

protocol PushNotificationManagerDelegate: AnyObject {
    func showToast(message: String)
    func navigate(to destination: PushNotificationDestination)
}

class PushNotificationManager {
    
    var object: [String: Any]?

    weak var delegate: PushNotificationManagerDelegate?
    
    private let timestampStorage: TimestampStorage = TimestampStorage()
    
    func handleNotification(object: [String: Any]?) {
        self.object = object
        
        guard let customObject = self.object else {
            return
        }
        
        if let notifFrom = customObject["notif_from"] as? String {
            if ( notifFrom == "news") {
                handleNotifNews(customObject: customObject)
            }
            
            if ( notifFrom == "social")  {
                handleNotifSocial(customObject: customObject)
            }
            
            if ( notifFrom == "shopping") {
                handleNotifShopping(customObject: customObject)
            }
            
            if (notifFrom == "chat") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.handleDirectMessageNotification(customObject)
                }
            }
            
            if (notifFrom == "donation") {
                handleDonationNotification(customObject)
            }
            
            if (notifFrom == "live") {
                handleNotifFromLive()
            }
            
        } else {
            handleNotifSocial(customObject: customObject)
        }
     
    }
    
    private func handleNotifFromLive() {
        delegate?.navigate(to: .live)
    }
    
    private func handleDonationNotification(_ object: [String: Any]) {
        if let type = object["notif_shop_type"] as? String {
            if let orderId = object["target_shop_id"] as? String, (type == "donation_unpaid") {
                delegate?.navigate(to: .donationTransaction(orderId: orderId))
            }
        }
        
        if let type = object["notif_push_donation_type"] as? String {
            if let donationId = object["target_donation_id"] as? String, (type == "push_donation") {
                delegate?.navigate(to: .donationDetail(donationId: donationId))
            }
        }
    }
    
    private func handleDirectMessageNotification(_ object: [String: Any]) {
        guard let senderId = object["sender_account_id"] as? String, !senderId.isEmpty else {
            delegate?.showToast(message: "User not found")
            return
        }
        let name: String = object["sender_name"] as? String ?? ""
        let avatar = object["sender_image_url"] as? String ?? ""
        let isVerify = object["sender_is_verified"] as? Bool ?? false
        
        let user = TXIMUser(userID: senderId, userName: name, faceURL: avatar, isVerified: isVerify)
        showIMConversation?(user)
    }
    
    private func handleNotifNews(customObject: [String: Any]) {
        if let notifNewsType = object?["notif_social_type"] as? String {
            if (notifNewsType == "like_feed") {
                
                let postId: String = customObject["feed_id"] as! String
                let dataSource = CommentModel.DataSource()
                dataSource.id = postId
                dataSource.postId = postId
                
                NotificationCenter.default.post(name: .pushNotifForLikeFeedId, object: nil, userInfo: ["NotifForCommentID" : dataSource])
            }    else if ( notifNewsType == "comment_feed" ) {
                let postId: String = customObject["feed_id"] as! String
                let dataSource = CommentModel.DataSource()
                dataSource.id = postId
                dataSource.postId = postId
                
                NotificationCenter.default.post(name: .pushNotifForCommentId, object: nil, userInfo: ["NotifForFeedID": dataSource])
            } else if (notifNewsType == "like_comment") {
                let postId: String = customObject["feed_id"] as! String
                let dataSource = CommentModel.DataSource()
                dataSource.id = postId
                dataSource.postId = postId
                
                NotificationCenter.default.post(name: .pushNotifForLikeCommentId, object: nil, userInfo: ["NotifForLikeFeedID": dataSource])
            } else if (notifNewsType == "mention_feed") {
                let postId: String = customObject["feed_id"] as! String
                let dataSource = CommentModel.DataSource()
                dataSource.id = postId
                dataSource.postId = postId
                
                NotificationCenter.default.post(name: .pushNotifForMentionFeedId, object: nil, userInfo: ["NotifForMentionFeedID": dataSource])
            } else if (notifNewsType == "mention_comment") {
                let postId: String = customObject["feed_id"] as! String
                let dataSource = CommentModel.DataSource()
                dataSource.id = postId
                dataSource.postId = postId
                
                NotificationCenter.default.post(name: .pushNotifForMentionCommentId, object: nil, userInfo: ["NotifForMentionCommentID": dataSource])
            } else if ( notifNewsType == "mention_commentSub" ) {
                let postId: String = customObject["target_social_id"] as! String
                let feedId: String = customObject["feed_id"] as! String
                let dataSource = SubcommentModel.DataSource()
                dataSource.id = postId
                dataSource.postId = feedId
                
                NotificationCenter.default.post(name: .pushNotifForMentionSubcommentId, object: nil, userInfo: ["NotifForMentionSubcommentID": dataSource])
            } else if ( notifNewsType == "commentSub_feed" ) {
                let postId: String = customObject["target_social_id"] as! String
                let feedId: String = customObject["feed_id"] as! String
                let dataSource = SubcommentModel.DataSource()
                dataSource.id = postId
                dataSource.postId = feedId
                
                NotificationCenter.default.post(name: .pushNotifForSubcommentId, object: nil, userInfo: ["NotifForSubcommentID": dataSource])
            }    else if ( notifNewsType == "like_commentSub" ) {
                let postId: String = customObject["target_social_id"] as! String
                let feedId: String = customObject["feed_id"] as! String
                let dataSource = SubcommentModel.DataSource()
                dataSource.id = postId
                dataSource.postId = feedId
                
                NotificationCenter.default.post(name: .pushNotifForLikeSubcommentId, object: nil, userInfo: ["NotifForLikeSubcommentID": dataSource])
            }    else if ( notifNewsType == "follow_account" ) {
                let username: String = customObject["username"] as! String
                
                delegate?.navigate(to: .profile(username: username, userId: nil))
                
            }   else if ( notifNewsType == "feed_news_daily" ) {
                let newsId: String = customObject["target_social_id"] as! String
                
                NotificationCenter.default.post(name: .pushNotifForNewsId, object: nil, userInfo: ["NotifForNewsTypeID": newsId])
            }
        }
    }
    
    private func handleNotifSocial(customObject: [String: Any]) {
        if let notifSocialType = object?["notif_social_type"] as? String {
            if notifSocialType == "like_feed" {
                
                let postId: String = customObject["feed_id"] as! String
                let dataSource = CommentModel.DataSource()
                dataSource.id = postId
                dataSource.postId = postId
                
//                NotificationCenter.default.post(name: .pushNotifForLikeFeedId, object: nil, userInfo: ["NotifForCommentID" : dataSource])
                delegate?.navigate(to: .singleFeed(feedId: postId))
            }    else if ( notifSocialType == "comment_feed" ) {
                let postId: String = customObject["feed_id"] as! String
                let dataSource = CommentModel.DataSource()
                dataSource.id = postId
                dataSource.postId = postId
                
//                NotificationCenter.default.post(name: .pushNotifForCommentId, object: nil, userInfo: ["NotifForFeedID": dataSource])
                delegate?.navigate(to: .singleFeed(feedId: postId))
            } else if (notifSocialType == "like_comment") {
                let postId: String = customObject["feed_id"] as! String
                let dataSource = CommentModel.DataSource()
                dataSource.id = postId
                dataSource.postId = postId
                
//                NotificationCenter.default.post(name: .pushNotifForLikeCommentId, object: nil, userInfo: ["NotifForLikeFeedID": dataSource])
                delegate?.navigate(to: .singleFeed(feedId: postId))
            } else if (notifSocialType == "mention_feed") {
                let postId: String = customObject["feed_id"] as! String
                let dataSource = CommentModel.DataSource()
                dataSource.id = postId
                dataSource.postId = postId
                
//                NotificationCenter.default.post(name: .pushNotifForMentionFeedId, object: nil, userInfo: ["NotifForMentionFeedID": dataSource])
                delegate?.navigate(to: .singleFeed(feedId: postId))
            } else if (notifSocialType == "mention_comment") {
                let postId: String = customObject["feed_id"] as! String
                let dataSource = CommentModel.DataSource()
                dataSource.id = postId
                dataSource.postId = postId
                
//                NotificationCenter.default.post(name: .pushNotifForMentionCommentId, object: nil, userInfo: ["NotifForMentionCommentID": dataSource])
                delegate?.navigate(to: .singleFeed(feedId: postId))
            } else if ( notifSocialType == "mention_commentSub" ) {
                let postId: String = customObject["target_social_id"] as! String
                let feedId: String = customObject["feed_id"] as! String
                let dataSource = SubcommentModel.DataSource()
                dataSource.id = postId
                dataSource.postId = feedId
                
//                NotificationCenter.default.post(name: .pushNotifForMentionSubcommentId, object: nil, userInfo: ["NotifForMentionSubcommentID": dataSource])
                delegate?.navigate(to: .singleFeed(feedId: postId))
            } else if ( notifSocialType == "commentSub_feed" ) {
                let postId: String = customObject["target_social_id"] as! String
                let feedId: String = customObject["feed_id"] as! String
                let dataSource = SubcommentModel.DataSource()
                dataSource.id = postId
                dataSource.postId = feedId
                
//                NotificationCenter.default.post(name: .pushNotifForSubcommentId, object: nil, userInfo: ["NotifForSubcommentID": dataSource])
                delegate?.navigate(to: .singleFeed(feedId: postId))
            }    else if ( notifSocialType == "like_commentSub" ) {
                let postId: String = customObject["target_social_id"] as! String
                let feedId: String = customObject["feed_id"] as! String
                let dataSource = SubcommentModel.DataSource()
                dataSource.id = postId
                dataSource.postId = feedId
                
//                NotificationCenter.default.post(name: .pushNotifForLikeSubcommentId, object: nil, userInfo: ["NotifForLikeSubcommentID": dataSource])
                delegate?.navigate(to: .singleFeed(feedId: postId))
            } else if ( notifSocialType == "follow_account" ) {
//                let postId: String = customObject["username"] as! String
//                
//                NotificationCenter.default.post(name: .pushNotifForUserProfileId, object: nil, userInfo: ["NotifForUserProfileID": postId])

                let userId: String = customObject["target_account_id"] as! String
                
                delegate?.navigate(to: .profile(username: nil, userId: userId))
            } else if notifSocialType == "content_daily" {
                let feedID: String = customObject["feed_id"] as! String
                
                NotificationCenter.default.post(name: .pushNotifForTrending, object: nil, userInfo: ["feedID" : feedID])
            } else if ( notifSocialType == "default_message") {
                print("Default Message")
            }
            
        }
    }
    
    private func handleNotifShopping(customObject: [String: Any]) {
        if let notifShopType = object?["notif_shop_type"] as? String {
            if object?["account_shop_type"] as? String == "buyer" {
                if ( notifShopType == "shop_payment_paid") {
                    var dataSource = DetailTransactionModel.DataSource()
                    let postId: String = customObject["target_shop_id"] as! String
                    dataSource.id = postId
                    dataSource.data = nil
                    dataSource.dataTransaction = nil
                    
                    NotificationCenter.default.post(name: .pushNotifForBuyerShopPaymentPaidId, object: nil, userInfo: ["PushNotifForBuyerShopPaymentPaidID": dataSource])
                }
            } else if ( object?["account_shop_type"] as? String == "seller" ) {
                if notifShopType == "shop_shipment_weightadj" {
                    let id: String = customObject["target_shop_id"] as! String
                    NotificationCenter.default.post(name: .pushNotifForWeightAdjustmentId, object: nil, userInfo: ["NotifForWeightAdjutmentID": id])
                } else if ( notifShopType == "shop_payment_paid") {
                    var dataSource = DetailTransactionModel.DataSource()
                    let postId: String = customObject["target_shop_id"] as! String
                    dataSource.id = postId
                    
                    NotificationCenter.default.post(name: .pushNotifForSellerShopPaymentPaidId, object: nil, userInfo: ["PushNotifForSellerShopPaymentPaidID": dataSource])
                } else if notifShopType == "product_banned" {
                    let id: String = customObject["target_shop_id"] as! String
                    NotificationCenter.default.post(name: .pushNotifForBannedProductId, object: nil, userInfo: ["NotifForBannedProductID": id])
                }else if notifShopType == "shop_out_of_stock_product"{
                    let id: String = customObject["target_shop_id"] as! String
                    NotificationCenter.default.post(name: .pushNotifOutOfStock, object: nil, userInfo: ["NotifForOutOfStock": id])
                }
            }
        }
    }
}
