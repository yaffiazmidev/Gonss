import Foundation

public protocol NotificationSuggestionAccountLoader {
    typealias ResultSuggestionAccount = Swift.Result<NotificationSuggestionAccountContent, Error>
    
    func load(request: NotificationSuggestionAccountRequest, completion: @escaping (ResultSuggestionAccount) -> Void)
}
