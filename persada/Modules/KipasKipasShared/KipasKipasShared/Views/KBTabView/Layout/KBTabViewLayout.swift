//
//  Created by BK @kitabisa.
//

import UIKit

internal let KBTabViewNeedsLayoutUpdateNotification = Notification.Name(rawValue: "KBTabViewNeedsLayoutUpdateNotification")

open class KBTabViewLayout {
    
    public var layoutHeight: CGFloat = 45 {
        didSet { setNeedsUpdate() }
    }
    
    internal var numberOfItems: Int = 0
    
    internal func createLayout() -> UICollectionViewLayout {
        return UICollectionViewLayout()
    }
    
    required public init() {}
    
    internal func setNeedsUpdate() {
        NotificationCenter.default.post(name: KBTabViewNeedsLayoutUpdateNotification, object: self)
    }
}

