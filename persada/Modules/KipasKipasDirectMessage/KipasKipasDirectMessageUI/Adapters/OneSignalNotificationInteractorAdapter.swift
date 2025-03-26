import Foundation
import Combine
import KipasKipasDirectMessage

public final class OneSignalNotificationInteractorAdapter {
    
    typealias NotificationResult = Swift.Result<OneSignalChatNotification, Error>
    
    private var cancellable: AnyCancellable?
    
    private let oneSignalAppId: String
    private let loader: (ChatPushNotificationParam) -> OneSignalChatNotificationLoader
    
    init(
        oneSignalAppId: String,
        loader: @escaping (ChatPushNotificationParam) -> OneSignalChatNotificationLoader
    ) {
        self.oneSignalAppId = oneSignalAppId
        self.loader = loader
    }
    
    func send(
        param: ChatPushNotificationParam,
        completion: @escaping (NotificationResult) -> Void
    ) {
        var param = param
        param.appId = oneSignalAppId
        
        cancellable = loader(param)
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { result in
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                    
                case .finished: break
                }
            }, receiveValue: { response in
                completion(.success(response))
            })
    }
}
