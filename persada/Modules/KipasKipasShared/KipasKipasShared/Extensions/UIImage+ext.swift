import UIKit
import AVFoundation

public extension UIImage {
    
    private class Resource {}
    
    static var bundle: Bundle {
        return Bundle(for: Resource.self)
    }
    
    struct System {
        public static let boltFill = UIImage(systemName: "bolt.fill")
        public static let boltSlash = UIImage(systemName: "bolt.slash")
        public static let boltBadge = UIImage(systemName: "bolt.badge.a")
        public static let chevronLeft = UIImage(systemName: "chevron.left")
    }
    
    struct Story {
        public static let iconColorPicker = UIImage(named: "Story/icon-color-picker", in: bundle, with: nil)
        public static let iconAlignmentLeft = UIImage(named: "Story/icon-alignment-left", in: bundle, with: nil)
        public static let iconAlignmentCenter = UIImage(named: "Story/icon-alignment-center", in: bundle, with: nil)
        public static let iconAlignmentRight = UIImage(named: "Story/icon-alignment-right", in: bundle, with: nil)
        public static let iconFont = UIImage(named: "Story/icon-font", in: bundle, with: nil)
        public static let iconTrashWhite = UIImage(named: "Story/icon-trash-white", in: bundle, with: nil)
        public static let iconStoryCamera = UIImage(named: "Story/icon-story-camera", in: bundle, with: nil)
        public static let iconX = UIImage(named: "Story/icon-x", in: bundle, with: nil)
        public static let iconShare = UIImage(named: "Story/icon-share", in: bundle, with: nil)
        public static let iconChevronDownSmall = UIImage(named: "Story/icon-chevron-down-small", in: bundle, with: nil)
        public static let iconHeartOutlined = UIImage(named: "Story/icon-heart-outlined", in: bundle, with: nil)
        public static let iconHeartFillRed = UIImage(named: "Story/icon-heart-fill-red", in: bundle, with: nil)
        public static let iconTrashOutlineBlack = UIImage(named: "Story/iconTrashOutlineBlack", in: bundle, with: nil)
        public static let iconSave = UIImage(named: "Story/icon-save", in: bundle, with: nil)
    }
    
    struct LuckyDraw {
        public static let giftBox = UIImage(named: "LuckyDraw/gift-box", in: bundle, with: nil)
        public static let giftBoxDouble = UIImage(named: "LuckyDraw/gift-box-double", in: bundle, with: nil)
        public static let giftBoxHeading = UIImage(named: "LuckyDraw/gift-box-heading", in: bundle, with: nil)
        public static let giftBoxHeartIllustration = UIImage(named: "LuckyDraw/gift-box-heart-illustration", in: bundle, with: nil)
        public static let giftBoxBackground = UIImage(named: "LuckyDraw/gift-box-background", in: bundle, with: nil)
        public static let giftBoxRibbonView = UIImage(named: "LuckyDraw/gift-box-ribbon-view", in: bundle, with: nil)
        public static let giftBoxDisabledButtonBackground = UIImage(named: "LuckyDraw/gift-box-disabled-button-background", in: bundle, with: nil)
        public static let giftBoxEnabledButtonBackground = UIImage(named: "LuckyDraw/gift-box-enabled-button-background", in: bundle, with: nil)
        public static let headingGradientBackground = UIImage(named: "LuckyDraw/heading-gradient-background", in: bundle, with: nil)
        public static let headingGradientGrayBackground = UIImage(named: "LuckyDraw/heading-gradient-gray-background", in: bundle, with: nil)
        public static let notificationGradientBackground = UIImage(named: "LuckyDraw/notification-gradient-background", in: bundle, with: nil)
        public static let iconX = UIImage(named: "LuckyDraw/icon-x", in: bundle, with: nil)
        public static let iconXOutlined = UIImage(named: "LuckyDraw/icon-x-outlined", in: bundle, with: nil)
        public static let iconEnvelope = UIImage(named: "LuckyDraw/icon-envelope", in: bundle, with: nil)
    }
    
    // MARK: A
    static let anonimProfilePhoto = UIImage(named: "anonim-profile-photo", in: bundle, with: nil)
    
