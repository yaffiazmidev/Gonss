//
//  ToastView.swift
//  KipasKipas
//
//  Created by DENAZMI on 29/12/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class ToastView: UIView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadNib()
        setupComponent()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadNib()
        setupComponent()
    }

    func setupComponent() {
        contentView.fixInView(self)
    }
}

extension UIView {
    public func loadNib() {
        let nibName = type(of: self).description().components(separatedBy: ".").last ?? ""
        Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
    }
}

extension UIView {
    func fixInView(_ container: UIView!) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.frame
        container.addSubview(self)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0)
        ])
    }
}
