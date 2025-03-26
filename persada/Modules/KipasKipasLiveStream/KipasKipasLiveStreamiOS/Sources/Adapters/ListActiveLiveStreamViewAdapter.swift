import Combine
import KipasKipasTRTC
import KipasKipasLiveStream

public final class ListActiveLiveStreamViewAdapter {

    public weak var controller: LiveStreamingListViewController?
    
    private let roomId: String?
    private let profileLoader: () -> LiveProfileLoader
    private let seatProfileLoader: (String) -> LiveProfileLoader
    private let audienceListLoader: (LiveStreamAudienceListRequest) -> ListAudienceLoader
    private let topSeatsLoader: (String) -> LiveTopSeatLoader
    private let followLoader: (String) -> FollowLoader
    private let unfollowLoader: (String) -> FollowLoader
    private let listGiftLoader: () -> ListGiftLoader
    private let coinBalanceLoader: () -> LiveCoinBalanceLoader
    
    private let onClickAudience: (String, String,@escaping()->Void,@escaping()->Void) -> Void
    private let onDailyRankClicked: (Bool,@escaping()->Void) -> Void
    private let onKicked: () -> Void
    private let onUserImageClicked: (String) -> Void
    private let onTapTopUpCoin: () -> Void
    private let onClickShare: ([String:String]) -> Void
    
    public init(
        roomId: String?,
        controller: LiveStreamingListViewController?,
        profileLoader: @escaping () -> LiveProfileLoader,
        seatProfileLoader: @escaping (String) -> LiveProfileLoader,
        audienceListLoader: @escaping (LiveStreamAudienceListRequest) -> ListAudienceLoader,
        topSeatsLoader: @escaping (String) -> LiveTopSeatLoader,
        followLoader: @escaping (String) -> FollowLoader,
        unfollowLoader: @escaping (String) -> FollowLoader,
        onClickShare: @escaping ([String:String]) -> Void,
        listGiftLoader: @escaping () -> ListGiftLoader,
        coinBalanceLoader: @escaping () -> LiveCoinBalanceLoader,
        onClickAudience: @escaping (String, String,@escaping()->Void,@escaping()->Void) -> Void,
        onDailyRankClicked: @escaping (Bool,@escaping()->Void) -> Void,
        onUserImageClicked: @escaping (String) -> Void,
        onKicked: @escaping () -> Void,
        onTapTopUpCoin: @escaping () -> Void
    ) {
        self.roomId = roomId
        self.controller = controller
        self.profileLoader = profileLoader
        self.seatProfileLoader = seatProfileLoader
        self.audienceListLoader = audienceListLoader
        self.topSeatsLoader = topSeatsLoader
        self.followLoader = followLoader
        self.unfollowLoader = unfollowLoader
        self.listGiftLoader = listGiftLoader
        self.coinBalanceLoader = coinBalanceLoader
        self.onClickAudience = onClickAudience
        self.onDailyRankClicked = onDailyRankClicked
        self.onUserImageClicked = onUserImageClicked
        self.onKicked = onKicked
        self.onTapTopUpCoin = onTapTopUpCoin
        self.onClickShare = onClickShare
    }
}

extension ListActiveLiveStreamViewAdapter: ListActiveLiveStreamView {
    public func display(_ viewModel: ListActiveLiveStreamViewModel) {
        
        var viewModels = viewModel.contents
        
        if let roomId = roomId, 
           let first = viewModels.first(where: { $0.roomId == roomId }) {
            viewModels = [first]
        }
        
        let controllers = viewModels.map {
            let info = LiveRoomInfoViewModel(
                roomId: $0.roomId,
                roomName: $0.roomDescription,
                ownerName: $0.anchorName,
                ownerId: $0.anchorUserId,
                ownerPhoto: $0.anchorPhoto,
                isFollowingOwner: $0.isFollowingAnchor,
                isVerified: $0.isVerified
            )
            return makeLiveStreamingAudienceViewController(
                liveRoomInfo: info,
                coinBalanceLoader: coinBalanceLoader, 
                profileLoader: profileLoader ,
                onClickAudience: onClickAudience
            )
        }
        
        controller?.set(controllers)
    }
    
    
    
    private func makeLiveStreamingAudienceViewController(
        liveRoomInfo: LiveRoomInfoViewModel,
        coinBalanceLoader: @escaping () -> LiveCoinBalanceLoader,
        profileLoader: @escaping () -> LiveProfileLoader,
        onClickAudience: @escaping (String, String,@escaping()->Void,@escaping()->Void) -> Void
    ) -> AudienceViewController {
        
        let parameter = LiveRoomParameter(
            roomId: liveRoomInfo.roomId,
            ownerId: liveRoomInfo.ownerId,
            roomName: liveRoomInfo.roomName
        )
        let audienceLiveRoom = AudienceLiveRoomManager(parameter: parameter)
        
         
        
        let profileAdapter = ProfileFollowAdapter(followLoader: followLoader,unfollowLoader: unfollowLoader)
        let listGiftAdapter = ListGiftAdapter(
            listGiftLoader: listGiftLoader,
            coinBalanceLoader: coinBalanceLoader
        )
        
        let controller = AudienceLiveUIComposer.composeAudienceUI(
            coinBalanceLoader:coinBalanceLoader,
            profileLoader:  profileLoader ,
            seatProfileLoader: seatProfileLoader , 
            audienceListLoader: audienceListLoader,
            topSeatsLoader: topSeatsLoader, 
            classicGiftLoader:listGiftLoader,
            followLoader: followLoader,
            unfollowLoader: unfollowLoader,
            liveRoom: audienceLiveRoom,
            liveRoomInfo: liveRoomInfo,
            onClickShare: onClickShare,
            onClickFollow: profileAdapter.follow,
            onClickAudience: onClickAudience,
            onDailyRankClicked: onDailyRankClicked,
            onUserImageClicked: onUserImageClicked,
            onKicked: onKicked, 
            onTapTopUpCoin: onTapTopUpCoin, 
            onLoadGifts: listGiftAdapter.loadListGift,
            onLoadCoinBalance: listGiftAdapter.loadCoinBalance
        )
        
        audienceLiveRoom.delegate = controller
        profileAdapter.delegate = controller
        listGiftAdapter.delegate = controller.listGiftController
        // controller as? any ListGiftAdapterDelegate
        return controller
    }
}
