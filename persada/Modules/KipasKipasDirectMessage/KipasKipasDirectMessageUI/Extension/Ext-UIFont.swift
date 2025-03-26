//
//  Ext-UIFont.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 12/07/23.
//

import UIKit

extension UIFont {
    
    enum RobotoType: String {
        case medium = "-Medium"
        case regular = "-Regular"
        case light = "-Light"
        case extraBold = "-Black"
        case bold = "-Bold"
    }
    
    static func Roboto(_ type: RobotoType = .regular, size: CGFloat = UIFont.systemFontSize) -> UIFont {
        registerFontsIfNeeded()
        return UIFont(name: "Roboto\(type.rawValue)", size: size)!
    }
    
    var isBold: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitBold)
    }
    
    var isItalic: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitItalic)
    }
    
}

extension UIFont {

    private static var fontsRegistered: Bool = false

    static func registerFontsIfNeeded() {
        
        guard
            !fontsRegistered,
            let fontURLs = SharedBundle.shared.bundle.urls(forResourcesWithExtension: "ttf", subdirectory: nil)
        else { return }

        fontURLs.forEach({ CTFontManagerRegisterFontsForURL($0 as CFURL, .process, nil) })
        fontsRegistered = true
    }
}
