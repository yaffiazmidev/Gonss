//
//  ProfileRepository.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 05/01/21.
//  Copyright © 2021 Muhammad Noor. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol ProfileRepository {
	func getNetworkAccount(id: String) -> Observable<ProfileResult>
    func getNetworkAccount(username: String) -> Observable<ProfileResult>

	func getNetworkFollowingCount(id: String) -> Observable<TotalFollow>
	func getNetworkFollowerCount(id: String) -> Observable<TotalFollow>
	func getNetworkPostCount(id: String) -> Observable<TotalFollow>
    func updateEmail(email: String) -> Observable<AccountUpdateEmailResult>

	func getNetworkProfileCount(profileId: String) -> Observable<TotalCountProfile>
	func followProfile(profileId: String) -> Observable<DefaultResponse>
	func unFollowProfile(profileId: String) -> Observable<DefaultResponse>

	func getNetworkFollower(id: String, name: String, page: Int) -> Observable<FollowerResult>
    func getNetworkFollowing(id: String, name: String, page: Int) -> Observable<FollowerResult>
    
    func getStory() -> Observable<StoryResult>
    func searchAccount(request: ProfileEndpoint) -> Observable<FollowerResult>
    func deleteMyAccount(password: String, reason: String) -> Observable<DefaultResponse>
}

final class ProfileRepositoryImpl: ProfileRepository {


	typealias ProfileInstance = (RxProfileNetworkModel) -> ProfileRepository

	fileprivate let remote: RxProfileNetworkModel

	private init(remote: RxProfileNetworkModel) {
		self.remote = remote
	}

	static let sharedInstance: ProfileInstance = { remoteRepo in
		return ProfileRepositoryImpl(remote: remoteRepo)
	}
    
    func deleteMyAccount(password: String, reason: String) -> Observable<DefaultResponse> {
        return remote.deleteMyAccount(password: password, reason: reason)
    }
    
    func searchAccount(request: ProfileEndpoint) -> Observable<FollowerResult> {
        return remote.searchAccount(request: request)
    }

	func getNetworkFollowingCount(id: String) -> Observable<TotalFollow> {
		return self.remote.fetchCounter(type: RMType.following, id: id)
	}

	func getNetworkFollowerCount(id: String) -> Observable<TotalFollow> {
		return self.remote.fetchCounter(type: RMType.follower, id: id)
	}

	func getNetworkPostCount(id: String) -> Observable<TotalFollow> {
		return self.remote.fetchCounter(type: RMType.post, id: id)
	}

	func getNetworkAccount(id: String) -> Observable<ProfileResult> {
		return remote.fetchProfile(id: id)
	}
    
    func getNetworkAccount(username: String) -> Observable<ProfileResult> {
        return remote.fetchProfile(username: username)
    }

    func updateEmail(email: String) -> Observable<AccountUpdateEmailResult> {
        var profile = retrieveCredentials()
        profile?.userEmail = email
        updateLoginData(data: profile!)
        return remote.updateEmail(email: email)
    }

	func getNetworkProfileCount(profileId: String) -> Observable<TotalCountProfile> {
		let post = getNetworkPostCount(id: profileId)
		let following = getNetworkFollowingCount(id: profileId)
		let follower = getNetworkFollowerCount(id: profileId)

		return Observable.zip(post, following, follower) { (post, following, follower) -> TotalCountProfile in
			return TotalCountProfile(profileId: profileId, postCount: post.data ?? 0, followingCount: following.data ?? 0, followerCount: follower.data ?? 0)
		}
	}

	func followProfile(profileId: String) -> Observable<DefaultResponse> {
		return self.remote.followAccount(profileId: profileId)
	}

	func unFollowProfile(profileId: String) -> Observable<DefaultResponse> {
		return self.remote.unFollowAccount(profileId: profileId)
	}
	
	func getNetworkFollower(id: String, name: String, page: Int) -> Observable<FollowerResult> {
        return remote.fetchFollower(id: id, name: name, page: page)
	}
    
    func getNetworkFollowing(id: String, name: String, page: Int) -> Observable<FollowerResult> {
        return remote.fetchFollowing(id: id, name: name, page: page)
    }
    
    func getStory() -> Observable<StoryResult> {
        return remote.fetchStory()
    }
}
