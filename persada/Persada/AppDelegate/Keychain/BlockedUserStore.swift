import Foundation

protocol BlockedUserStore {
    
    typealias BlockedUserId = String
    typealias InsertionResult = Swift.Result<Void, Error>
    typealias InsertionCompletions = (InsertionResult) -> Void
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func insert(_ blockedUserIds: [BlockedUserId], completion: @escaping InsertionCompletions)
        
    func retrieve() -> [BlockedUserId]?
    
    func remove(_ blockedUserId: BlockedUserId)
}
