//
//  AssetEnum.swift
//  KipasKipasShared
//
//  Created by Rahmat Trinanda Pramudya Amar on 13/11/23.
//

import Foundation

enum AssetEnum: String {
    /*
     Everytime you put new asset with new prefix, please update index too
     Index
     - AppIcon
     - ic = icon
     + universal
     - ill = illustration
     + universal
     - img = image
     + special
     - logo
     
     Format: prefix_component (Akronim & camel case)_Color/Purpose/Size/Feature_Section/Area
     */
    
    //AppIcon (universal)
    case AppIcon
    
    //Bottom Navbar new icon
    case iconHomeActiveLight
    case iconHomeActiveDark
    case iconHomeIdleLight
    case iconNotifActiveLight
    case iconNotifIdleDark
    case iconNotifIdleLight
    case iconPostIdleDark
    case iconPostIdleLight
    case iconProfileActiveLight
    case iconProfileIdleDark
    case iconProfileIdleLight
    case iconShopActiveLight
    case iconShopIdleDark
    case iconShopIdleLight
    
    //icon
    case arrowLeftWhiteBlackBg = "arrow_left_white_black_bg"
    case arrowleft
    case arrowLeftBlack = "arrow_left_black"
    case arrowLeftWhite
    case arrowRight
    case btnAddMedia
    case channel
    case iconAddress
    case iconAddStory
    case iconApple
    case iconbca
    case iconBookmark
    case iconCamera
    case iconCameraClose
    case iconCameraChange
    case iconChannels
    case iconChat
    case iconCheckCircle
    case iconClose
    case iconComment
    case iconComponent
    case iconCompletedWithdrawGopay
    case iconConfirm
    case iconDM
    case iconDocument
    case iconEllipsis
    case iconEyeOffOutline
    case iconEyeOutLine
    case iconFacebook
    case iconFeatherSend
    case iconFeatherSendGray
    case iconGoogle
    case iconHeart
    case iconHome
    case iconHomeActive
    case iconImage
    case iconInvalidInput
    case iconSuccess
    case iconLike
    case iconLocalMall
    case iconLogout
    case iconNavigateNext
    case iconNotif
    case iconNotifActive
    case iconNotifComment
    case iconNotifLike
    case iconNotifMention
    case iconStatusTransaksi
    case iconNotifPlus
    case iconOneOneRatio
    case iconFiveOnFourRatio
    case iconSixteenOnNineRatio
    case iconOneOneRatioOn
    case iconFiveOnFourRatioOn
    case iconSixteenOnNineRatioOn
    case iconPerson
    case iconPersonBig
    case iconPersonCircle
    case iconPersonWithCornerRadius
    case iconPlus
    case iconPost
    case iconPrivacy
    case iconProduct
    case iconProductLocation
    case iconProductReseller
    case iconProductStarEmpty
    case iconProductStarFill
    case iconProfile
    case iconProfileActive
    case iconProfileEmpty
    case iconProfileVerified
    case iconRedDot
    case iconRelogin
    case iconReport
    case iconKebab
    case iconKebabEllipsis
    case iconRetry
    case iconRumahZakat
    case iconBack
    case iconEmptySearchProduct
    case iconSendMessage
    case iconSearch
    case iconSearchCategory
    case iconSearchNavigation
    case iconDMPaid
    case iconSearchNavigationActive
    case iconSetting
    case iconSharealt
    case iconShop
    case iconShopNew
    case icshopnew = "ic_shop_new"
    case iconVerified
    case iconVideoPlayerPlay
    case Kipaskipas
    case redFlag
    case search
    case selectedItem
    case star
    case iconCommentVideo
    case iconCommentClose
    case iconLoveVideo
    case iconShareVideo
    case iconCheckboxChecked
    case iconCheckboxUncheck
    case iconPersonGirl
    case iconPersonGirlFill
    case iconPersonGuy
    case iconPersonGuyFill
    case iconPersonUnknown
    case iconPersonUnknownFill
    case iconPinPoint
    case iconPinPointQuestionMark
    case iconCheckboxCheckedGreen
    case iconCheckboxUncheckGreen
    case iconCheckboxCheckedBlue
    case iconUncheckRad4
    case iconRightArrow
    case iconRadioButtonChecked
    case iconRadioButtonUncheck
    case iconFavorite
    case iconSort
    case iconFilter
    case iconQR
    case iconCaptureImage
    
    case iconNotFoundBold
    case iconEmptyBold
    case iconNotFoundSoft
    case iconPlay = "play"
    case iconPlayWithoutBackground = "ic_play_without_background"
    //illustration
    case iconInsurance
    
    //universal illustration part
    
    //image (universal)
    case img_launchscreen
    case imgLaunchScreen
    case registerBG
    case empty
    case splashBG
    case divider
    case images
    case LoginBG
    
    case iconSicepat
    case iconJNE
    case iconJNT
    case iconAnterAja
    
    case iconButtonShopBrand
    
    case iconBin
    case iconSwap
    case iconReportSuccess
    
    case chevronDown = "chevron.down"
    case magnifyingglass = "magnifyingglass"
    
    case imgMyStory
    
    case iconDownload
    
    case imageMaps
    case imageMapsEmpty
    case iconPinPointMaps
    case iconCornerShopping
    case iconCornerStack
    case iconCornerVideo
    case iconDonationWhite = "ic_donation_white"
    
    case iconBNIBank
    case iconBRIBank
    case iconPermataBank
    case iconMandiriBank
    case iconBankLain
    
    case iconArchiveBox
    case iconAttach
    case iconTrashGrey
    case iconGroup
    case iconCommentSmall
    
    case iconStore
    case iconCar
    
    
    case iconActiveInstagram
    case iconActiveTiktok
    case iconActiveWikipedia
    case iconNonActiveFacebook
    case iconActiveFacebook
    case iconNonActiveTwitter
    case iconActiveTwitter
    case iconNonActiveInstagram
    case iconNonActiveTiktok
    case iconNonActiveWikipedia
    
    case iconTiktokLike
    case iconTiktokLikeActive
    case iconTiktokComment
    case iconTiktokShare
    
    case wikipedia
    
    case iconWA
    case iconWA_white
    
    case iconCloseWhite
    case iconInfo
    case iconGroupChat
    
    case iconHomeWhite
    case iconHighPriority
    case iconWhatsapp
    case iconFB
    case iconIG
    case iconShareDownload
    case iconShareLink
    case iconShareReport
    case iconShareDelete
    case iconShareMore
    case iconKipasKipas
    case iconPrinter
    case ic_check
    case ic_refresh
    case iconThumbUp
    
    case iconCommentLikeDisabled
    case iconCommentLikeEnabled
    case iconProfilePlaceholder
    case iconProcWithdrawGopay
    case iconCommentSend
    
    case iconAnotherReport
    case iconAnotherBlock
    case iconAnotherMessage
    case iconInfoProduct
    case iconRightGray
    case iconStatusTransactionFill = "icon_status_transaction_fill"
    case imageCart
    
    case iconResellerProductEmpty
    case iconWarningRhombus
    case iconWrong
    case iconLinkGrey
    case iconLinkWhite
}
