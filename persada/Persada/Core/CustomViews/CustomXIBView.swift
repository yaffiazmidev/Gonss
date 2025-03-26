//
//  CustomXIBView.swift
//  KipasKipas
//
//  Created by DENAZMI on 29/12/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class CustomXIBView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
        setupComponent()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
        setupComponent()
    }

    private func loadViewFromNib() {
        let nibName = String(describing: type(of: self))
        Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
    }

    func setupComponent() {
        // override
    }
}

class NibView: UIView {
    var view: UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Setup view from .xib file
        xibSetup()
        setupComponent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Setup view from .xib file
        xibSetup()
        setupComponent()
    }
    
    func setupComponent() {
        // override
    }
}

private extension NibView {
    
    func xibSetup() {
        backgroundColor = UIColor.clear
        view = loadNib()
        // use bounds not frame or it'll be offset
        view.frame = bounds
        // Adding custom subview on top of our view
        addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        let hotizontalFormat = "H:|[childView]|"
        let verticalFormat = "V:|[childView]|"
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: hotizontalFormat, options: [], metrics: nil, views: ["childView": view!]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: verticalFormat, options: [], metrics: nil, views: ["childView": view!]))
    }
}
