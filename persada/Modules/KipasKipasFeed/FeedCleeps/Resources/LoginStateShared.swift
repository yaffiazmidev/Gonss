//
//  LoginStateShared.swift
//  FeedCleeps
//
//  Created by PT.Koanba on 07/07/22.
//

import Foundation

class LoginStateShared {
    var isLogin: Bool = false
    static let shared = LoginStateShared()

    private init() {}
}
