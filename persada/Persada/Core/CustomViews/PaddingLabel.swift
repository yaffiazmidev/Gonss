//
//  PaddingLabel.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 23/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class PaddingLabel: UILabel {

		@IBInspectable var topInset: CGFloat = 5.0
		@IBInspectable var bottomInset: CGFloat = 5.0
		@IBInspectable var leftInset: CGFloat = 7.0
		@IBInspectable var rightInset: CGFloat = 7.0
		
		
		override func drawText(in rect: CGRect) {
				let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
				super.drawText(in: rect.inset(by: insets))
		}

		override var intrinsicContentSize: CGSize {
				let size = super.intrinsicContentSize
				return CGSize(width: size.width + leftInset + rightInset,
											height: size.height + topInset + bottomInset)
		}

		override var bounds: CGRect {
				didSet {
						// ensures this works within stack views if multi-line
						preferredMaxLayoutWidth = bounds.width - (leftInset + rightInset)
				}
		}
}
