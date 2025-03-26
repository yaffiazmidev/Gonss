//
//  UIImageView+Crop.swift
//  KipasKipasShared
//
//  Created by Rahmat Trinanda Pramudya Amar on 04/06/24.
//

import UIKit

public extension UIImageView {
    func crop(rect: CGRect) -> UIImage? {
        guard let image = image else { return nil }
        
        if let cgImage = image.cgImage?.cropping(to: rect) {
            let croppedImage = UIImage(cgImage: cgImage)
            return croppedImage
        }
        
        return nil
    }
    
    func crop() -> UIImage? {
        return crop(rect: bounds)
    }
}
