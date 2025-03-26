//
//  CustomHomeTopView.swift
//  KipasKipas
//
//  Created by Yaffi Azmi on 10/11/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class CustomHomeTopView: UIView {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    
    var view: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        backgroundColor = UIColor.clear
        view = loadNib()
        view.frame = bounds
        addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[childView]|", options: [], metrics: nil, views: ["childView": view!]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[childView]|", options: [], metrics: nil, views: ["childView": view!]))
    }
}
