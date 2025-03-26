//
//  SplashScreenPresenter.swift
//  KipasKipas
//
//  Created by koanba on 24/08/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import OneSignal
import FeedCleeps

class RefreshTokenPresenter {
    
    enum Status {
        case success
        case failed
        case offline
        case tokenStillValid
    }
    
    static let shared = RefreshTokenPresenter()
    
    private init() {}
    
    var isRefreshing = false
    
    let disposeBag = DisposeBag()
    let usecase = Injection.init().provideAuthUseCase()
    let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
    var retryCount = 0
    
    func refreshToken(completion: @escaping (Status) -> Void) {
        if !ReachabilityNetwork.isConnectedToNetwork() {
            completion(.offline)
            return
        }
        if isRefreshing {
            return
        }
        if AUTH.isTokenExpired() {
            self.isRefreshing = true
            let network: AuthNetworkModel = AuthNetworkModel()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                network.refreshToken(.refreshToken(refreshToken: getRefreshToken())) { [weak self] (data) in
                    guard let self = self else { return }
                    switch data {
                    case .success(let dataLogin):
                        updateLoginData(data: dataLogin)
                        completion(.success)
                    case .failure(_):
                        if self.retryCount == 3 {
                            self.logout()
                            removeToken()
                            completion(.failed)
                            self.retryCount = 0
                        } else {
                            self.retryCount += 1
                            self.refreshToken(completion: completion)
                        }
                    }
                    self.isRefreshing = false
                }
            }
            
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                completion(.tokenStillValid)
            }
        }
       
    }
    
    func logout() {
        return usecase.logoutClearCache().subscribeOn(self.concurrentBackground)
            .observeOn(MainScheduler.instance)
            .subscribe{ result in
                DataCache.instance.cleanAll()
                OneSignal.removeExternalUserId({ results in
                    // The results will contain push and email success statuses
                    print("External user id update complete with results: ", results!.description)
                    // Push can be expected in almost every situation with a success status, but
                    // as a pre-caution its good to verify it exists
                    if let pushResults = results!["push"] {
                        print("Remove external user id push status: ", pushResults)
                    }
                    // Verify the email is set or check that the results have an email success status
                    if let emailResults = results!["email"] {
                        print("Remove external user id email status: ", emailResults)
                    }
                })
            }.disposed(by: disposeBag)
    }
    
}


class RefreshToken {
    
    static let shared = RefreshToken()
    
    enum Status {
        case success
        case failed
    }
    
    var isRefreshing = false
    let disposeBag = DisposeBag()
    let usecase = Injection.init().provideAuthUseCase()
    let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
    let authNetwork: AuthNetworkModel = AuthNetworkModel()
    var retryCount = 0

    func refreshToken(token: String, completion: @escaping (Status) -> Void) {
        if !ReachabilityNetwork.isConnectedToNetwork() {
            completion(.failed)
            return
        }
        
        if isRefreshing { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if !AUTH.isTokenExpired() {
                self.isRefreshing = false
                completion(.success)
                return
            }
            
            self.authNetwork.refreshToken(.refreshToken(refreshToken: token)) { [weak self] data in
                switch data {
                case .success(let dataLogin):
                    updateLoginData(data: dataLogin)
                    completion(.success)
                case .failure(_):
                    if self?.retryCount == 3 {
                        self?.logoutClearCache()
                        removeToken()
                        completion(.failed)
                        self?.retryCount = 0
                    } else {
                        self?.retryCount += 1
                        self?.refreshToken(token: token, completion: completion)
                    }
                }
                self?.isRefreshing = false
            }
        }
    }
    
    func logoutClearCache() {
        return usecase.logoutClearCache().subscribeOn(concurrentBackground).observeOn(MainScheduler.instance)
            .subscribe{ result in
            DataCache.instance.cleanAll()
            OneSignal.removeExternalUserId({ results in
                print("External user id update complete with results: ", results?.description ?? "")
                if let pushResults = results!["push"] { print("Remove external user id push status: ", pushResults) }
                if let emailResults = results!["email"] { print("Remove external user id email status: ", emailResults) }
            })
        }.disposed(by: disposeBag)
    }
}
