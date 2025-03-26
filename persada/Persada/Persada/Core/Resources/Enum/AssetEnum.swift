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

	//icon
	case arrowleft
	case arrowRight
	case btnAddMedia
	case channel
	case iconAddress
	case iconApple
	case iconbca
	case iconBookmark
	case iconCameraChange
	case iconChannels
	case iconChat
	case iconCheckCircle
	case iconClose
	case iconComment
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
	case iconInvalidInput
	case iconLike
	case iconLocalMall
	case iconLogout
	case iconNavigateNext
	case iconNotif
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
	case iconPersonCircle
	case iconPlus
	case iconPost
	case iconPrivacy
	case iconProfile
	case iconRelogin
	case iconReport
	case iconRetry
	case iconRumahZakat
	case iconSearch
	case iconSetting
	case iconSharealt
	case iconShop
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

	//illustration

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

	case iconButtonShopBrand

	case iconBin
	case iconSwap
    case iconReportSuccess

}
