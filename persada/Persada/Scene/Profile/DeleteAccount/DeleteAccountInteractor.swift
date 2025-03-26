//
//  DeleteAccountInteractor.swift
//  KipasKipas
//
//  Created by DENAZMI on 26/01/22.
//

import UIKit
import RxSwift
import KipasKipasShared
import KipasKipasCall

protocol DeleteAccountInteractorBusinessLogic: AnyObject {
	var parameters: [String: Any]? { get }
    
    func deleteMyAccount(password: String, reason: String)
    func logout()
    func logoutCallFeature()
}

class DeleteAccountInteractor: DeleteAccountInteractorBusinessLogic {
    
    var presenter: DeleteAccountPresenterPresentingLogic?
    var parameters: [String: Any]?
    let profileNetwork: ProfileNetworkModel
    let authUsecase: AuthUseCase
    let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
    private let disposeBag = DisposeBag()
    
    private(set) lazy var callAuthenticator: CallAuthenticator = {
        let auth = TUICallAuthenticator()
        return MainQueueDispatchDecorator(decoratee: auth)
    }()
    
    init(presenter: DeleteAccountPresenterPresentingLogic, profileNetwork: ProfileNetworkModel, authUsecase: AuthUseCase) {
        self.presenter = presenter
        self.profileNetwork = profileNetwork
        self.authUsecase = authUsecase
    }
}

extension DeleteAccountInteractor {
    func deleteMyAccount(password: String, reason: String) {
        profileNetwork.deleteMyAccount(.deleteMyAccount(passwordd: password, reason: reason)) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print("\(error?.statusCode ?? 0) \(error?.statusData ?? "")")
                self.presenter?.presentFailedDeleteMyAccount()
            case .success(let response):
                guard let statusCode = response.code, statusCode == "1000" else {
                    self.presenter?.presentFailedDeleteMyAccount()
                    return
                }
                KKCache.common.remove(key: .trendingCache)
                self.presenter?.presentSuccessDeleteMyAccount()
            }
        }
    }
    
    func logout() {
        self.presenter?.presentLogout(isSuccess: true)
        authUsecase.logoutClearCache()
            .subscribeOn(self.concurrentBackground)
            .observeOn(MainScheduler.instance)
            .subscribe{ [weak self] result in
                guard let self = self else { return }
                self.presenter?.presentLogout(isSuccess: true)
            } onError: { err in
                print(err.localizedDescription)
                self.presenter?.presentLogout(isSuccess: false)
            } onCompleted: {
            }.disposed(by: disposeBag)
    }
    
    func logoutCallFeature() {
        callAuthenticator.logout { result in
            switch result {
            case .failure(let error):
                print("Call Feature: Failure Logout", error.localizedDescription)
            case .success(_):
                print("Call Feature: Success Logout")
            }
        }
    }
}
