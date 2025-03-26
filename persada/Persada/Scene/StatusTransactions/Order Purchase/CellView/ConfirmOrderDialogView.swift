//
//  ConfirmOrderDialogView.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 06/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class ConfirmOrderDialogView : UIView {
	
	@IBOutlet weak var buttonCancel: UIButton!
	@IBOutlet weak var buttonDone: UIButton!
	
	var handleCancel: (() -> Void)?
	var handleDone: (() -> Void)?
	
	@IBAction func cancel(_ sender: Any) {
		handleCancel?()
	}
	
	@IBAction func done(_ sender: Any) {
		handleDone?()
	}
	
	static func loadViewFromNib() -> ConfirmOrderDialogView {
					let bundle = Bundle(for: self)
					let nib = UINib(nibName: "ConfirmOrderDialogView", bundle: bundle)
					return nib.instantiate(withOwner: self, options: nil).first as! ConfirmOrderDialogView
			}
}
