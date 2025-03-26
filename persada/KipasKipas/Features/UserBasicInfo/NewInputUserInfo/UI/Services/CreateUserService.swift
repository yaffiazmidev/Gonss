//
//  CreateUserService.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

class CreateUserService: CreateUserControllerDelegate {
    
    private let creater: CreateUser
    var presenter: CreateUserPresenter?
    
    init(creater: CreateUser) {
        self.creater = creater
    }
    
    func didCreateUser(request: CreateUserRequest) {
        presenter?.didStartLoadingGetCreateUser()
        creater.create(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(userItem):
                self.presenter?.didFinishLoadingGetCreateUser(with: userItem)
            case let .failure(error):
                self.presenter?.didFinishLoadingGetCreateUser(with: error)
            }
        }
    }
}


