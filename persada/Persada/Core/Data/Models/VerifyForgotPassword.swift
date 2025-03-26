//
//  ForgotPassword.swift
//  Persada
//
//  Created by monggo pesen 3 on 18/06/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation


struct VerifyForgotPassword : Codable {
	let code, message: String?
	let data: ForgotPasswordItem?
}

struct ForgotPasswordItem: Codable {
	let id: String?
	let key: String?
	let otpCode: String?
	let newPassword: String?
	let media: String?
}
