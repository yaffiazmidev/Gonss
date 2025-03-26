import Foundation
import Combine
import SendbirdChatSDK
import KipasKipasDirectMessage

final class CreateGroupChannelInteractorAdapter {
    
    typealias CreationResult = Swift.Result<GroupChannel, Error>
    
    private enum CreationError: Error {
        case emptyChannel
    }
    
    private var cancellable: AnyCancellable?
    
    private let useCase = CreateGroupChannelUseCase()
    
    private let userId: String
    private let loader: (DirectMessageRegisterParam) -> DirectMessageRegisterLoader
    
    var completion: ((CreationResult) -> Void)?
    
    init(
        userId: String,
        loader: @escaping (DirectMessageRegisterParam) -> DirectMessageRegisterLoader
    ) {
        self.userId = userId
        self.loader = loader
    }
    
    func create(with selectedUserId: String) {
        cancellable = loader(.init(
            externalChannelId: userId + "_" + selectedUserId,
            payerId: userId,
            recipientId: selectedUserId
        ))
        .dispatchOnMainQueue()
        .sink(receiveCompletion: { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .finished: break
            case let .failure(error):
                completion?(.failure(error))
            }
        }, receiveValue: { [weak self] _ in
            self?.createSendbirdGroupChannel(with: selectedUserId)
        })
    }
    
    private func createSendbirdGroupChannel(with selectedUserId: String) {
        useCase.createGroupChannel(
            name: nil,
            coverImage: nil, 
            userId: userId,
            selectedUserId: selectedUserId
        ) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case let .success(channel):
                guard let channel else {
                    completion?(.failure(CreationError.emptyChannel))
                    return
                }
                completion?(.success(channel))
                
            case let .failure(error):
                completion?(.failure(error))
            }
        }
    }
}