    // MARK: B
    static let backgroundDailyRankHeader = UIImage(named: "background-daily-rank-header", in: bundle, with: nil)
    static let backgroundDailyRank1 = UIImage(named: "background-daily-rank-1", in: bundle, with: nil)
    static let backgroundDailyRank2 = UIImage(named: "background-daily-rank-2", in: bundle, with: nil)
    static let backgroundDailyRank3 = UIImage(named: "background-daily-rank-3", in: bundle, with: nil)
    static let boxThumbnailSmall = UIImage(named: "box-thumbnail-small", in: bundle, with: nil)
    static let boxThumbnailBig = UIImage(named: "box-thumbnail-big", in: bundle, with: nil)

    // MARK: D
    static let defaultProfileImage = UIImage(named: "default-profile-image", in: bundle, with: nil)
    static let defaultProfileImageSmall = UIImage(named: "default-profile-image-small", in: bundle, with: nil)
    static let defaultProfileImageLarge = UIImage(named: "default-profile-image-large", in: bundle, with: nil)
    static let defaultProfileImageCircle = UIImage(named: "default-profile-image-circle", in: bundle, with: nil)
    static let defaultProfileImageSmallCircle = UIImage(named: "default-profile-image-small-circle", in: bundle, with: nil)
    static let defaultProfileImageLargeCircle = UIImage(named: "default-profile-image-large-circle", in: bundle, with: nil)
    static let dummyBadge = UIImage(named: "dummy-badge", in: bundle, with: nil)

    // MARK: E
    static let emptyProfilePhoto = UIImage(named: "empty-profile-photo", in: bundle, with: nil)
    
