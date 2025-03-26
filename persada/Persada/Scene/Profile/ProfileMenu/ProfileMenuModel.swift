//
//  ProfileMenuModel.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 10/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import Foundation

enum ProfileMenuModel {

	enum Request {
		case doSomething(item: Int)
	}

	enum Response {
		case doSomething(newItem: Int, isItem: Bool)
	}

	enum ViewModel {
		case doSomething(viewModelData: NSObject)
	}

	enum Route {
		case dismiss(id: String, showNavBar: Bool)
		case navigateToProfileSettingAccount
		case navigateToProfileEdit(id: String)
		case navigateToRekeningSaya
        case navigateToWithdrawDiamondDiamond
        case navigateToTopUpCoin
		case navigateToSetDiamond
		case navigateToTnC
        case navigateToPrivacyPolicy
		case navigateToMyAddress
		case dismissToLogin
		case xScene(xData: Int)
        case navigateToFundraising
	}

	struct DataSource: DataSourceable {
		var id: String
		var items: [ProfileSettings] = []
		var showNavBar: Bool
		var isVerified: Bool
        var accountType: String

        init(id: String, showNavBar: Bool, isVerified: Bool, accountType: String) {
			self.id = id
			self.showNavBar = showNavBar
			self.isVerified = isVerified
            self.accountType = accountType
			literateData()
		}

		mutating func literateData(){
            items = ProfileSettings.allCases
            if isVerified == false {
                items.removeAll(where: {$0 == .setDiamond})
            }
            
            if accountType != "INITIATOR" {
                items.removeAll(where: {$0 == .fundraising })
            }
		}
	}
}

enum ProfileSettings: String, CaseIterable {

	//ACTION TEXT::ACTION ICON

	case changeProfile = "Ubah Profil::ic_profile_gray"
	case accountSetting = "Pengaturan Akun::ic_profile_setting_gray"
	case myAddress = "Alamat Saya::ic_pinpoint_gray"
//	case verifiedRequest = "Permintaan Akun Verified::iconCheckCircle"
    case myAccount = "Rekening Saya::ic_money_gray"
    case fundraising = "Penggalangan dana::ic_donation_gray"
    case badge = "Badge Donasi::ic_donation_badge"
    case withdrawDiamond = "Tarik Diamond::iconWithdrawDiamond"
    case topUpCoin = "Top-Up Koin::iconTopUpCoin"
	case setDiamond = "Pengaturan Pesan Berbayar::ic_dm_gray"
    case lottery = "Undian::gift"
    case lotteryInitiation = "Inisiasi Undian::"
    case lotteryHistory = "Riwayat Undian::"
	case divider = "::divider"
//	case applicationSetting = "Pengaturan Aplikasi::iconSetting"
//    case notificationSetting = "Notifikasi::ic_notification_gray"
    case accessOrPermission = "Akses / Perizinan Aplikasi::ic_permission"
	case tnc = "Syarat & Ketentuan::ic_write_doc_gray"
	case privacy = "Kebijakan Privasi::ic_shield_profile_gray"
    case sendFeedback = "Kirim Feedback::ic_paperplane_grey"
    case sendLogs = "Kirim Log::iconLog"
	case logout = "Log Out::ic_logout_gray"
//    case blankSpace = "::"
//    case sendFeedback = "Kirim Feedback::"
    
    var isLotteryExpand: Bool {
        switch self {
        case .lotteryInitiation, .lotteryHistory:
            return false
        default:
            return true
        }
    }
}
