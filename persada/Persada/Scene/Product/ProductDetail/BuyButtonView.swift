//
//  BuyButtonView.swift
//  Persada
//
//  Created by movan on 22/07/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class BuyButtonView: UIView {
	
	var value: Int = 1 {
		didSet {
			countLabel.text = "\(value)"
		}
	}
    
	var handleBuy: (() -> Void)?
    var handleIncrease: (() -> Void)?
    var handleReduce: (() -> Void)?
    
    @IBOutlet weak var buyButton: PrimaryButton!
    @IBOutlet weak var increaseButton: UIButton!
    @IBOutlet weak var reduceButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!
 

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    static func loadViewFromNib() -> BuyButtonView {
        let bundle = Bundle(for: self)
        let nib = UINib(nibName: "BuyButtonView", bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! BuyButtonView
    }
    
    @IBAction func increaseAction(_ sender: UIButton) {
        handleIncrease?()
    }
    
    @IBAction func reduceAction(_ sender: UIButton) {
        handleReduce?()
    }
    
    @IBAction func buyAction(_ sender: UIButton) {
        self.buyButton.showLoading()
        self.handleBuy?()
    }
}


