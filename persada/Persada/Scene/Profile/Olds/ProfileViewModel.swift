//
//  ProfileViewModel.swift
//  Persada
//
//  Created by Muhammad Noor on 05/05/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

class ProfileViewModel {
    
    // MARK: - Public  Property
    
    let networkModel: ProfileNetworkModel?
    var changeHandler: ((ProfileViewModelChange) -> Void)?
    var id: String = ""
    
    // MARK: - Private Property
    
    private var profile: Profile!
    
    // MARK: - Public Method
    
    init(id: String, networkModel: ProfileNetworkModel) {
        self.networkModel = networkModel

        self.id = id
        fetchProfile()
        fetchFollowers()
        fetchFollowings()
    }
    
    func fetchProfile() {
        networkModel?.fetchAccount(.profile(id: self.id), { [weak self] (result) in
            
            guard let self = self else {
                return
            }
            
            switch result {
                
            case .failure(let error):
                DispatchQueue.main.async { [unowned self] in
                    self.emit(.didEncounterError(error))
                }
            
            case .success(let response):
                
                if let profile = response.data  {
//                    self.profile = profile
                    self.emit(.didUpdateProfile(values: self.profile))
                }
            }
        })
    }

    func followUser() {
        networkModel?.followAccount(.followAccount(id: id), { [weak self] (result) in
            guard let self = self else {
                return
            }
            
            switch result {
            case .failure(let error):
                DispatchQueue.main.async { [unowned self] in
                    self.emit(.didEncounterError(error))
            }
            case .success(let response):
                if response.code == "1000" {
                    self.emit(.didUpdateProfileFollowAccount)
                }
            }
        })
    }
    
    func fetchFollowers() {
        networkModel?.fetchFollowers(.followers(id: id), { [weak self] (result) in
            guard let self = self else {
                return
            }
            
            switch result {
            case .failure(let error):
                DispatchQueue.main.async { [unowned self] in
                    self.emit(.didEncounterError(error))
            }
            case .success(let response):
                if response.code == "1000" {
                    self.emit(.didUpdateTotalFollowers(value: response.data ?? 0))
                }
            }
        })
    }
    
    func fetchFollowings() {
        networkModel?.fetchFollowings(.followings(id: id), { [weak self] (result) in
            guard let self = self else {
                return
            }
            
            switch result {
                case .failure(let error):
                    DispatchQueue.main.async { [unowned self] in
                        self.emit(.didEncounterError(error))
                }
                case .success(let response):
                    if response.code == "1000" {
                        self.emit(.didUpdateTotalFollowings(value: response.data ?? 0))
                }
            }
        })
    }

    func emit(_ change: ProfileViewModelChange) {
        changeHandler?(change)
    }

}

enum ProfileViewModelChange {
    case didUpdateProfile(values: Profile)
    case didUpdateProfileFollowAccount
    case didUpdateTotalFollowings(value: Int)
    case didUpdateTotalFollowers(value: Int)
    case didEncounterError(ErrorMessage?)
}
