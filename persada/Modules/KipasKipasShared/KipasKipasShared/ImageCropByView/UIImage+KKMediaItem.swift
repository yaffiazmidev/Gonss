//
//  UIImage+KKMediaItem.swift
//  KipasKipasShared
//
//  Created by Rahmat Trinanda Pramudya Amar on 04/06/24.
//

import UIKit

public extension UIImage {
    func toMediaItem() -> KKMediaItem? {
        return KKMediaHelper.instance.photo(image: self)
    }
}
