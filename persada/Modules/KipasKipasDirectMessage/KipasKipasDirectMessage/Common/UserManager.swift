//
//  UserManager.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 02/08/23.
//

import Foundation
import KipasKipasNetworking

#warning("[BEKA] Get rid of this")
public class UserManager {
    public static var shared = UserManager()
    
    public var accessToken: String? {
        get {
            return UserDefaults.standard.string(forKey: "access_token")
        } set {
            UserDefaults.standard.set(newValue, forKey: "access_token")
        }
    }
    
    public var username: String? {
        get {
            return UserDefaults.standard.string(forKey: "userName")
        } set {
            UserDefaults.standard.set(newValue, forKey: "userName")
        }
    }
    
    public var userAvatarUrl: String? {
        get {
            return UserDefaults.standard.string(forKey: "userAvatarUrl")
        } set {
            UserDefaults.standard.set(newValue, forKey: "userAvatarUrl")
        }
    }
    
    public var userVerify: Bool? {
        get {
            return UserDefaults.standard.bool(forKey: "userVerify")
        } set {
            UserDefaults.standard.set(newValue, forKey: "userVerify")
        }
    }
    
    public var accountId: String? {
        get {
            return UserDefaults.standard.string(forKey: "accountId")
        } set {
            UserDefaults.standard.set(newValue, forKey: "accountId")
        }
    }
    
	public func save(_ user: LoginResponseDM) {
        UserDefaults.standard.set(user.accessToken, forKey: "access_token")
        UserDefaults.standard.set(user.userName, forKey: "userName")
        UserDefaults.standard.set(user.accountId, forKey: "accountId")
			let second = user.expiresIn ?? 0
			let expiredDate = TokenHelper.addSecondToCurrentDate(second: second)
			let item = LocalTokenItem(
					accessToken: user.accessToken ?? "",
					refreshToken: user.refreshToken ?? "",
					expiresIn: expiredDate
			)
			KeychainTokenStore().insert(item) { _ in }
    }
}
