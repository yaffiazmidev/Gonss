//
//  UIScrollView+VisibleRect.swift
//  KipasKipasShared
//
//  Created by Rahmat Trinanda Pramudya Amar on 04/06/24.
//

import UIKit

public extension UIScrollView {
    func visibleRect() -> CGRect {
        let visibleWidth = bounds.width / zoomScale
        let visibleHeight = bounds.height / zoomScale
        
        let offsetX = contentOffset.x / zoomScale
        let offsetY = contentOffset.y / zoomScale
        
        return CGRect(x: offsetX, y: offsetY, width: visibleWidth, height: visibleHeight)
    }
    
    func visibleRect(for imageView: UIImageView) -> CGRect {
        guard let _ = imageView.image else { return CGRect.zero }
        return visibleRect()
    }
}
