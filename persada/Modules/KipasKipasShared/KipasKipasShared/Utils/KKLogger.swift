//
//  KKLogger.swift
//  KipasKipasShared
//
//  Created by Rahmat Trinanda Pramudya Amar on 03/10/23.
//

import Foundation
import Disk
import Sentry
import UIKit


/**
 KKLogger, for creating Log on Sentry or File locally
 */
public class KKLogger {
    private static var _instance: KKLogger? // Sebagai Instance utama
    private static let lock = NSLock() // digunakan untuk mengamankan multithread
    
    
    /**
     Get Instance of KKLogger
     - returns: KKLogger
     
     # Example #
     ```
     // KKLogger.instance
     ```
     
     */
    public static var instance: KKLogger { // Merupakan Lazy var, variable akan terbentuk ketika dipanggil saja
        if _instance == nil { // Instance pertama, masih nil
            lock.lock() // Untuk mengunci NSLock, jadi tidak bisa terjadi multi instance
            defer { // Memastikan NSLock dibuka setelah inisialisasi selesai
                lock.unlock()
            }
            if _instance == nil {
                _instance = KKLogger()
            }
        }
        return _instance!
    }
    
    private init() {}
    
    
    /**
     Send Log to Sentry
     
     - parameter title: String of Title.
     - parameter message: String of content/message.
     
     # Example #
     ```
     // KKLogger.instance.send(title: "Network Log", message: "Network Speed is Slow")
     ```
     
     */
    public func send(title: String, message: String) {
        
        if(ignoredMessage(message: message)){
            return
        } else {
            let user = User()
            user.userId = "\(UIDevice.current.name)"
            user.username = self.userData()?.userName ?? "-"
            
            
            SentrySDK.setUser(user)
            SentrySDK.capture(message: "KKLogger : \(title)\n\(message)")
        }
    }
    
    private func ignoredMessage(message: String) -> Bool {
        if(message.lowercased().contains("timed out")){
            return true
        }

        if(message.lowercased().contains("9999")){
            return true
        }

        if(message.lowercased().contains("token")){
            return true
        }
        if(message.lowercased().contains("unknown network")){
            return true
        }

        return false
    }
}

// MARK: - Helper
fileprivate extension KKLogger {
    private func userData() -> Login? {
        do {
            let data = try Disk.retrieve("token.json", from: .applicationSupport, as: Login.self)
            return data
        } catch {
            print("Error Load User Data")
            return nil
        }
    }
}

// MARK: - UserModel
fileprivate struct Login: Codable {
    var accessToken, tokenType, loginRefreshToken: String?
    var expiresIn: Int?
    var scope: String?
    var userNo: Int?
    var userName, userEmail, userMobile, accountId: String?
    var authorities: [String]?
    var appSource, code: String?
    var timelapse: Int?
    var avatar: String?
    var role, jti, token, refreshToken: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case loginRefreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case scope, userNo, userName, userEmail, userMobile, accountId, authorities, appSource, code, timelapse, role, jti, token, refreshToken, avatar
    }
}
