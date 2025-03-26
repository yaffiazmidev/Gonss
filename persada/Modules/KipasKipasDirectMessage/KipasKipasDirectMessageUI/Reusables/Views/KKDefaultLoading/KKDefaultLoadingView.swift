//
//  KKDefaultLoadingView.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 04/08/23.
//

import UIKit

class KKDefaultLoadingView: UIView {
    
    @IBOutlet weak var activityLoadingView: UIActivityIndicatorView!
    @IBOutlet weak var messageLabel: UILabel!

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupComponent()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupComponent()
    }
    
    func setupComponent() {
    }
}
