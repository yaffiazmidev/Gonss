//
//  CurrentUserLogin.swift
//  FeedCleeps
//
//  Created by DENAZMI on 06/11/23.
//

import Foundation

enum CurrentUserLogin {
    static let id = DataCache.instance.readString(forKey: "USER_LOGIN_ID") ?? ""
}
