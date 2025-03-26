import Foundation
import Sentry
import Disk
import KipasKipasDirectMessage
import KipasKipasDirectMessageUI
import UIKit
import OneSignal

var logoutIM: (() -> Void)?

// MARK: Sentry
extension AppDelegate {
    func updateSentryUserData(){
        SentrySDK.setUser(nil)
        
        let user = User()
        user.userId = UIDevice.current.name
        user.username = getUsername()
        
        SentrySDK.setUser(user)
    }
}

// MARK: SendBird
extension AppDelegate {
    func configureThirdPartyFeature() {
        KipasKipas.logoutIM = logoutIM
    }
    
    func loginIM() {
        loginIM(with: getIdUser())
    }
    
    func loginIM(with userId: String) {
        let userSig = TencentUserSig.genTestUserSig(userId)
        TXIMUserManger.shared.login(userId, userSig: userSig) { [weak self] result in
            switch result {
            case .success(_):
                self?.getUserBy(id: userId)
                UserManager.shared.accountId = userId
                print("TXIM login: Success")
            case .failure(let error):
                print("TXIM login: Error \(error.localizedDescription)")
            }
        }
    }
  
    func logoutIM() {
        TXIMUserManger.shared.logout { }
    }
    
    func connectOneSignal(with id: String) {
        OneSignal.setExternalUserId(id) { results in
            print("Sendbird - Success setExternalUserID with id:", id)
        } withFailure: { error in
            print("Sendbird - Failed setExternalUserID with id:", id, "error:", error)
        }
    }
}

// MARK: Disk
extension AppDelegate {
    var disk: Disk.Type {
        return Disk.self
    }
}
