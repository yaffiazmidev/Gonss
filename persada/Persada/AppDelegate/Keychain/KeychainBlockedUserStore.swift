import Foundation
import KipasKipasNetworking

class KeychainBlockedUserStore: BlockedUserStore {
    
    private let store: KeychainDataStore
    
    private static let blocked_user_ids = getIdUser()
    
    init(query: KeychainStoreQueryable = GenericPasswordQueryable(service: "blockedUser")) {
        self.store = KeychainDataStore(keychainStoreQueryable: query)
    }
    
    func insert(_ blockedUserIds: [BlockedUserId], completion: @escaping InsertionCompletions) {
        do {
            
            let existing = retrieve() ?? []
            let ids = try JSONSerialization.data(withJSONObject: existing + blockedUserIds, options: [])
            
            try store.setValue(ids, for: KeychainBlockedUserStore.blocked_user_ids)
            completion(.success(()))
            
        } catch (let error) {
            completion(.failure(error))
        }
    }
    
    func retrieve() -> [BlockedUserId]? {
        do {
            guard let data = try store.getValue(for: KeychainBlockedUserStore.blocked_user_ids) else {
                return nil
            }
            let blockedUserIds = try JSONSerialization.jsonObject(with: data) as? [BlockedUserId]
            return blockedUserIds
        } catch {
            return nil
        }
    }
    
    func remove(_ blockedUserId: BlockedUserId) {
        do {
            guard var existing = retrieve(), !existing.isEmpty else { return }
            existing.removeAll(where: { $0 == blockedUserId })
            
            let ids = try JSONSerialization.data(withJSONObject: existing, options: [])
            
            try store.setValue(ids, for: KeychainBlockedUserStore.blocked_user_ids)
            
        } catch {}
    }
}
