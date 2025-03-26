//
//  ErrorView.swift
//  KipasKipas
//
//  Created by PT.Koanba on 13/07/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class KKErrorView: UIView {
    private let XIB_NAME = "KKErrorView"
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var errorMessage: UILabel!
    
    var onRetry: (() -> Void)?
    var onViewTap: (() -> Void)?
    
    @IBAction func onRetryButtonPress(_ sender: UIButton) {
        onRetry?()
    }
    
    func setErrorMessage(message: String) {
        self.errorMessage.text = message
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        let bundle = Bundle(for: Self.self)
        bundle.loadNibNamed(XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
        
        addTapGestureToView()
    }
    
    func addTapGestureToView() {
        contentView.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        contentView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func handleTapGesture(sender: UITapGestureRecognizer) {
        onViewTap?()
    }
}

private extension UIView {
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
