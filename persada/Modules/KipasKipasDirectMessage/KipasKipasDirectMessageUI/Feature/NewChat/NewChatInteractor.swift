import UIKit
import KipasKipasDirectMessage

protocol INewChatInteractor: AnyObject {
    var requestPage: Int { get set }
    var totalPage: Int { get set }
    var followings: [RemoteFollowingContent] { get set }
    var isSearching: Bool { get set }
    
    func requestFollowing()
    func loadMore(isLastIndex: Bool)
    func searchUser(by username: String)
}

class NewChatInteractor: INewChatInteractor {
    
    private let presenter: INewChatPresenter
    
    private let listFollowingAdapter: ListFollowingInteractorAdapter
    private let searchUserAdapter: SearchUserInteractorAdapter
    
    var requestPage: Int = 0
    var totalPage: Int = 0
    var followings: [RemoteFollowingContent] = []
    var isSearching: Bool = false
    
    init(
        presenter: INewChatPresenter,
        listFollowingAdapter: ListFollowingInteractorAdapter,
        searchUserAdapter: SearchUserInteractorAdapter
    ) {
        self.presenter = presenter
        self.listFollowingAdapter = listFollowingAdapter
        self.searchUserAdapter = searchUserAdapter
    }
    
    func requestFollowing() {
        listFollowingAdapter.load(page: requestPage) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(data):
                totalPage = (data.totalPages ?? 0) - 1
                presenter.presentFollowing(with: .success(data.content ?? []))
                
            case let .failure(error):
                presenter.presentFollowing(with: .failure(error))
            }
        }
    }
    
    func loadMore(isLastIndex: Bool) {
        guard isLastIndex && requestPage < totalPage else { return }
        
        requestPage += 1
        requestFollowing()
    }
    
    func searchUser(by username: String) {
        searchUserAdapter.search(by: username) { [weak self] result in
            self?.presenter.presentSearchUser(with: result)
        }
    }
}