    // MARK: I
    static let iconArrowLeft = UIImage(named: "icon-arrow-left", in: bundle, with: nil)
    static let iconArrowRightGrey = UIImage(named: "arrowRightGrey", in: bundle, with: nil)
    static let iconArrowUpGray = UIImage(named: "icon-arrow-up", in: bundle, with: nil)
    static let iconAudiences = UIImage(named: "icon-audiences", in: bundle, with: nil)
    static let iconCalendar = UIImage(named: "icon-calendar", in: bundle, with: nil)
    static let iconCamera = UIImage(named: "icon-camera", in: bundle, with: nil)
    static let iconCameraRotate = UIImage(named: "icon-camera-rotate", in: bundle, with: nil)
    static let iconCloseWhite = UIImage(named: "icon-close-white", in: bundle, with: nil)
    static let iconCircleX = UIImage(named: "icon-circle-x", in: bundle, with: nil)
    static let iconCircleCheck = UIImage(named: "icon-circle-check", in: bundle, with: nil)
    static let iconCircleCheckGreen = UIImage(named: "icon-circle-check-green", in: bundle, with: nil)
    static let iconCoin = UIImage(named: "icon-coin", in: bundle, with: nil)
    static let iconCommentClose = UIImage(named: "iconCommentClose", in: bundle, with: nil)
    static let iconChart = UIImage(named: "icon-chart", in: bundle, with: nil)
    static let iconCaretDown = UIImage(named: "icon-caret-down", in: bundle, with: nil)
    static let iconCircleQuestion = UIImage(named: "icon-circle-question", in: bundle, with: nil)
    static let iconChevronRightOutlineBlack = UIImage(named: "ic_chevron_right_outline_black", in: bundle, with: nil)
    static let iconDailyRanking = UIImage(named: "icon-daily-ranking", in: bundle, with: nil)
    static let iconDonationCartWhite = UIImage(named: "iconDonationCartWhite", in: bundle, with: nil)
    static let iconPopularLive = UIImage(named: "icon-popular-live", in: bundle, with: nil)
    static let iconDropdownCollapsed = UIImage(named: "icon-dropdown-collapsed", in: bundle, with: nil)
    static let iconDropdownExpanded = UIImage(named: "icon-dropdown-expanded", in: bundle, with: nil)
    static let iconEndLive = UIImage(named: "icon-end-live", in: bundle, with: nil)
    static let iconEyeOpen = UIImage(named: "icon-eye-open", in: bundle, with: nil)
    static let iconEyeClosed = UIImage(named: "icon-eye-closed", in: bundle, with: nil)
    static let iconEyeOutline = UIImage(named: "iconEyeOutLine", in: bundle, with: nil)
    static let iconEyeOffOutline =  UIImage(named: "iconEyeOffOutline", in: bundle, with: nil)
    static let iconFirstTopSeat =  UIImage(named: "icon-first-top-seat", in: bundle, with: nil)
    static let iconGearThin =  UIImage(named: "iconGearThin", in: bundle, with: nil)
    static let iconGift =  UIImage(named: "icon-gift", in: bundle, with: nil)
    static let iconHeart =  UIImage(named: "icon-heart", in: bundle, with: nil)
    static let iconHorizontalElipsisGrey =  UIImage(named: "iconHorizontalElipsisGrey", in: bundle, with: nil)
    static let iconKompas =  UIImage(named: "icon-kompas", in: bundle, with: nil)
    static let iconKebab =  UIImage(named: "iconKebab", in: bundle, with: nil)
    static let iconSecondTopSeat =  UIImage(named: "icon-second-top-seat", in: bundle, with: nil)
    static let iconSearch =  UIImage(named: "icon_search", in: bundle, with: nil)
    static let iconSuperindo =  UIImage(named: "icon_superindo", in: bundle, with: nil)
    static let iconLiveComment = UIImage(named: "icon-live-comment", in: bundle, with: nil)
    static let iconMemberJoined = UIImage(named: "icon-member-joined", in: bundle, with: nil)
    static let iconMemberLiked = UIImage(named: "icon-member-liked", in: bundle, with: nil)
    static let iconMemberWelcome = UIImage(named: "icon-member-welcome", in: bundle, with: nil)
    static let iconMove = UIImage(named: "icon-move", in: bundle, with: nil)
    static let iconNewsExternal = UIImage(named: "iconNewsExternal", in: bundle, with: nil)
    static let iconNewsPaperGray = UIImage(named: "iconNewsPaperGray", in: bundle, with: nil)
    static let iconPen = UIImage(named: "icon-pen", in: bundle, with: nil)
    static let iconPlus = UIImage(named: "icon-plus", in: bundle, with: nil)
    static let iconFollowed = UIImage(named: "icon_followed", in: bundle, with: nil)
    static let iconLove = UIImage(named: "ic_love", in: bundle, with: nil)
    static let btnFollow = UIImage(named: "btn_follow", in: bundle, with: nil)
    static let iconMedal = UIImage(named: "icon-medal", in: bundle, with: nil)
    static let iconQuestion = UIImage(named: "icon-question", in: bundle, with: nil)
    static let iconReactionLike =  UIImage(named: "icon-reaction-like", in: bundle, with: nil)
    static let iconSend =  UIImage(named: "ic_send", in: bundle, with: nil)
    static let iconSendNormal =  UIImage(named: "ic_send_normal", in: bundle, with: nil)
    static let iconLaugh =  UIImage(named: "ic_laugh", in: bundle, with: nil)
    static let iconVector =  UIImage(named: "ic_vector", in: bundle, with: nil)
    static let iconDeleteLeft =  UIImage(named: "icon_delete_left", in: bundle, with: nil)
    static let iconUser =  UIImage(named: "icon-user", in: bundle, with: nil)
    static let iconUserOutline =  UIImage(named: "icon-user-outline", in: bundle, with: nil)
    static let iconVerified =  UIImage(named: "icon-verified", in: bundle, with: nil)
    static let iconVideo =  UIImage(named: "iconVideo", in: bundle, with: nil)
    static let iconTopOne =  UIImage(named: "icon-top-one", in: bundle, with: nil)
    static let iconTopTwo =  UIImage(named: "icon-top-two", in: bundle, with: nil)
    static let iconTickActive =  UIImage(named: "icon-tick-active", in: bundle, with: nil)
    static let iconTickInactive =  UIImage(named: "icon-tick-inactive", in: bundle, with: nil)
    static let iconTopThree =  UIImage(named: "icon-top-three", in: bundle, with: nil)
    static let iconWarningRed =  UIImage(named: "icon-warning-red", in: bundle, with: nil)
    static let navBgDaily =  UIImage(named: "nav_bg_daily", in: bundle, with: nil)
    static let navBgLive =  UIImage(named: "nav_bg_live", in: bundle, with: nil)
    static let iconRankingBadge =  UIImage(named: "icon_ranking_badge", in: bundle, with: nil)
    static let iconTrashFillGrey =  UIImage(named: "iconTrashFillGrey", in: bundle, with: nil)
    static let iconRight =  UIImage(named: "icon-right", in: bundle, with: nil)
    static let iconFlag =  UIImage(named: "ic_flag", in: bundle, with: nil)
    static let iconBadge =  UIImage(named: "icon-badge", in: bundle, with: nil)
    static let iconMember =  UIImage(named: "icon-member", in: bundle, with: nil)
    static let iconRemind =  UIImage(named: "icon-remind", in: bundle, with: nil)
    static let btnDefault =  UIImage(named: "button_default", in: bundle, with: nil)
    static let iconShareWithe =  UIImage(named: "ic_share_white", in: bundle, with: nil)
    static let iconRotate =  UIImage(named: "icon-rotate", in: bundle, with: nil)
    static let iconSms =  UIImage(named: "icon-sms", in: bundle, with: nil) 
    static let iconShopComingSoon =  UIImage(named: "iconShopComingSoon", in: bundle, with: nil)
    static let iconYayasan =  UIImage(named: "icon_yayasan", in: bundle, with: nil)
    static let iconWarningWhite =  UIImage(named: "icon-warning-white", in: bundle, with: nil)
    static let iconWhatsapp =  UIImage(named: "icon-whatsapp", in: bundle, with: nil)
    static let illustrationDoubleLogin = UIImage(named: "illustration-double-login", in: bundle, with: nil)
    static let illustrationStopHand = UIImage(named: "illustration-stop-hand", in: bundle, with: nil)
    static let illustrationThumbOk = UIImage(named: "illustration-thumb-ok", in: bundle, with: nil)
    static let illustrationGiftError = UIImage(named: "illustration-gift-error", in: bundle, with: nil)
    static let illustrationTrophy = UIImage(named: "illustration-trophy", in: bundle, with: nil)
    static let illustrationVideoCamera = UIImage(named: "illustration-video-camera", in: bundle, with: nil)
    static let illustrationTart = UIImage(named: "illustration-tart", in: bundle, with: nil)
    static let imgProgress = UIImage(named: "img_in_progress", in: bundle, with: nil)
    static let imageLockBox = UIImage(named: "imageLockBox", in: bundle, with: nil)
    static let iconList = UIImage(named: "iconList", in: bundle, with: nil)
    
