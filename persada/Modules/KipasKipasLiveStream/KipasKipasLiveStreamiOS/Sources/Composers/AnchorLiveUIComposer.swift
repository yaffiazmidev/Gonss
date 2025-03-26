import UIKit
import Combine
import KipasKipasTRTC
import KipasKipasLiveStream
import KipasKipasShared
import KipasKipasNetworking

public enum AnchorLiveUIComposer {
    public static func composeAnchorUI(
        liveRoom: AnchorLiveRoomManager,
        profileLoader: @escaping () -> LiveProfileLoader,
        createRoomLoader: @escaping (String, String) -> LiveCreateLoader,
        validationLoader: @escaping () -> LiveValidationLoader,
        dismissalLoader: @escaping (LiveRoomSummaryRequest) -> LiveSummaryLoader,
        audienceListLoader: @escaping (LiveStreamAudienceListRequest) -> ListAudienceLoader,
        topSeatsLoader: @escaping (String) -> LiveTopSeatLoader,
        classicGiftLoader:@escaping () -> ListGiftLoader,
        coinBalanceLoader:@escaping () -> LiveCoinBalanceLoader,
        onAudienceClicked: @escaping (String, String,@escaping()->Void,@escaping()->Void) -> Void,
        onDailyRankingClicked: @escaping (Bool,@escaping()->Void) -> Void,
        dismiss: @escaping () -> Void
    ) -> AnchorViewController {
    
        let profileAdapter = ProfileAdapter(loader: profileLoader)
        
        let dismissalAdapter = LiveRoomDismissalAdapter(loader: dismissalLoader)
        dismissalAdapter.dismiss = dismiss
        
        let validationAdapter = LiveRoomValidationAdapter(loader: validationLoader)
        let creationAdapter = LiveRoomCreationAdapter(loader: createRoomLoader)
        let audienceListAdapter = LiveStreamAudienceListAdapter(
            classicGiftLoader:classicGiftLoader,
            listAudienceLoader: audienceListLoader,
            topSeatsLoader: topSeatsLoader,
            coinBalanceLoader:coinBalanceLoader 
        )
        
        let viewController = AnchorViewController(
            liveRoom: liveRoom,
            audienceListAdapter: audienceListAdapter
        )
        
        viewController.onLoadProfile = profileAdapter.loadProfile
        viewController.onCreateNewRoom = creationAdapter.createRoom
        viewController.onDestroyRoom = dismissalAdapter.dismissRoom
        viewController.onLeaveRoomWithoutLive = dismissalAdapter.dismiss
        viewController.onValidateRoom = validationAdapter.validate
        viewController.onAudienceClicked = onAudienceClicked
        viewController.onDailyRankClicked = onDailyRankingClicked
        
        profileAdapter.delegate = viewController
        creationAdapter.delegate = viewController
        validationAdapter.delegate = viewController
        audienceListAdapter.delegate = viewController
        dismissalAdapter.delegate = viewController
        
        return viewController
    }
}
