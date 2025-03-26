//
//  NewUserProfileModel.swift
//  Persada
//
//  Created by monggo pesen 3 on 19/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import UIKit
import KipasKipasShared

enum NewUserProfileModel {

	enum Request {
		case profile(id: String)
		case fetchTotalFollower(id: String)
		case fetchTotalFollowing(id: String)
		case fetchProfilePost(id: String, type: String, isPagination: Bool)
        case uploadPicture(_ item: KKMediaItem)
        case updatePicture(id: String, url: String)
	}

	enum Response {
		case profile(ResultData<ProfileResult>)
		case totalFollower(ResultData<TotalFollow>)
		case totalFollowing(ResultData<TotalFollow>)
        case uploadPicture(data: ResultData<ResponseMedia>)
        case updatePicture(data: ResultData<String>)
	}

	enum ViewModel {
		case profile(viewModel: Profile)
		case totalFollower(viewModel: TotalFollow)
		case totalFollowing(viewModel: TotalFollow)
		case totalPost(viewModel: TotalFollow)
		case profilePosts(viewModel: [Feed])
		case paginationPosts(viewModel: [Feed])
        case pictureUploaded(viewModel: ResponseMedia)
        case pictureUpdated(viewModel: String)
        case error(message: String)
	}

	enum Route {
        case profileSetting(id: String, showNavbar: Bool, isVerified: Bool, accountType: String)
        case myShop(id: String, isVerified: Bool)
		case followers(id: String, showNavbar: Bool)
		case followings(id: String, showNavbar: Bool)
		case socialMedia(url: String)
        case pictureOptions(picture: UIImage?, delegate: ProfilePictureOptionsDelegate)
        case openCamera(onMediaSelected: ((KKMediaItem) -> Void))
        case openLibrary(delegate: KKMediaPickerDelegate)
        case cropPicture(item: KKMediaItem, delegate: ProfilePictureCropDelegate)
        case picturePreview(picture: UIImage?)
        case donationRankAndBadge(accountId: String)
	}

	struct DataSource: DataSourceable {
		var id: String?
		var type: String?
		var page: Int?
		var data: [Feed]?
        var dataStory: [StoriesItem]?
        var socialMedias: [SocialMedia]?
	}
}
