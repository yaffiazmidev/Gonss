import Foundation
import Disk
import KipasKipasNetworking
import FeedCleeps
import UIKit
import KipasKipasLogin
import KipasKipasShared
import KipasKipasVerificationIdentity
import KipasKipasVerificationIdentityiOS

func updateLoginData(data: LoginResponse) {
    let second = data.expiresIn ?? 0
    let expiredDate = TokenHelper.addSecondToCurrentDate(second: second)
    let item = LocalTokenItem(
        accessToken: data.accessToken ?? "",
        refreshToken: data.refreshToken ?? "",
        expiresIn: expiredDate
    )
    DataCache.instance.write(string: data.accessToken ?? "", forKey: "KEY_AUTH_TOKEN")
    KeychainTokenStore().insert(item) { _ in }
    HelperSingleton.shared.token = data.accessToken ?? ""
    HelperSingleton.shared.userId = data.accountID ?? ""
    try? Disk.save(data, to: .applicationSupport, as: "token.json")
}

func retrieveCredentials() -> LoginResponse? {
    try? Disk.retrieve("token.json", from: .applicationSupport, as: LoginResponse.self)
}

func getToken() -> String? {
    
    let KEY_AUTH_TOKEN = "KEY_AUTH_TOKEN"
    
    if let cacheData = DataCache.instance.readString(forKey: KEY_AUTH_TOKEN) {
        if cacheData != "" {
            return cacheData
        }
    }

    let data = try? Disk.retrieve("token.json", from: .applicationSupport, as: LoginResponse.self)

    if(data?.accessToken != ""){
        DataCache.instance.write(string: data?.accessToken ?? "", forKey: KEY_AUTH_TOKEN)
    }
    
    return data?.accessToken    
}

func getIdUser() -> String {
//    let data = try? Disk.retrieve("token.json", from: .applicationSupport, as: LoginResponse.self)
//    return data?.accountID ?? ""

    let KEY_AUTH_IDUSER = "KEY_AUTH_IDUSER"
    
    if let cacheData = DataCache.instance.readString(forKey: KEY_AUTH_IDUSER) {
        if cacheData != "" {
            return cacheData
        }
    }

    let data = try? Disk.retrieve("token.json", from: .applicationSupport, as: LoginResponse.self)

    if(data?.accountID != ""){
        DataCache.instance.write(string: data?.accountID ?? "", forKey: KEY_AUTH_IDUSER)
    }

    return data?.accountID ?? ""
}

func getRole() -> String {
    let data = try? Disk.retrieve("token.json", from: .applicationSupport, as: LoginResponse.self)
    return data?.role ?? ""
}

func getUsername() -> String {
    
    let KEY_AUTH_USERNAME = "KEY_AUTH_USERNAME"
    
    let data = try? Disk.retrieve("token.json", from: .applicationSupport, as: LoginResponse.self)
    
    if let username = data?.userName {
        DataCache.instance.write(string: username, forKey: KEY_AUTH_USERNAME)
    } else if let cacheData = DataCache.instance.readString(forKey: KEY_AUTH_USERNAME) {
        return cacheData
    }
    
    return data?.userName ?? ""
}

func getTokenExpiresIn() -> Int? {
    let data = try? Disk.retrieve("token.json", from: .applicationSupport, as: LoginResponse.self)
    return data?.expiresIn ?? 0
}

func getTokenExpiresDate() -> Date {
    let tokenExpireDate = UserDefaults.standard.value(forKey: "TokenExpiredDate") as? Date
    return tokenExpireDate ?? Date()
}

func removeToken() {
    if Disk.exists("token.json", in: .applicationSupport) {
        try! Disk.remove("token.json", from: .applicationSupport)
    }
    DataCache.instance.clean(byKey: "KEY_AUTH_TOKEN")
    DataCache.instance.cleanAll()
    FeedSeenCache.instance.removeAllSeenFeed()
    KeychainTokenStore().remove()
    LoggedUserKeychainStore(key: .loggedInUser).remove()
    VerifyIdentityStoredKeychainStore().remove()
    ProfileKeychainStore(key: .profile).remove()
    NotificationCenter.default.post(name: .init("destroyObserver"), object: nil)
}

func getEmail() -> String {
    let data = try? Disk.retrieve("token.json", from: .applicationSupport, as: LoginResponse.self)
    return data?.userEmail ?? ""
}


func getPhone() -> String {
    let data = try? Disk.retrieve("token.json", from: .applicationSupport, as: LoginResponse.self)
    return data?.userMobile ?? ""
}

func getRefreshToken() -> String {
    let data = try? Disk.retrieve("token.json", from: .applicationSupport, as: LoginResponse.self)
    return data?.refreshToken ?? ""
}

func getName() -> String {
    let data = try? Disk.retrieve("token.json", from: .applicationSupport, as: LoginResponse.self)
    return data?.userName ?? ""
}

func getDeviceId() -> String {
    return UIDevice.current.identifierForVendor?.uuidString ?? ""
}

func getFollowing() -> Int {
    let profile = ProfileKeychainStore(key: .profile).retrieve()
    return profile?.totalFollowing ?? 0
}

func getPhotoURL() -> String {
    let profile = ProfileKeychainStore(key: .profile).retrieve()
    return profile?.photo ?? ""
}
