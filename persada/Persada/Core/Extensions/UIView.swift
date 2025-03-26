//
//  UIView.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 28/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

extension UIView {

	func addShadow(shadowColor: UIColor, offSet: CGSize, opacity: Float, shadowRadius: CGFloat, cornerRadius: CGFloat, corners: UIRectCorner, fillColor: UIColor = .white) {

		let shadowLayer = CAShapeLayer()
		let size = CGSize(width: cornerRadius, height: cornerRadius)
		let cgPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: size).cgPath //1
		shadowLayer.path = cgPath //2
		shadowLayer.fillColor = fillColor.cgColor //3
		shadowLayer.shadowColor = shadowColor.cgColor //4
		shadowLayer.shadowPath = cgPath
		shadowLayer.shadowOffset = offSet //5
		shadowLayer.shadowOpacity = opacity
		shadowLayer.shadowRadius = shadowRadius
		
		layer.shouldRasterize = true
		layer.rasterizationScale = UIScreen.main.scale
		self.layer.addSublayer(shadowLayer)
	}

	func dropShadow(scale: Bool = true) {
		layer.masksToBounds = false
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowOpacity = 0.2
		layer.shadowOffset = .zero
		layer.shadowRadius = 1

		layer.shouldRasterize = true
		layer.rasterizationScale = scale ? UIScreen.main.scale : 1
	}

	public var viewWidth: CGFloat {
		return self.frame.size.width
	}

	public var viewHeight: CGFloat {
		return self.frame.size.height
	}

	func addSubViews(_ views: [UIView]){
		views.forEach { view in
			self.addSubview(view)
		}
	}
    
    func setCorners(corners: UIRectCorner, radius: CGFloat) {
      let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
      let mask = CAShapeLayer()
      mask.path = path.cgPath
      layer.mask = mask
    }

    @IBInspectable
    var setCornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        } set {
            self.layer.cornerRadius = newValue
        }
    }

    @IBInspectable
    var setBorderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        } set {
            self.layer.borderWidth = newValue
        }
    }

    @IBInspectable
    var setBorderColor: UIColor? {
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
    var setShadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }

    @IBInspectable
    var setShadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }

    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }

    @IBInspectable
    var shadowColor: UIColor? {
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

    public func loadNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last ?? ""
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
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

func getDocumentsDirectory() -> NSString {
	let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
	let documentsDirectory = paths[0]
	return documentsDirectory as NSString
}

func clearTempFolder() {
	let fileManager = FileManager.default
	let tempFolderPath = NSTemporaryDirectory()
	do {
		let filePaths = try fileManager.contentsOfDirectory(atPath: tempFolderPath)
		for filePath in filePaths {
			try fileManager.removeItem(atPath: tempFolderPath + filePath)
		}
	} catch {
		print("Could not clear temp folder: \(error)")
	}

}
