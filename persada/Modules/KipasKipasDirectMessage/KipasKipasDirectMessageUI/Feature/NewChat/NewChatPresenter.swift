import UIKit
import KipasKipasDirectMessage

protocol INewChatPresenter {
    typealias CompletionHandler<T> = Swift.Result<T, Error>
    
    func presentFollowing(with result: CompletionHandler<[RemoteFollowingContent]>)
    func presentSearchUser(with result: CompletionHandler<[RemoteSearchUserData]>)
}

class NewChatPresenter: INewChatPresenter {
    weak var controller: INewChatViewController?
    
    init(controller: INewChatViewController) {
        self.controller = controller
    }
    
    func presentFollowing(with result: CompletionHandler<[RemoteFollowingContent]>) {
        switch result {
        case let .success(content):
            controller?.displayFollowers(content)
            
        case let .failure(error):
            controller?.displayError(error.localizedDescription)
        }
    }
    
    func presentSearchUser(with result: CompletionHandler<[RemoteSearchUserData]>) {
        switch result {
        case .failure(let error):
            print(error.localizedDescription)
            controller?.displaySearchingUser([])
        case .success(let response):
            let searchUsers: [RemoteFollowingContent] = response.compactMap({
                RemoteFollowingContent(
                    isVerified: $0.isVerified,
                    username: $0.username,
                    photo: $0.photo,
                    name: $0.name,
                    isFollow: $0.isFollow,
                    id: $0.id
                )
            })
            controller?.displaySearchingUser(searchUsers)
        }
    }
}
