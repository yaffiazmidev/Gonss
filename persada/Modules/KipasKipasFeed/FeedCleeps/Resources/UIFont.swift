//
//  Fonts.swift
//  Persada
//
//  Created by monggo pesen 3 on 17/06/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

extension UIFont {
	
	public enum RobotoFontType: String {
		case medium = "-Medium"
		case regular = "-Regular"
		case light = "-Light"
		case extraBold = "-Black"
		case bold = "-Bold"
	}
	
	static func Roboto(_ type: RobotoFontType = .regular, size: CGFloat = UIFont.systemFontSize) -> UIFont {
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
