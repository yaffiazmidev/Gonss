import Foundation
import Combine
import ImSDK_Plus

extension V2TIMManager {
    
    struct SavedError: Error {}
    
    func setSelfInfoPublisher(_ info: V2TIMUserFullInfo) -> AnyPublisher<Void, Error> {
        return Future { promise in
            self.setSelfInfo(info) {
                promise(.success(()))
            } fail: { (_,_) in
                promise(.failure(SavedError()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    struct GetMemberListError: Error {}
    
    func getAudienceList(groupId: String, page: Int) -> AnyPublisher<[V2TIMGroupMemberFullInfo], Error> {
        let filter: UInt32 = 0
        let page: UInt64 = UInt64(page)
        
        return Future { promise in
            self.getGroupMemberList(groupId, filter: filter, nextSeq: page) { _, members in
                promise(.success(members ?? []))
            } fail: { _, _ in
                promise(.failure(GetMemberListError()))
            }
        }
        .eraseToAnyPublisher()
    }
}
