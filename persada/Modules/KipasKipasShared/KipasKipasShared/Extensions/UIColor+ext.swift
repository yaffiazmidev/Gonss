import UIKit

/**
 These custom color values and names are generated via:
 https://colors.artyclick.com/color-name-finder/
 &
 https://uicolor.io
 */
public extension UIColor {
    
    private class Resource {}
    
    static var bundle: Bundle {
        return Bundle(for: Resource.self)
    }
    
    /// HEX: #4A4A4A
    static let gravel = UIColor(red: 0.29, green: 0.29, blue: 0.29, alpha: 1.00)
    
    /// HEX: #505D4D
    static let liver = UIColor(red: 0.31, green: 0.30, blue: 0.30, alpha: 1.00)
    
    /// HEX: #18D1E0
    static let aquaBlue = UIColor(red: 0.09, green: 0.82, blue: 0.88, alpha: 1.00)
    
    /// HEX: #E7F3FF
    static let water = UIColor(red: 0.91, green: 0.95, blue: 1.00, alpha: 1.00)
    
    /// HEX: #1890FF
    static let azure = UIColor(red: 0.09, green: 0.56, blue: 1.00, alpha: 1.00)
    
    /// HEX: #FF4265
    static let watermelon = UIColor(red: 1.00, green: 0.26, blue: 0.40, alpha: 1.00)
    
    /// HEX: #EEEEEE
    static let softPeach = UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1.00)
    
    /// HEX: #BBBBBB
    static let ashGrey = UIColor(red: 0.73, green: 0.73, blue: 0.73, alpha: 1.00)
    
    /// HEX: #3478F6
    static let chatBlue = UIColor(hexString: "3478F6")
    
    /// HEX: #E70000
    static let brightRed = UIColor(red: 0.91, green: 0.00, blue: 0.00, alpha: 1.00)
    
    /// HEX: #777777
    static let boulder = UIColor(red: 0.47, green: 0.47, blue: 0.47, alpha: 1.00)
    
    /// HEX: #DDDDDD
    static let gainsboro = UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1.00)
    
    /// HEX: #FAFAFA
    static let alabaster = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.00)
    
    /// HEX: #320647
    static let deepPurple = UIColor(red: 0.197, green: 0.023, blue: 0.279, alpha: 1.00)
    
    /// HEX: #FF8A00
    static let carrot = UIColor(red: 1.00, green: 0.54, blue: 0.00, alpha: 1.00)
    
    /// HEX: #E0BDF0
    static let mauve = UIColor(red: 0.88, green: 0.74, blue: 0.94, alpha: 1.00)
    
    /// HEX: #F9F9F9
    static let snowDrift = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.00)
    
    /// HEX: #FFA4B5
    static let sweetPink = UIColor(red: 1.00, green: 0.64, blue: 0.71, alpha: 1.00)
    
    /// HEX: #10012F
    static let midnightBlue = UIColor(red: 0.06, green: 0.00, blue: 0.18, alpha: 1.00)
    
    /// HEX: #212227
    static let mirage = UIColor(red: 0.13, green: 0.13, blue: 0.15, alpha: 1.00)
    
    /// HEX: #2D2D2D
    static let gunMetal = UIColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1.00)
    
    /// HEX: #000000
    static let night = UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 1.00)
    
    /// HEX: #C90000
    static let scarlet = UIColor(red: 0.79, green: 0.00, blue: 0.00, alpha: 1.00)
    
    /// HEX: #E70000
    static let ferrariRed = UIColor(red: 0.91, green: 0.00, blue: 0.00, alpha: 1.00)
    
    /// HEX: #52C41A
    static let alien = UIColor(red: 0.32, green: 0.77, blue: 0.10, alpha: 1.00)
    
    /// HEX: #F2F2F2
    static let porcelain = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.00)
    
    /// HEX: #FFEED1
    static let oasis = UIColor(red: 1.00, green: 0.93, blue: 0.82, alpha: 1.00)
    
    /// HEX: #FFB68C
    static let paleSalmon = UIColor(red: 1.00, green: 0.71, blue: 0.55, alpha: 1.00)
    
    /// HEX: #AB3442
    static let paleCarmine = UIColor(red: 0.67, green: 0.20, blue: 0.26, alpha: 1.00)
    
    /// HEX: #FFE4B5
    static let palePeach = UIColor(red: 1.00, green: 0.89, blue: 0.71, alpha: 1.00)
    
    /// HEX: #6A0000
    static let redOxide = UIColor(red: 0.42, green: 0.00, blue: 0.00, alpha: 1.00)
}

