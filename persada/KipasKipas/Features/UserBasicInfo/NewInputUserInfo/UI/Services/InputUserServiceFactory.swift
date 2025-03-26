//
//  InputUserServiceFactory.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

class InputUserServiceFactory: InputUserDelegate {
    private let emailValidator: EmailValidatorControllerDelegate
    private let usernameValidator: UsernameValidatorControllerDelegate
    private let uploader: UserPhotoUploadControllerDelegate
    private let creater: CreateUserControllerDelegate
    
    init(
        emailValidator: EmailValidatorControllerDelegate,
        usernameValidator: UsernameValidatorControllerDelegate,
        uploader: UserPhotoUploadControllerDelegate,
        creater: CreateUserControllerDelegate
    ) {
        self.emailValidator = emailValidator
        self.usernameValidator = usernameValidator
        self.uploader = uploader
        self.creater = creater
    }
    
    func didCreateUser(request: CreateUserRequest) {
        creater.didCreateUser(request: request)
    }
    
    func didValidateEmail(request: EmailValidatorRequest) {
        emailValidator.didValidateEmail(request: request)
    }
    
    func didValidateUsername(request: UsernameValidatorRequest) {
        usernameValidator.didValidateUsername(request: request)
    }
    
    func didUserPhotoUpload(request: UserPhotoUploadRequest) {
        uploader.didUserPhotoUpload(request: request)
    }
}
