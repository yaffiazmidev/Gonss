//
//  LoadingView.swift
//  Krypton
//
//  Created by DENAZMI on 17/12/21.
//

import UIKit

class LoadingView: CustomXIBView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var activityContainerView: UIView!
    
    override func setupComponent() {
        contentView.fixInView(self)
    }
}
