//
//  Created by BK @kitabisa.
//

import UIKit

public protocol KBTabViewItemable: Hashable {
    var id: String { get set }
    var title: String { get set }
    var badgeValue: String? { get set }
    var isSelected: Bool { get set }
    var isLoading: Bool { get set }
    var leftIconModel: LeftIconModel? { get set }
    var urlData: String { get set }
}

public struct LeftIconModel {
    public let icon: UIImage?
    public let size: CGFloat
    public let url: URL?
    
    public init(
        icon: UIImage?,
        size: CGFloat,
        url: URL?
    ) {
        self.icon = icon
        self.size = size
        self.url = url
    }
}

public struct KBTabViewItem: KBTabViewItemable {

    public var id: String = UUID().uuidString
    public var title: String
    public var badgeValue: String?
    public var isSelected: Bool = false
    public var isLoading: Bool
    public var leftIconModel: LeftIconModel?
    public var urlData: String
    
    public init(
        title: String,
        isLoading: Bool = false,
        badgeValue: String? = nil,
        leftIconModel: LeftIconModel? = nil,
        urlData: String = ""
    ) {
        self.title = title
        self.isLoading = isLoading
        self.badgeValue = badgeValue
        self.leftIconModel = leftIconModel
        self.urlData = urlData
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: KBTabViewItem, rhs: KBTabViewItem) -> Bool {
        return lhs.id == rhs.id && lhs.isSelected == rhs.isSelected
    }
}
