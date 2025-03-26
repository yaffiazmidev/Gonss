//
//  UIButton+Extension.swift
//  Persada
//
//  Created by movan on 22/07/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

extension UIButton {
    private func actionHandler(action:(() -> Void)? = nil) {
        struct __ { static var action :(() -> Void)? }
        if action != nil { __.action = action }
        else { __.action?() }
    }
    @objc private func triggerActionHandler() {
        self.actionHandler()
    }
    func actionHandler(controlEvents control :UIControl.Event, ForAction action:@escaping () -> Void) {
        self.actionHandler(action: action)
        self.addTarget(self, action: #selector(triggerActionHandler), for: control)
    }
	
	var isValid: Bool {
		get {
			return isEnabled && backgroundColor == .primary
		}
		set {
			backgroundColor = newValue ? .primary : .orangeLowTint
			isEnabled = newValue
		}
	}
	
	var isEmpty: Bool {
		get {
			return isEnabled && backgroundColor == .clear
		}
		set {
			backgroundColor = .clear
			isEnabled = newValue
		}
	}
	
	func setupButton(color: UIColor = UIColor.primary, textColor: UIColor = .white, font: UIFont = .Roboto(.bold, size: 16)) {
					self.layer.cornerRadius = 8
					self.backgroundColor = color
					self.titleLabel?.font = font
//					self.contentEdgeInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
					self.setTitleColor(textColor, for: .normal)
	
			}

    convenience public init(title: String, titleColor: UIColor, font: UIFont = .systemFont(ofSize: 14), backgroundColor: UIColor = .clear, target: Any? = nil, action: Selector? = nil) {
        self.init(type: .system)
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        self.titleLabel?.font = font
        
        self.backgroundColor = backgroundColor
        if let action = action {
            addTarget(target, action: action, for: .touchUpInside)
        }
    }
    
    convenience public init(image: UIImage, tintColor: UIColor? = nil, target: Any? = nil, action: Selector? = nil) {
        self.init(type: .system)
        if tintColor == nil {
            setImage(image, for: .normal)
        } else {
            setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
            self.tintColor = tintColor
        }
        
        if let action = action {
            addTarget(target, action: action, for: .touchUpInside)
        }
    }
    
    //MARK:- Animate check mark
    func checkboxAnimation(closure: @escaping () -> Void){
            guard let image = self.imageView else {return}
            
            UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveLinear, animations: {
                    image.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    
            }) { (success) in
                    UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                            self.isSelected = !self.isSelected
                            //to-do
                            closure()
                            image.transform = .identity
                    }, completion: nil)
            }
            
    }
    
    func setBackgroundColor(_ color: UIColor, forState: UIControl.State) {
        setBackgroundImage(imageWithColor(color), for: forState)
    }
    
    func imageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    
    func text(_ t: String) -> Self {
        setTitle(t, for: .normal)
        return self
    }
    
    func image(_ s: String) -> Self {
        setImage(UIImage(named: s), for: .normal)
        return self
    }
}
