//
//  Created by BK @kitabisa.
//

import UIKit
/*
 Tab view with `Menu Tab` style and fixed layout
 */
public typealias KBMenuFixedTab = KBTabView<KBTabViewFixedLayout, KBTabViewItem, KBTabViewMenuCell>

/*
 Tab view with `Menu Tab` style and dynamic layout
 */
public typealias KBMenuDynamicTab = KBTabView<KBTabViewDynamicLayout, KBTabViewItem, KBTabViewMenuCell>

/*
 Tab view with `Segmented Tab` style and dynamic layout
 */
public typealias KBSegmentedDynamicTab = KBTabView<KBTabViewDynamicLayout, KBTabViewItem, KBTabViewSegmentedCell>
