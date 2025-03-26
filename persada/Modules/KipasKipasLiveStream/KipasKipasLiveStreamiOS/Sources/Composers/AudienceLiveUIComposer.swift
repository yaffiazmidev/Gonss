import UIKit
import Combine
import KipasKipasTRTC
import KipasKipasLiveStream

public enum AudienceLiveUIComposer {
    
    public static func composeAudienceUI(
        coinBalanceLoader:@escaping () -> LiveCoinBalanceLoader,
        profileLoader: @escaping () -> LiveProfileLoader,
        seatProfileLoader: @escaping (String) -> LiveProfileLoader,
        audienceListLoader: @escaping (LiveStreamAudienceListRequest) -> ListAudienceLoader,
        topSeatsLoader: @escaping (String) -> LiveTopSeatLoader,
        classicGiftLoader:@escaping () -> ListGiftLoader,
        followLoader: @escaping (String) -> FollowLoader,
        unfollowLoader: @escaping (String) -> FollowLoader,
        liveRoom: AudienceLiveRoomManager,
        liveRoomInfo: LiveRoomInfoViewModel,
        onClickShare: @escaping ([String:String]) -> Void,
        onClickFollow: @escaping (String) -> Void,
        onClickAudience: @escaping (String, String,@escaping()->Void,@escaping()->Void)->Void,
        onDailyRankClicked: @escaping (Bool,@escaping()->Void) -> Void,
        onUserImageClicked: @escaping (String) -> Void,
        onKicked: @escaping () -> Void,
        onTapTopUpCoin: @escaping () -> Void,
        onLoadGifts: @escaping () -> Void,
        onLoadCoinBalance: @escaping () -> Void
        
    ) -> AudienceViewController {
        let profileAdapter = ProfileAdapter(loader: profileLoader)
        
        let adapter = LiveStreamAudienceListAdapter(
            classicGiftLoader:classicGiftLoader, 
            listAudienceLoader: audienceListLoader,
            topSeatsLoader: topSeatsLoader,
            coinBalanceLoader: coinBalanceLoader
        )
        
        let viewController = AudienceViewController(
            liveRoom: liveRoom,
            liveRoomInfo: liveRoomInfo, 
            audienceListAdapter: adapter,
            seatProfileLoader: seatProfileLoader,
            followLoader: followLoader,
            unfollowLoader: unfollowLoader
        )
        
        adapter.delegate = viewController
        
//        viewController.seatProfileLoader = seatProfileLoader
        viewController.followLoader = followLoader
        viewController.onClickShare = onClickShare
        viewController.onLoadProfile = profileAdapter.loadProfile
        viewController.onClickFollow = onClickFollow
        viewController.onClickAudience = onClickAudience
        viewController.onDailyRankClicked = onDailyRankClicked
        viewController.onKicked = onKicked
        viewController.onUserImageClicked = onUserImageClicked
        viewController.onTapTopUpCoin = onTapTopUpCoin
        viewController.onLoadGifts = onLoadGifts
        viewController.onLoadCoinBalance = onLoadCoinBalance
        
        profileAdapter.delegate = viewController
        
        return viewController
    }
}
