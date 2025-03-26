import UIKit
import KipasKipasLiveStream
import KipasKipasShared

public enum ListGiftUIComposer {
    
    public static func composeListGiftUIWith(
        selection: @escaping (LiveGift) -> Void,
        onTapTopUpCoin: (() -> Void)?
    ) -> ListGiftViewController {
        
        let controller = ListGiftViewController(selection: selection)
        controller.onTapTopUpCoin = onTapTopUpCoin
        return controller
    }
}
