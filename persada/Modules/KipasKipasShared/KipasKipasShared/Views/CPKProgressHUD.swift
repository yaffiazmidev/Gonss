//
//  CPKProgressHUD.swift
//  Persada
//
//  Created by Muhammad Noor on 29/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

public enum CPKProgressHUDStyle {
    case loading(text: String? = nil)
    case success
}

public class CPKProgressHUD: UIVisualEffectView {
    private let dimension: CGFloat = 100.0
    
    var indicator: UIActivityIndicatorView? = nil
    let textLabel: UILabel
    
    let style: CPKProgressHUDStyle
    
    private init(style: CPKProgressHUDStyle) {
        self.style = style
        
        self.textLabel = UILabel()
        self.textLabel.numberOfLines = 0
        self.textLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        self.textLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        self.textLabel.textAlignment = .center
        
        super.init(effect: UIBlurEffect(style: .dark))
        
        self.isHidden = true
        self.alpha = 0
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        
        self.contentView.addSubview(textLabel)
        
        switch style {
            case .loading(text: let text):
                let indicator = UIActivityIndicatorView(style: .large)
                indicator.color = .white
                self.contentView.addSubview(indicator)
                self.indicator = indicator
                if let text = text {
                    self.textLabel.text = text
                } else {
                    self.textLabel.text = "Loading..."
                }
                break
            case .success:
                break
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public static func progressHUD(style: CPKProgressHUDStyle) -> CPKProgressHUD {
        return CPKProgressHUD(style: style)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = self.bounds
        if let indicator = indicator {
            let w = indicator.frame.width
            let h = indicator.frame.height
            indicator.frame = CGRect(x: (bounds.width - w) / 2.0, y: 18.0, width: w, height: h)
            textLabel.sizeToFit()
            textLabel.frame = CGRect(x: 0,
                                     y: indicator.frame.maxY,
                                     width: bounds.width,
                                     height: bounds.height - 23.0 - indicator.frame.height)
        }
    }
    
    public func show(in view: UIView) {
        self.removeFromSuperview()
        view.addSubview(self)
        view.bringSubviewToFront(self)
        
        indicator?.startAnimating()
        
        let bounds = view.bounds
        self.frame = CGRect(x: (bounds.maxX - bounds.minX - dimension) / 2.0,
                            y: (bounds.maxY - bounds.minY - dimension) / 2.0,
                            width: dimension,
                            height: dimension)
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.3) {
            self.isHidden = false
            self.alpha = 1
        }
    }
    
    public func dismiss(after delay: TimeInterval = 0.3) {
        UIView.animate(withDuration: delay, animations: {
            self.isHidden = true
            self.alpha = 0
            self.indicator?.stopAnimating()
        }) { (success) in
            self.removeFromSuperview()
        }
    }
}
