//
//  InputUserDelegate.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

protocol CreateUserControllerDelegate {
    func didCreateUser(request: CreateUserRequest)
}

protocol EmailValidatorControllerDelegate {
    func didValidateEmail(request: EmailValidatorRequest)
}

protocol UsernameValidatorControllerDelegate {
    func didValidateUsername(request: UsernameValidatorRequest)
}

protocol UserPhotoUploadControllerDelegate {
    func didUserPhotoUpload(request: UserPhotoUploadRequest)
}

typealias InputUserDelegate = CreateUserControllerDelegate & EmailValidatorControllerDelegate & UsernameValidatorControllerDelegate & UserPhotoUploadControllerDelegate

