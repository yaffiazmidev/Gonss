//
//  ZoomableViewDelegate.swift
//  KipasKipasShared
//
//  Created by Rahmat Trinanda Pramudya Amar on 30/01/24.
//

import UIKit

public protocol ZoomableViewDelegate: AnyObject {
    func zoomableViewShouldZoom(_ view: ZoomableView) -> Bool
    func zoomableViewDidZoom(_ view: ZoomableView)
    func zoomableViewEndZoom(_ view: ZoomableView)
    func zoomableViewGetBackground(_ view: ZoomableView) -> UIView?
}

extension ZoomableViewDelegate {
    func zoomableViewShouldZoom(_ view: ZoomableView) -> Bool {
        return true
    }
    
    func zoomableViewGetBackground(_ view: ZoomableView) -> UIView? {
        return nil
    }
}
