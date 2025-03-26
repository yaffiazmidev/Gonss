//
//  AccountRepository.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 01/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift

protocol AccountRepository {
    func updateEmail(email: String) -> Observable<DefaultResponse>
    func saveAccount(profile: ProfileResult) -> Observable<ProfileResult>
}

final class AccountRepositoryImpl: AccountRepository {

    typealias AccountInstance = (LocalDataSource<Profile>, RxAccountNetworkModel, RxProfileNetworkModel) -> AccountRepository

    fileprivate let remote: RxAccountNetworkModel
    fileprivate let remoteProfile: RxProfileNetworkModel
    fileprivate let locale: LocalDataSource<Profile>

    private init(locale: LocalDataSource<Profile>, remote: RxAccountNetworkModel, remoteProfile: RxProfileNetworkModel) {
        self.locale = locale
        self.remote = remote
        self.remoteProfile = remoteProfile
    }

    static let sharedInstance: AccountInstance = { localeRepo, remoteRepo, remoteProfile in
        return AccountRepositoryImpl(locale: localeRepo, remote: remoteRepo, remoteProfile: remoteProfile)
    }


    func updateEmail(email: String) -> Observable<DefaultResponse> {
            var profile = getData()
            profile?.userEmail = email
            updateToken(data: profile!)
            return remote.updateEmail(email: email)
    }
    
    func saveAccount(profile: ProfileResult) -> Observable<ProfileResult> {
        if let data = profile.data {
            return locale.save(entity: data).map { _ in
                return profile
            }
        } else {
            return Observable.just(ProfileResult(code: "500", data: nil, message: nil))
        }
    }
    
    func getNetworkAccount(id: String) -> Observable<ProfileResult> {
        return remoteProfile.fetchProfile(id: id)
    }
}
