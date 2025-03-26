//
//  CustomPopUpConfigureItem.swift
//  KipasKipasShared
//
//  Created by DENAZMI on 04/06/24.
//

import UIKit

public struct CustomPopUpConfigureItem {
    public let title: String
    public let description: String
    public let iconImage: UIImage?
    public let iconHeight: CGFloat
    public let withOption: Bool
    public let cancelButtonTitle: String
    public let okButtonTitle: String
    public let isHideIcon: Bool
    public let okButtonBackgroundColor: UIColor
    public let actionStackAxis: NSLayoutConstraint.Axis
    
    public init(
        title: String = "",
        description: String = "",
        iconImage: UIImage? = .emptyProfilePhoto,
        iconHeight: CGFloat = 35,
        withOption: Bool = false,
        isHideIcon: Bool = false,
        okButtonTitle: String = "OK",
        cancelButtonTitle: String = "Batalkan",
        okButtonBackgroundColor: UIColor = .gradientStoryOne,
        actionStackAxis: NSLayoutConstraint.Axis = .horizontal
    ) {
        self.title = title
        self.description = description
        self.iconImage = iconImage
        self.iconHeight = iconHeight
        self.withOption = withOption
        self.cancelButtonTitle = cancelButtonTitle
        self.okButtonTitle = okButtonTitle
        self.isHideIcon = isHideIcon
        self.okButtonBackgroundColor = okButtonBackgroundColor
        self.actionStackAxis = actionStackAxis
    }
}
