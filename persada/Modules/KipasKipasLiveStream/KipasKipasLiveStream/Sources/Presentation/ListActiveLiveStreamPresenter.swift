import Foundation

public protocol ListActiveLiveStreamView {
    func display(_ viewModel: ListActiveLiveStreamViewModel)
}

public final class ListActiveLiveStreamPresenter {
    
    public let view: ListActiveLiveStreamView
    
    public init(view: ListActiveLiveStreamView) {
        self.view = view
    }
    
    public func didFinishLoading(with response: LiveRoomActive) {
        view.display(ListActiveLiveStreamPresenter.map(response))
    }
    
    public func didFinishLoading(with error: Error) {
        view.display(.init(page: 0, totalPages: 0, contents: []))
    }
    
    private static func map(_ response: LiveRoomActive) -> ListActiveLiveStreamViewModel {
        return ListActiveLiveStreamViewModel(
            page: response.pageable?.pageNumber ?? 0,
            totalPages: response.totalPages ?? 1,
            contents: response.content?.compactMap {
                return ListActiveLiveStreamContentViewModel(
                    id: $0.id ?? "",
                    roomId: $0.roomID ?? "0",
                    roomDescription: $0.description ?? "", 
                    anchorName: $0.account?.name ?? $0.account?.username ?? "",
                    anchorUserId: $0.account?.id ?? "",
                    anchorPhoto: $0.account?.photo ?? "", 
                    isFollowingAnchor: $0.account?.isFollow ?? false,
                    isVerified: $0.account?.isVerified ?? false 
                )
            } ?? []
        )
    }
}
