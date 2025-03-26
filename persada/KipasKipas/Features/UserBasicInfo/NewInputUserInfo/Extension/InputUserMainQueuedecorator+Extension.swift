//
//  InputUserMainQueuedecorator+Extension.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import KipasKipasShared

extension MainQueueDispatchDecorator: EmailValidator where T == EmailValidator {
    func check(request: EmailValidatorRequest, completion: @escaping (EmailValidator.Result) -> Void) {
        
        decoratee.check(request: request)  { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: UsernameValidator where T == UsernameValidator {
    func check(request: UsernameValidatorRequest, completion: @escaping (UsernameValidator.Result) -> Void) {
        
        decoratee.check(request: request)  { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: CreateUser where T == CreateUser {
    
    func create(request: CreateUserRequest, completion: @escaping (CreateUser.Result) -> Void) {
        decoratee.create(request: request)  { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: UserPhotoUploader where T == UserPhotoUploader {
     
    func upload(request: UserPhotoUploadRequest, completion: @escaping (UserPhotoUploader.Result) -> Void) {
        
        decoratee.upload(request: request)  { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
