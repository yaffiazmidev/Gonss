//
//  Created by BK @kitabisa.
//

import UIKit

open class KBTabViewBaseCell: UICollectionViewCell {
    
    internal lazy var view = KBTabItemBaseView()
    
    public static var identifier: String {
        return String(describing: self)
    }
    
    internal var setSelected: Bool = false
    
    internal var hideLeftIconWhenUnselected: Bool = false
}
