//
//  RxProfileNetworkModel.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 05/01/21.
//  Copyright © 2021 Muhammad Noor. All rights reserved.
//

import Foundation
import RxSwift

public final class RxProfileNetworkModel {
	private let network: Network<ProfileResult>
	private let networkTotal: Network<TotalFollow>
    private let networkProfile: Network<AccountUpdateEmailResult>
	private let defaultNetwork: Network<DefaultResponse>
	private let networkFollower: Network<FollowerResult>
    private let networkStory: Network<StoryResult>

	init(network: Network<ProfileResult>) {
		self.network = network
		self.networkTotal = Network<TotalFollow>()
		self.networkProfile = Network<AccountUpdateEmailResult>()
		self.defaultNetwork = Network<DefaultResponse>()
		self.networkFollower = Network<FollowerResult>()
        self.networkStory = Network<StoryResult>()
	}
    
    func deleteMyAccount(password: String, reason: String) -> Observable<DefaultResponse> {
        let request = ProfileEndpoint.deleteMyAccount(passwordd: password, reason: reason)
        return defaultNetwork.deleteItem(request.path, parameters: request.parameter, headers: request.header)
    }
    
    func searchAccount(request: ProfileEndpoint) -> Observable<FollowerResult> {
        return networkFollower.getItem(request.path, parameters: request.parameter, headers: request.header)
    }
	
	func fetchFollower(id: String, name: String, page: Int) -> Observable<FollowerResult> {
			let request = ProfileEndpoint.searchFollowers(id: id, name: name, page: page)
			return networkFollower.getItem(request.path, parameters: request.parameter, headers: request.header)
	}
    
    func fetchFollowing(id: String, name: String, page: Int) -> Observable<FollowerResult> {
        let request = ProfileEndpoint.searchFollowing(id: id, name: name, page: page)
        return networkFollower.getItem(request.path, parameters: request.parameter, headers: request.header)
    }

	func fetchProfile(id: String) -> Observable<ProfileResult> {
		let request = ProfileEndpoint.profile(id: id)
		return network.getItem( request.path, parameters: nil, headers: request.header)
	}
    
    func fetchProfile(username: String) -> Observable<ProfileResult>  {
        let request = ProfileEndpoint.profileUsername(text: username)
        return network.getItems( request.path, parameters: request.parameter)
    }

	func fetchCounter(type: RMType, id: String) -> Observable<TotalFollow> {
		switch type {
			case .follower:
				let request = ProfileEndpoint.followers(id: id)
				return networkTotal.getItem(request.path, parameters: nil, headers: request.header)
			case .following:
				let request = ProfileEndpoint.followings(id: id)
				return networkTotal.getItem(request.path, parameters: nil, headers: request.header)
			case .post:
				let request = ProfileEndpoint.totalPost(id: id)
				return networkTotal.getItem(request.path, parameters: nil, headers: request.header)
		}
	}
    
    func updateEmail(email : String) -> Observable<AccountUpdateEmailResult> {
        let request = AccountEndPoint.updateEmail(email: email)
        return networkProfile.postItemNew(request.path, parameters: request.parameter, headers: request.header)
    }

	func followAccount(profileId: String) -> Observable<DefaultResponse> {
		let request = ProfileEndpoint.followAccount(id: profileId)
		return defaultNetwork.updateItem(request.path, parameters: request.parameter, headers: request.header)
	}

	func unFollowAccount(profileId: String) -> Observable<DefaultResponse> {
		let request = ProfileEndpoint.unfollowAccount(id: profileId)
		return defaultNetwork.updateItem(request.path, parameters: request.parameter, headers: request.header)
	}
    
    func fetchStory() -> Observable<StoryResult> {
        let request = ProfileEndpoint.story
        return networkStory.getItem(request.path, parameters: nil, headers: request.header)
    }
}

