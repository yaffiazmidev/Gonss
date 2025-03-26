//
//  ToastView.swift
//  KipasKipas
//
//  Created by DENAZMI on 29/12/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class ToastView: CustomXIBView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var messageLabel: UILabel!

    override func setupComponent() {
        contentView.fixInView(self)
    }
}
