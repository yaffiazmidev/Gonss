//
//  ProfileUseCases.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 05/01/21.
//  Copyright © 2021 Muhammad Noor. All rights reserved.
//

import Foundation
import RxSwift

protocol ProfileUseCase {
	func getNetworkProfile(id: String) -> Observable<ProfileResult>
    func getNetworkProfile(username: String) -> Observable<ProfileResult>
	func getCounterNetwork(id: String) -> Observable<TotalCountProfile>
    func updateEmail(email: String) -> Observable<AccountUpdateEmailResult>
    func followAccount(id: String) -> Observable<DefaultResponse>
    func unFollowAccount(id: String) -> Observable<DefaultResponse>
    func getStory() -> Observable<StoryResult>
    func searchAccount(request: ProfileEndpoint) -> Observable<FollowerResult>
    func deleteMyAccount(password: String, reason: String) -> Observable<DefaultResponse>
}

class ProfileInteractorRx: ProfileUseCase {
   
	private let repository: ProfileRepository

	required init(repository: ProfileRepository) {
		self.repository = repository
	}
    
    func deleteMyAccount(password: String, reason: String) -> Observable<DefaultResponse> {
        return repository.deleteMyAccount(password: password, reason: reason)
    }
    
    func searchAccount(request: ProfileEndpoint) -> Observable<FollowerResult> {
        return repository.searchAccount(request: request)
    }

	func getNetworkProfile(id: String) -> Observable<ProfileResult> {
		return repository.getNetworkAccount(id: id)
	}
    
    func getNetworkProfile(username: String) -> Observable<ProfileResult> {
        return repository.getNetworkAccount(username: username)
    }

	func getCounterNetwork(id: String) -> Observable<TotalCountProfile> {
		return repository.getNetworkProfileCount(profileId: id)
	}

    func updateEmail(email: String) -> Observable<AccountUpdateEmailResult> {
        return repository.updateEmail(email: email)
    }

	func followAccount(id: String) -> Observable<DefaultResponse> {
		return repository.followProfile(profileId: id)
	}

	func unFollowAccount(id: String) -> Observable<DefaultResponse> {
		return repository.unFollowProfile(profileId: id)
	}
    
    func getStory() -> Observable<StoryResult> {
        return repository.getStory()
    }
}

