//
//  CreateNewUser.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 26/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

class CreateNewUser {
    var name: String
    var mobile: String
    var password: String
    var photo: String
    var username: String
    var otpCode: String
    var birthDate: String
    var gender: String
    var deviceId: String
    var email: String
    
    init(name: String? = nil, mobile: String? = nil, password: String? = nil, photo: String? = nil, username: String? = nil, otpCode: String? = nil, birthDate: String? = nil, gender: String? = nil, email: String? = nil) {
        self.name = name ?? ""
        self.mobile = mobile ?? ""
        self.password = password ?? ""
        self.photo = photo ?? ""
        self.username = username ?? ""
        self.otpCode = otpCode ?? ""
        self.birthDate = birthDate ?? ""
        self.gender = gender ?? ""
        self.deviceId = getDeviceId()
        self.email = email ?? ""
    }
}


class ValidateAllData {
    var fullname: Bool
    var username: Bool
    var email: Bool
    var password: Bool
    var agreeTnC: Bool
    
    init(fullname: Bool = false, username: Bool = false, email: Bool = false, password: Bool = false, agreeTnC: Bool = false) {
        self.fullname = fullname
        self.username = username
        self.email = email
        self.password = password
        self.agreeTnC = agreeTnC
    }
    
    func isAllValidated() -> Bool {
        guard fullname, username, email, password, agreeTnC else {
            return false
        }
        return true
    }
}

struct InputUserParams {
    let otp, phone: String
}
