//
//  SceneDelegate+TUICall.swift
//  KipasKipasCallApp
//
//  Created by Rahmat Trinanda Pramudya Amar on 24/12/23.
//

import Foundation
import KipasKipasNetworking

extension SceneDelegate {
    func didTUILogin(with result: Swift.Result<Void, Error>) {
        switch result {
        case .success(_):
            print("KipasKipasCallApp login success")
            break
        case .failure(let failure):
            print("KipasKipasCallApp login fail", failure.localizedDescription)
            break
        }
    }
    
    func didTUILogout(with result: Swift.Result<Void, Error>) {
        guard let window = window else { return }
        switch result {
        case .success(_):
            print("KipasKipasCallApp logout success")
            tokenStore.remove()
            configureRootViewController(in: window)
        case .failure(let failure):
            print("KipasKipasCallApp logout fail", failure.localizedDescription)
            break
        }
    }
    
    func didTUICall(with result: Swift.Result<Void, Error>) {
        switch result {
        case .success(_):
            print("KipasKipasCallApp call success")
            break
        case .failure(let failure):
            print("KipasKipasCallApp call fail", failure.localizedDescription)
            break
        }
    }
}
