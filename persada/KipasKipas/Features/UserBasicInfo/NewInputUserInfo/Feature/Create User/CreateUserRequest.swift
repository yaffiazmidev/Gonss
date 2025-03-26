//
//  CreateUserRequest.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 19/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

struct CreateUserRequest: Encodable {
    let name: String
    let mobile: String
    let password: String
    let photo: String
    let username: String
    let otpCode: String
    let birthDate: String
    let gender: String
    let deviceId: String
    let email: String
    let referralCode: String
    
    init(name: String, mobile: String, password: String, photo: String, username: String, otpCode: String, birthDate: String, gender: String, deviceId: String, email: String, referralCode: String) {
        self.name = name
        self.mobile = mobile
        self.password = password
        self.photo = photo
        self.username = username
        self.otpCode = otpCode
        self.birthDate = birthDate
        self.gender = gender.uppercased()
        self.deviceId = deviceId
        self.email = email
        self.referralCode = referralCode
    }
}
