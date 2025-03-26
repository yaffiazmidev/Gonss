//
//  VerifyOTP.swift
//  Persada
//
//  Created by Muhammad Noor on 24/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

// MARK: - VerifyOTP
struct VerifyOTP: Codable {
    let code, message: String?
    let data: OTP?
}

// MARK: - OTP
struct OTP: Codable {
    let isRegister: Bool?
}
