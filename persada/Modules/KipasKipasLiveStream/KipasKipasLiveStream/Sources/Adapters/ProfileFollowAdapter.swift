import Combine
import KipasKipasNetworking

public protocol ProfileFollowAdapterDelegate: AnyObject {
    func followStatus(_ isFollowed: Bool) 
    func requestFail()
}

public final class ProfileFollowAdapter {
    
    private let followLoader: (String) -> AnyPublisher<EmptyData, Error>
    private let unfollowLoader: (String) -> AnyPublisher<EmptyData, Error>
    
    private var cancellable: AnyCancellable?
    
    public weak var delegate: ProfileFollowAdapterDelegate?
    
    public init(followLoader: @escaping (String) -> AnyPublisher<EmptyData, Error>,
                unfollowLoader: @escaping (String) -> AnyPublisher<EmptyData, Error>) {
        self.followLoader = followLoader
        self.unfollowLoader = unfollowLoader
    }
    
    public func follow(_ userId: String) {
        cancellable = followLoader(userId)
            .sink(receiveCompletion: { [weak self] result in
                if case .failure = result {
                    self?.delegate?.followStatus(false)
                }
            }, receiveValue: { [weak self] _ in
                self?.delegate?.followStatus(true)
            })
    }
    
    public func unfollow(_ userId: String) {
        cancellable = unfollowLoader(userId)
            .sink(receiveCompletion: { [weak self] result in
                if case .failure = result {
                    self?.delegate?.requestFail()
                }
            }, receiveValue: { [weak self] _ in
                self?.delegate?.followStatus(false)
            })
    }
     
}
