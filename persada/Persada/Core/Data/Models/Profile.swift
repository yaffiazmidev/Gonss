//
//  Profile.swift
//  Persada
//
//  Created by Muhammad Noor on 05/05/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

// MARK: - Profile
struct ProfileResult : Codable {

	let code : String?
	let data : Profile?
	let message : String?

	enum CodingKeys: String, CodingKey {
		case code = "code"
		case data = "data"
		case message = "message"
	}
}

// MARK: - Profile
struct Profile : Codable {
    init(accountType: String? = nil, bio: String? = nil, email: String? = nil, id: String? = nil, isFollow: Bool? = nil, birthDate: String? = nil, note: String? = nil, isDisabled: Bool? = nil, isSeleb: Bool? = nil, isVerified: Bool? = nil, mobile: String? = nil, name: String? = nil, photo: String? = nil, username: String? = nil, isSeller: Bool? = nil, socialMedias: [SocialMedia]? = nil, donationBadge: DonationBadge? = nil, referralCode: String? = nil, urlBadge: String? = nil, isShowBadge: Bool? = nil, chatPrice: Int? = nil) {
        self.accountType = accountType
        self.bio = bio
        self.email = email
        self.id = id
        self.isFollow = isFollow
        self.birthDate = birthDate
        self.note = note
        self.isDisabled = isDisabled
        self.isSeleb = isSeleb
        self.isVerified = isVerified
        self.mobile = mobile
        self.name = name
        self.photo = photo
        self.username = username
        self.isSeller = isSeller
        self.socialMedias = socialMedias
        self.donationBadge = donationBadge
        self.referralCode = referralCode
        self.urlBadge = urlBadge
        self.isShowBadge = isShowBadge
        self.chatPrice = chatPrice
    }
    

	let accountType : String?
	let bio : String?
	let email : String?
	var id : String?
	var isFollow : Bool?
	let birthDate: String?
	let note: String?
	let isDisabled: Bool?
	let isSeleb: Bool?
	let isVerified : Bool?
	let mobile : String?
	let name : String?
	var photo : String?
	var username : String?
	let isSeller: Bool?
	let socialMedias: [SocialMedia]?
    let donationBadge: DonationBadge?
	let referralCode: String?	
    let urlBadge: String?
    let isShowBadge: Bool?
    let chatPrice: Int?

	enum CodingKeys: String, CodingKey {
		case accountType = "accountType"
		case bio = "bio"
		case email = "email"
		case id = "id"
		case isFollow = "isFollow"
		case birthDate = "birthDate"
		case note = "note"
		case isDisabled = "isDisabled"
		case isSeleb = "isSeleb"
		case isVerified = "isVerified"
		case mobile = "mobile"
		case name = "name"
		case photo = "photo"
		case username = "username"
		case isSeller = "isSeller"
		case socialMedias = "socialMedias"
        case donationBadge
		case referralCode = "referralCode"
        case urlBadge = "urlBadge"
        case isShowBadge = "isShowBadge"
        case chatPrice
	}

}
struct SocialMedia : Codable {
	
	let socialMediaType : String?
	let urlSocialMedia : String?
	
	enum CodingKeys: String, CodingKey {
		case socialMediaType = "socialMediaType"
		case urlSocialMedia = "urlSocialMedia"
	}
	
}

struct DonationBadge: Codable {
    let id, name: String?
    let url: String?
    let min, max, level: Int?
    let isFlagUpdate: Bool?
    let globalRank: Int?
    let isShowBadge: Bool?
}

enum SocialMediaType: String {
	case instagram = "INSTAGRAM"
	case tiktok = "TIKTOK"
	case wikipedia = "WIKIPEDIA"
	case facebook = "FACEBOOK"
	case twitter = "TWITTER"
}

struct EditProfile: Codable {
	let name, bio, photo, birthDate, gender: String?
		let socialMedias: [SocialMedia]?
}

extension Profile {
	static func emptyObject() -> Profile {
        return Profile(accountType: "", bio: "", email: "", id: "", isFollow: false, birthDate: "", note: "", isDisabled: false, isSeleb: false, isVerified: false, mobile: "", name: "", photo: "", username: "", isSeller: false, socialMedias: [], donationBadge: nil, referralCode: "", urlBadge: "", isShowBadge: false, chatPrice: 0)
	}
}

enum RMType: String {
    case following
    case post
    case follower
}
