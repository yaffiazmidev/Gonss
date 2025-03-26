//
//  ReviewAddSubmitView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 18/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//


import UIKit

class ReviewAddSubmitView: UIView {
    
    var handleSubmit: (() -> Void)?
    
    @IBOutlet weak var hideUsernameCheckBox: CheckBox!
    @IBOutlet weak var submitButton: PrimaryButton!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    static func loadViewFromNib() -> ReviewAddSubmitView {
        let bundle = Bundle(for: self)
        let nib = UINib(nibName: "ReviewAddSubmitView", bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! ReviewAddSubmitView
    }
    
    
    @IBAction func onSubmit(_ sender: UIButton) {
        self.submitButton.showLoading()
        self.handleSubmit?()
    }
}


