//
//  EditProfileModel.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 13/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import Foundation
import KipasKipasShared

enum EditProfileModel {

	enum Request {
		case getProfile(id: String)
		case uploadImage(item: KKMediaItem)
		case updateUploadedImageUrl(source: String)
        case updateProfile(bio: String, name: String, photo: String?, birthDate: String?, gender: String?, socmed: [SocialMedia])
	}

	enum Response {
		case getProfile(data: ResultData<EditProfileResult>)
		case uploadImage(data: ResultData<ResponseMedia>)
		case updateProfile(data: ResultData<DefaultResponse>)
	}

	enum ViewModel {
		case uploadImage(viewModelData: ResultData<ResponseMedia>)
		case getProfile(viewModelData: ResultData<EditProfileResult>)
		case updateProfile(data: ResultData<DefaultResponse>)
	}

	enum Route {
		case dismissWhenAlreadySave
		case dismiss
	}

	struct DataSource: DataSourceable {
        var id: String
        var item: KKMediaItem? = nil
        var imageUrl: String? = nil
	}
}


// MARK: - Profile
struct EditProfileResult : Codable {

    let code : String?
    let data : EditProfileData?
    let message : String?

    enum CodingKeys: String, CodingKey {
        case code = "code"
        case data = "data"
        case message = "message"
    }
}

// MARK: - EditProfileData
struct EditProfileData : Codable {

    let accountType : String?
    let bio : String?
    let email : String?
    let id : String?
    let isFollow : Bool?
    let birthDate: String?
    let note: String?
    let isDisabled: Bool?
    let isSeleb: Bool?
    let isVerified : Bool?
    let mobile : String?
    let name : String?
    let photo : String?
    let username : String?
    let isSeller: Bool?
    let gender: String?
    let socialMedias: [SocialMedia]?

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
        case gender = "gender"
    }

}