    // MARK: L
    static let loginHeader =  UIImage(named: "LoginHeader", in: bundle, with: nil)
    
    // MARK: P
    static let placeholderBackground =  UIImage(named: "placeholder-background", in: bundle, with: nil)
    static let personMale =  UIImage(named: "person-male", in: bundle, with: nil)
    static let personFemale =  UIImage(named: "person-female", in: bundle, with: nil)
    static let personMaleFemale =  UIImage(named: "person-male-female", in: bundle, with: nil)
    static let paymentHeaderBackground = UIImage(named: "payment-header-background", in: bundle, with: nil)
    
    // MARK: R
    static let rankBadge = UIImage(named: "rank-badge", in: bundle, with: nil)
    static let rankDowngrade = UIImage(named: "rank-downgrade", in: bundle, with: nil)
    static let rankUpgrade = UIImage(named: "rank-upgrade", in: bundle, with: nil)
    static let ribbonRank1 = UIImage(named: "ribbon-rank-1", in: bundle, with: nil)
    static let ribbonRank2 = UIImage(named: "ribbon-rank-2", in: bundle, with: nil)
    static let ribbonRank3 = UIImage(named: "ribbon-rank-3", in: bundle, with: nil)
    static let ribbonRankGlobal = UIImage(named: "ribbon-rank-global", in: bundle, with: nil)
    
