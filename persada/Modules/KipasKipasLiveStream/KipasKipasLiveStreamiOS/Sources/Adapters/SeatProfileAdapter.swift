import Combine
import KipasKipasNetworking
import KipasKipasLiveStream
import KipasKipasShared

protocol SeatProfileAdapterDelegate: AnyObject {
    func profileResult(_ result: Result<LiveUserProfile, Error>)
//    func followStatus(_ isFollowed: Bool)
}

final class SeatProfileAdapter {
    
    private let seatLoader: (String) -> LiveProfileLoader
//    private let followLoader: (String) -> AnyPublisher<EmptyData, Error>
    
    private var cancellable: AnyCancellable?
    
    weak var delegate: SeatProfileAdapterDelegate?
    
    init(seatLoader: @escaping (String) -> LiveProfileLoader
    ) {
        self.seatLoader = seatLoader
    }
    
    public func loadProfile(_ userId: String) {
        cancellable = seatLoader(userId)
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { [weak self] result in
                if case let .failure(error) = result {
                    self?.delegate?.profileResult(.failure(error))
                }
            }, receiveValue: { [weak self] response in
                self?.delegate?.profileResult(.success(response.data))
            })
    }
    
//    public func follow(_ userId: String) {
//        cancellable = followLoader(userId)
//            .sink(receiveCompletion: { [weak self] result in
//                if case .failure = result {
//                    self?.delegate?.followStatus(false)
//                }
//            }, receiveValue: { [weak self] _ in
//                self?.delegate?.followStatus(true)
//            })
//    }
}
