import UIKit
import Combine
import KipasKipasLiveStream
import KipasKipasShared

public enum AudienceListUIComposer {
    
    public static func composeAudienceListUIWith(
        loader: @escaping (LiveStreamAudienceListRequest) -> ListAudienceLoader,
        classicGiftLoader:@escaping () -> ListGiftLoader,
        coinBalanceLoader:@escaping () -> LiveCoinBalanceLoader,
        groupId: String,
        ownerId: String,
        audienceShowTips:Bool,
        selection: @escaping (String) -> Void,
        giftAction: @escaping () -> Void,
        faqAction: @escaping () -> Void
    ) -> UIViewController {
        let adapter = LiveStreamAudienceListAdapter(
            classicGiftLoader:classicGiftLoader, 
            listAudienceLoader: loader,
            topSeatsLoader: { _ in
                return Empty(completeImmediately: true).eraseToAnyPublisher()
            },
            coinBalanceLoader: coinBalanceLoader
        )
        let controller = AudienceListViewController(selection: selection,giftAction: giftAction,faqAction:faqAction)
        
        controller.onLoadAudienceList = { [adapter] page in
            adapter.loadAudienceList(request: .init(
                roomId: groupId,
                ownerId: ownerId,
                page: page
            ))
        }
        controller.audienceShowTips = audienceShowTips
        adapter.delegate = controller
        
        return controller
    }
}
