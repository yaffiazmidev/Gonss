import Foundation
import Combine
import KipasKipasLiveStream
import KipasKipasNetworking
import KipasKipasShared

protocol LiveRoomDismissalAdapterDelegate: AnyObject {
    func didDismissedRoom(
        with result: Swift.Result<LiveStreamSummary, Error>,
        completion: @escaping () -> Void
    )
}

final class LiveRoomDismissalAdapter {
    
    private let loader: (LiveRoomSummaryRequest) -> LiveSummaryLoader
    
    private var cancellable: AnyCancellable?
    
    weak var delegate: LiveRoomDismissalAdapterDelegate?
    
    init(loader: @escaping (LiveRoomSummaryRequest) -> LiveSummaryLoader) {
        self.loader = loader
    }
    
    var dismiss: (() -> Void)?
    
    func dismissRoom(
        viewModel: LiveRoomSummaryViewModel
    ) {
        let summary = LiveRoomSummaryRequest(
            totalDuration: Int(viewModel.duration),
            totalLike: viewModel.likesCount,
            totalAudience: viewModel.viewersCount,
            streamingId: viewModel.streamId
        )
        
       guard let dismiss else { return }
        
       cancellable = loader(summary)
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { [weak self] result in
                if case .failure(let error) = result {
                    self?.delegate?.didDismissedRoom(
                        with: .failure(error),
                        completion: dismiss
                    )
                }
            }, receiveValue: { [weak self] response in
                self?.delegate?.didDismissedRoom(
                    with: .success(response.data),
                    completion: dismiss
                )
            })
    }
}
