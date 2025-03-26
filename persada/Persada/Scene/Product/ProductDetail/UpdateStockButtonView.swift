//
//  UpdateStockButtonView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 14/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class UpdateStockButtonView: UIView {
    
    var handleUpdate: (() -> Void)?
    
    @IBOutlet weak var updateButton: PrimaryButton!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    static func loadViewFromNib() -> UpdateStockButtonView {
        let bundle = Bundle(for: self)
        let nib = UINib(nibName: "UpdateStockButtonView", bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UpdateStockButtonView
    }
    
    @IBAction func updateAction(_ sender: UIButton) {
        self.handleUpdate?()
    }
}


