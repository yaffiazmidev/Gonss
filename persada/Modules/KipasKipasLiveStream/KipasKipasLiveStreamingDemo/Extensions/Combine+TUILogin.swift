import Foundation
import Combine
import TUICore

extension TUILogin {
    
    enum Error: Swift.Error {
        case loginError
    }
    
    static func loginPublisher(userId: String) -> AnyPublisher<Void, Error> {
        let sdkAppId = Int32(SDKAPPID) ?? 0
        let userSig = TencentUserSig.genTestUserSig(userId)
        
        return Future { promise in
            login(sdkAppId, userID: userId, userSig: userSig) {
                promise(.success(()))
            } fail: { (_,_) in
                promise(.failure(Error.loginError))
            }
        }
        .eraseToAnyPublisher()
    }
}
