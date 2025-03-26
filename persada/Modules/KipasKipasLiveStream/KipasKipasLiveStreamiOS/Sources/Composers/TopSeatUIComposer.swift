import UIKit
import KipasKipasLiveStream
import KipasKipasShared

public enum TopSeatUIComposer {
    
    public static func composeTopSeatUIWith(
         seatProfileLoader:  @escaping (String) -> LiveProfileLoader ,
         followLoader: @escaping (String) -> FollowLoader ,
         unfollowLoader: @escaping (String) -> FollowLoader ,
         onUserImageClicked: ( (String) -> Void)? ,
         onClickRemind:  ((String) -> Void)? ,
         onClickReport: (() -> Void)?
    ) -> LiveTopSeatViewController {
        
        let adapter = SeatProfileAdapter(seatLoader: seatProfileLoader)
        let profileAdapter = ProfileFollowAdapter(followLoader:followLoader,unfollowLoader: unfollowLoader)
        
        let controller = LiveTopSeatViewController(seatProfileAdapter: adapter)
        controller.onClickFollow = profileAdapter.follow
        controller.onClickUnfollow = profileAdapter.unfollow
        
        controller.onUserImageClicked = onUserImageClicked
        controller.onClickRemind = onClickRemind
        controller.onClickReport = onClickReport
//        controller.onLoadSeatProfile = adapter.loadProfile
        
        adapter.delegate = controller
        profileAdapter.delegate = controller
        
        return controller
    }
}
