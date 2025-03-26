import Foundation
import Combine
import TUICore

extension TUILogin {
    
    enum LoginError: Swift.Error {
        case general
        case appDisabled
    }
    
    static func loginPublisher(userId: String) -> AnyPublisher<Void, LoginError> {
        let sdkAppId = Int32(SDKAPPID) ?? 0
        let userSig = TencentUserSig.genTestUserSig(userId)
        
        return Future { promise in
            login(sdkAppId, userID: userId, userSig: userSig) {
                promise(.success(()))
            } fail: { (code, _) in
                switch code {
                /// -10108: Overdue prepayment.
                /// -10112: The SDKAppID has been disabled.
                case -10108, -10112:
                    promise(.failure(.appDisabled))
                default:
                    promise(.failure(.general))
                }
                
            }
        }
        .eraseToAnyPublisher()
    }
}
