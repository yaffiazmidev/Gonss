//
//  KKDefaultLabel.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 10/08/23.
//

import UIKit

class KKDefaultLabel: UILabel {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        } set {
            self.layer.cornerRadius = newValue
        }
    }

    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        } set {
            self.layer.borderWidth = newValue
        }
    }

    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }

    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }

    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }

    @IBInspectable
    override var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }

    @IBInspectable
    override var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
}

extension KKDefaultLabel {
    @IBInspectable
    var strikethrough: Bool {
        get {
            return false
        }
        set {
            if newValue {
                let attributes: [NSAttributedString.Key: Any] = [
                    NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue
                ]
                let attributedText = NSAttributedString(string: self.text ?? "", attributes: attributes)
                self.attributedText = attributedText
            } else {
                let attributedText = NSAttributedString(string: self.text ?? "")
                self.attributedText = attributedText
            }
        }
    }
    
    @IBInspectable
    var underline: Bool {
        get {
            return false
        }
        set {
            if newValue {
                let attributes: [NSAttributedString.Key: Any] = [
                    NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
                ]
                let attributedText = NSAttributedString(string: self.text ?? "", attributes: attributes)
                self.attributedText = attributedText
            } else {
                let attributedText = NSAttributedString(string: self.text ?? "")
                self.attributedText = attributedText
            }
        }
    }
}

