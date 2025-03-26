//
//  UIColor.swift
//  Persada
//
//  Created by Muhammad Noor on 12/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import UIKit

//MARK: ADD YOUR HARCODED COLOR IN HERE
extension UIColor {
    public static let orangeLowTint = UIColor(named: "orangeLowTint", in: SharedBundle.shared.bundle, compatibleWith: nil)!
	public static let warning = UIColor(named: "warning", in: SharedBundle.shared.bundle, compatibleWith: nil)!
	public static let whiteSnow = UIColor(named: "whiteSnow", in: SharedBundle.shared.bundle, compatibleWith: nil)!
	public static let whiteSmoke = UIColor(named: "whiteSmoke", in: SharedBundle.shared.bundle, compatibleWith: nil)!
	public static let primary = UIColor(named: "primary", in: SharedBundle.shared.bundle, compatibleWith: nil)!
	public static let primaryLowTint = UIColor(named: "primaryLowTint", in: SharedBundle.shared.bundle, compatibleWith: nil)!
	public static let gainsboro = UIColor(named: "gainsboro", in: SharedBundle.shared.bundle, compatibleWith: nil)!
	public static let orangeColor = UIColor(named: "orangeColor", in: SharedBundle.shared.bundle, compatibleWith: nil)!
	public static let grey = UIColor(named: "grey", in: SharedBundle.shared.bundle, compatibleWith: nil)!
	public static let greyAlpha4 = UIColor(named: "greyAlpha4", in: SharedBundle.shared.bundle, compatibleWith: nil)!
	public static let secondary = UIColor(named: "secondary", in: SharedBundle.shared.bundle, compatibleWith: nil)!
	public static let placeholder = UIColor(named: "placeholder", in: SharedBundle.shared.bundle, compatibleWith: nil)!
	public static let secondaryLowTint = UIColor(named: "secondaryLowTint", in: SharedBundle.shared.bundle, compatibleWith: nil)!
	public static let contentGrey = UIColor(named: "contentGrey", in: SharedBundle.shared.bundle, compatibleWith: nil)!
	public static let safetyOrange = UIColor(named: "safetyOrange", in: SharedBundle.shared.bundle, compatibleWith: nil)!
	public static let redError = UIColor(named: "redError", in: SharedBundle.shared.bundle, compatibleWith: nil)!
	public static let blackTransparent = UIColor(named: "blackTransparent", in: SharedBundle.shared.bundle, compatibleWith: nil)!
	public static let success = UIColor(named: "success", in: SharedBundle.shared.bundle, compatibleWith: nil)!
	public static let blueWhite = UIColor(named: "blueWhite", in: SharedBundle.shared.bundle, compatibleWith: nil)!
	public static let greyAlpha9 = UIColor(named: "greyAlpha9", in: SharedBundle.shared.bundle, compatibleWith: nil)!
	public static let greenKelly = UIColor(named: "greenKelly", in: SharedBundle.shared.bundle, compatibleWith: nil)!
	public static let black25 = UIColor(named: "black25", in: SharedBundle.shared.bundle, compatibleWith: nil)!
	public static let greenWhite = UIColor(named: "greenWhite", in: SharedBundle.shared.bundle, compatibleWith: nil)!
	public static let gradientStoryOne = UIColor(named: "gradientStoryOne", in: SharedBundle.shared.bundle, compatibleWith: nil)!
	public static let gradientStoryTwo = UIColor(named: "gradientStoryTwo", in: SharedBundle.shared.bundle, compatibleWith: nil)!
    public static let cleepsBlack = UIColor(named: "cleepsBlack", in: SharedBundle.shared.bundle, compatibleWith: nil)!
    public static let primaryPink = UIColor(named: "primaryPink", in: SharedBundle.shared.bundle, compatibleWith: nil)!
    public static let blueCetacean = UIColor(named: "blueCetacean", in: SharedBundle.shared.bundle, compatibleWith: nil)!
    public static let lightSilver = UIColor(named: "lightSilver", in: SharedBundle.shared.bundle, compatibleWith: nil)!
    public static let whiteAlpha30 = UIColor(named: "whiteAlpha30", in: SharedBundle.shared.bundle, compatibleWith: nil)!
    public static let unselectedTab = UIColor(named: "unselectedTab")!
	
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    static func darkModeColor(hexString: String) -> UIColor {
        let lightColor = UIColor(hexString: hexString)
        return {
            if #available(iOS 13.0, *) {
                return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                    switch traitCollection.userInterfaceStyle {
                        case
                        .unspecified,
                        .light: return lightColor
                        case .dark: return lightColor.inverted
                        @unknown default:
                            return lightColor
                    }
                }
            } else {
                return lightColor
            }
            }()
    }
    
    static func modedColor(light: String, dark: String) -> UIColor {
        let lightColor = UIColor(hexString: light)
        let darkColor = UIColor(hexString: dark)
        return {
            if #available(iOS 13.0, *) {
                return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                    switch traitCollection.userInterfaceStyle {
                        case
                        .unspecified,
                        .light: return lightColor
                        case .dark: return darkColor
                        @unknown default:
                            return lightColor
                    }
                }
            } else {
                return lightColor
            }
            }()
    }
    
    var inverted: UIColor {
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: (1 - r), green: (1 - g), blue: (1 - b), alpha: a)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"#%06x", rgb)
    }
    
    func components() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        guard let c = cgColor.components else { return (0, 0, 0, 1) }
        if cgColor.numberOfComponents == 2 {
            return (c[0], c[0], c[0], c[1])
        } else {
            return (c[0], c[1], c[2], c[3])
        }
    }

    static func interpolate(from: UIColor, to: UIColor, with fraction: CGFloat) -> UIColor {
        let f = min(1, max(0, fraction))
        let c1 = from.components()
        let c2 = to.components()
        let r = c1.0 + (c2.0 - c1.0) * f
        let g = c1.1 + (c2.1 - c1.1) * f
        let b = c1.2 + (c2.2 - c1.2) * f
        let a = c1.3 + (c2.3 - c1.3) * f
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }

}