    static let iconBack = UIImage(named: "icon-back", in: bundle, with: nil)
    static let iconChevronLeft = UIImage(named: "icon-chevron-left", in: bundle, with: nil)
    static let iconChevronLeftOutlineBlack = UIImage(named: "ic_chevron_left_outline_black", in: bundle, with: nil)
    static let iconArrowLeftCircleBlack = UIImage(named: "icon-arrow-left-circle-black", in: bundle, with: nil)
    static let iconArrowLeftCircleWhite = UIImage(named: "icon-arrow-left-circle-white", in: bundle, with: nil)
    
    static let iconActivities = UIImage(named: "ic_activities", in: bundle, with: nil)
    static let iconFollower = UIImage(named: "ic_follower", in: bundle, with: nil)
    static let iconSystem = UIImage(named: "ic_system", in: bundle, with: nil)
    static let iconTransaction = UIImage(named: "ic_transaction", in: bundle, with: nil)
    static let iconTransactionItem = UIImage(named: "iconTransactionItem", in: bundle, with: nil)
    static let iconTransactionEmpty = UIImage(named: "iconTransactionEmpty", in: bundle, with: nil)
    static let iconPersonOutlineGrey = UIImage(named: "ic_person_outline_grey", in: bundle, with: nil)
    
    static let iconCommentFillBlue = UIImage(named: "ic_comment_fill_blue", in: bundle, with: nil)
    static let iconLikeFillPink = UIImage(named: "ic_like_fill_pink", in: bundle, with: nil)
    static let iconMentionFillYellow = UIImage(named: "ic_mention_fill_yellow", in: bundle, with: nil)
    static let iconPlusFillGradientBlue = UIImage(named: "ic_plus_fill_gradient_blue", in: bundle, with: nil)
    static let iconRefreshBlack = UIImage(named: "ic_refresh_black", in: bundle, with: nil)
    static let imageNoActivityOutlineGrey = UIImage(named: "img_no_activity_outline_grey", in: bundle, with: nil)
    static let iconUserOutlineGrey = UIImage(named: "ic_user_outline_grey", in: bundle, with: nil)
    static let iconInfoOutlineGrey = UIImage(named: "ic_info_outline_grey", in: bundle, with: nil)
    
    static let iconLiveSolidBlack = UIImage(named: "ic_live_solid_black", in: bundle, with: nil)
    static let iconSosialSolidBlack = UIImage(named: "ic_sosial_solid_black", in: bundle, with: nil)
    static let iconUpdateSolidBlack = UIImage(named: "ic_update_solid_black", in: bundle, with: nil)
    static let iconBoxOutlineGrey = UIImage(named: "ic_box_outline_grey", in: bundle, with: nil)
    static let iconCircleCloseFillRed = UIImage(named: "ic_circle_close_fill_red", in: bundle, with: nil)
    static let iconClockFillGray = UIImage(named: "ic_clock_fill_gray", in: bundle, with: nil)
    
    // Story Badge
    static let iconBadgeAdd = UIImage(named: "iconBadgeAdd", in: bundle, with: nil)
    static let iconBadgeLive = UIImage(named: "iconBadgeLive", in: bundle, with: nil)
    static let iconBadgeRetry = UIImage(named: "iconBadgeRetry", in: bundle, with: nil)
    
	
    func fixedOrientation() -> UIImage? {
        guard imageOrientation != UIImage.Orientation.up else {
            // This is default orientation, don't need to do anything
            return self.copy() as? UIImage
        }
        
        guard let cgImage = self.cgImage else {
            // CGImage is not available
            return nil
        }
        
        guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil // Not able to create CGContext
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
        case .up, .upMirrored:
            break
        @unknown default:
            break
        }
        
        // Flip image one more time if needed to, this is to prevent flipped image
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            break
        }
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }
        
        guard let newCGImage = ctx.makeImage() else { return nil }
        return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .up)
    }
}

public extension UIImage {
    func resizeImage(scale: CGFloat) -> UIImage {
        let newSize = CGSize(width: self.size.width*scale, height: self.size.height*scale)
        let rect = CGRect(origin: CGPoint.zero, size: newSize)

        UIGraphicsBeginImageContext(newSize)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    static func videoThumbnail(_ path: String) -> UIImage? {
        do {
            let url = URL(fileURLWithPath: path)
            let asset = AVURLAsset(url: url, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
}
