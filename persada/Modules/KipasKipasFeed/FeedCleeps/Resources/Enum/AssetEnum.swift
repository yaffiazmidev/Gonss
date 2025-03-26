//
//  StringConstans.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 28/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

enum AssetEnum : String {
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
    case iconNewsExternal
    
	//icon
	case arrowleft
	case arrowRight
	case btnAddMedia
	case channel
	case iconAddress
    case iconAddStory
	case iconApple
	case iconbca
	case iconBookmark
	case iconCameraChange
	case iconChannels
	case iconChat
	case iconCheckCircle
	case iconClose
	case iconComment
    case iconComponent
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
	case iconPlus
	case iconPost
	case iconPrivacy
	case iconProduct
	case iconProfile
    case iconProfileActive
	case iconRelogin
	case iconReport
	case iconKebab
    case iconKebabEllipsis
    case iconKebabHorizontal
	case iconRetry
	case iconRumahZakat
	case iconBack
	case iconSearch
    case iconSearchNavigation
    case iconSearchNavigationActive
	case iconSetting
	case iconSharealt
	case iconShop
    case iconShopNew
	case iconVerified
	case iconVideoPlayerPlay
	case Kipaskipas
	case redFlag
	case search
	case selectedItem
	case star
	case iconCommentVideo
	case iconLoveVideo
	case iconShareVideo
	case iconCheckboxChecked
	case iconCheckboxUncheck
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
	case iconPersonWithCornerRadius
    
    case iconNotFoundBold
    case iconEmptyBold
    case iconNotFoundSoft
    case iconPlay = "play"
	//illustration
	case iconInsurance

	//universal illustration part

	//image (universal)
	case img_launchscreen
	case imgLaunchScreen
	case registerBG
	case empty
    case PotraitPlaceholder
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
    
    case iconBNIBank
    case iconBRIBank
    case iconPermataBank
    case iconMandiriBank
    case iconBankLain
    
    case iconArchiveBox
	case iconAttach
    case iconTrashGrey
    case iconGroup
	case iconGroupFillWhite
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
    case iconHomeWhite
    case iconWhatsapp
    case iconFB
    case iconIG
    case iconShareDownload
    case iconShareLink
    case iconShareMore
    case iconKipasKipas
    case iconPrinter
    case iconWrong
    case iconLinkGrey
    case iconLinkWhite
    case iconCloseCircle
    case iconProfilePlaceholder
    case iconLinkPlaceholder
    
    case iconDonationCartWhite
    case iconDonationCartPink
    case iconDonationCartAddPink
    
    case iconLikeSolidBorderWhite = "ic_like_solid_border_white"
    case iconCommentSolidBorderWhite = "ic_comment_solid_border_white"
    case iconBookmarkSolidBorderWhite = "ic_bookmark_solid_border_white"
    case iconShareSolidBorderWhite = "ic_share_solid_border_white"
    
    case iconLikeSolidWhite = "ic_like_solid_white"
    case iconCommentSolidWhite = "ic_comment_solid_white"
    case iconBookmarkSolidWhite = "ic_bookmark_solid_white"
    case iconShareSolidWhite = "ic_share_solid_white"
}
