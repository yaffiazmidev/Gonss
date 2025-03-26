import UIKit

public struct FontName {
    public enum Roboto: String, CaseIterable {
        case thin = "Roboto-Thin"
        case light = "Roboto-Light"
        case regular = "Roboto-Regular"
        case medium = "Roboto-Medium"
        case bold = "Roboto-Bold"
        case black = "Roboto-Black"
    }
    
    public enum Airbnb: String, CaseIterable {
        case light = "AirbnbCerealApp-Light"
        case medium = "AirbnbCerealApp-Medium"
        case bold = "AirbnbCerealApp-Bold"
        case black = "AirbnbCerealApp-Black"
        case extraBold = "AirbnbCerealApp-ExtraBold"
        case book = "AirbnbCerealApp-Book"
    }
    
    public enum Rye: String {
        case regular = "Rye-Regular"
    }
}

public extension UIFont {
    
    static let loadCustomFonts: () = {
        loadRobotoFonts()
        loadAirbnbFonts()
        loadRyeFonts()
    }()
   
    static func roboto(_ roboto: FontName.Roboto, size: CGFloat) -> UIFont {
        return UIFont(name: roboto.rawValue, size: size)!
    }
    
    static func roboto(_ roboto: FontName.Roboto, adaptedSize: CGFloat) -> UIFont {
        return UIFont(name: roboto.rawValue, size: adaptedSize.adaptedFontSize)!
    }
    
    static func airbnb(_ airbnb: FontName.Airbnb, size: CGFloat) -> UIFont {
        return UIFont(name: airbnb.rawValue, size: size)!
    }
    
    static func rye(_ rye: FontName.Rye, size: CGFloat) -> UIFont {
        return UIFont(name: rye.rawValue, size: size)!
    }
    
    static func rye(_ rye: FontName.Rye, adaptedSize: CGFloat) -> UIFont {
        return UIFont(name: rye.rawValue, size: adaptedSize.adaptedFontSize)!
    }
}

private extension UIFont {
    
    private class Typography {}
    
    private static func loadFont(_ fontName: String) {
        let bundle = Bundle(for: Typography.self)
        let path = bundle.path(forResource: fontName, ofType: "ttf")
        let fontData = NSData(contentsOfFile: path!)
        let dataProvider = CGDataProvider(data: fontData!)
        
        if let fontRef = CGFont(dataProvider!) {
            var error: Unmanaged<CFError>?
            if CTFontManagerRegisterGraphicsFont(fontRef, &error) == false {
                let message = error.debugDescription
                error?.release()
                //throw RegisterFontError.init(errorMessage: message)
                NSLog("Failed to register font - register graphics font failed - this font may have already been registered in the main bundle.")
            }
        }
                
//        var errorRef: Unmanaged<CFError>? = nil
//        
//        if CTFontManagerRegisterGraphicsFont(fontRef!, &errorRef) == false {
//            NSLog("Failed to register font - register graphics font failed - this font may have already been registered in the main bundle.")
//        }

    }
    
    static func loadRobotoFonts() {
        FontName.Roboto.allCases.forEach { name in
            loadFont(name.rawValue)
        }
    }
    
    static func loadAirbnbFonts() {
        FontName.Airbnb.allCases.forEach { name in
            loadFont(name.rawValue)
        }
    }
    
    static func loadRyeFonts() {
        loadFont(FontName.Rye.regular.rawValue)
    }
}