public extension UIColor {
    static let black25 = UIColor(named: "black25", in: bundle, compatibleWith: nil)!
    static let blackTransparent = UIColor(named: "blackTransparent", in: bundle, compatibleWith: nil)!
    static let blueWhite = UIColor(named: "blueWhite", in: bundle, compatibleWith: nil)!
    static let cleepsBlack = UIColor(named: "cleepsBlack", in: bundle, compatibleWith: nil)!
    static let contentGrey = UIColor(named: "contentGrey", in: bundle, compatibleWith: nil)!
//    static let gainsboro = UIColor(named: "gainsboro")!
    static let gradientStoryOne = UIColor(named: "gradientStoryOne", in: bundle, compatibleWith: nil)!
    static let gradientStoryTwo = UIColor(named: "gradientStoryTwo", in: bundle, compatibleWith: nil)!
    static let greenKelly = UIColor(named: "greenKelly", in: bundle, compatibleWith: nil)!
    static let greenLawn = UIColor(named: "greenLawn", in: bundle, compatibleWith: nil)!
    static let greenWhite = UIColor(named: "greenWhite", in: bundle, compatibleWith: nil)!
    static let grey = UIColor(named: "grey", in: bundle, compatibleWith: nil)!
    static let greyAlpha4 = UIColor(named: "greyAlpha4", in: bundle, compatibleWith: nil)!
    static let greyAlpha9 = UIColor(named: "greyAlpha9", in: bundle, compatibleWith: nil)!
    static let orangeColor = UIColor(named: "orangeColor", in: bundle, compatibleWith: nil)!
    static let orangeLowTint = UIColor(named: "orangeLowTint", in: bundle, compatibleWith: nil)!
    static let placeholder = UIColor(red: 0.73, green: 0.73, blue: 0.73, alpha: 1.00)
    static let primary = UIColor(named: "primary", in: bundle, compatibleWith: nil)!
    static let primaryDisabled = UIColor(named: "primaryDisabled", in: bundle, compatibleWith: nil)!
    static let primaryLowTint = UIColor(named: "primaryLowTint", in: bundle, compatibleWith: nil)!
    static let primaryPink = UIColor(named: "primaryPink", in: bundle, compatibleWith: nil)!
    static let redError = UIColor(named: "redError", in: bundle, compatibleWith: nil)!
    static let safetyOrange = UIColor(named: "safetyOrange", in: bundle, compatibleWith: nil)!
    static let secondary = UIColor(named: "secondary", in: bundle, compatibleWith: nil)!
    static let secondaryLowTint = UIColor(named: "secondaryLowTint", in: bundle, compatibleWith: nil)!
    static let shimmer = UIColor(named: "shimmer", in: bundle, compatibleWith: nil)!
    static let silver = UIColor(named: "silver", in: bundle, compatibleWith: nil)!
    static let success = UIColor(named: "success", in: bundle, compatibleWith: nil)!
    static let unselectedTab = UIColor(named: "unselectedTab", in: bundle, compatibleWith: nil)!
    static let warning = UIColor(named: "warning", in: bundle, compatibleWith: nil)!
    static let whiteAlpha30 = UIColor(red: 1.00, green: 1.0, blue: 1.0, alpha: 0.3)
    static let whiteAlpha50 = UIColor(named: "whiteAlpha50", in: bundle, compatibleWith: nil)!
    static let whiteSmoke = UIColor(named: "whiteSmoke", in: bundle, compatibleWith: nil)!
    static let whiteSnow = UIColor(named: "whiteSnow", in: bundle, compatibleWith: nil)!
}

public extension UIColor {
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
}


infix operator |: AdditionPrecedence
public extension UIColor {
    
    /// Easily define two colors for both light and dark mode.
    /// - Parameters:
    ///   - lightMode: The color to use in light mode.
    ///   - darkMode: The color to use in dark mode.
    /// - Returns: A dynamic color that uses both given colors respectively for the given user interface style.
    static func | (lightMode: UIColor, darkMode: UIColor) -> UIColor {
        return UIColor { (traitCollection) -> UIColor in
            return traitCollection.userInterfaceStyle == .light ? lightMode : darkMode
        }
    }
}
