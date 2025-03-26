//
//  FloatingStackView.swift
//  FeedCleeps
//
//  Created by Rahmat Trinanda Pramudya Amar on 10/04/23.
//

import UIKit

open class FloatingStackView: UIStackView {
    @IBInspectable public var viewMargin: UIEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDrag)))
    }
    
    @objc open func handleDrag(gesture: UIPanGestureRecognizer){
        guard let superview = self.superview else { return }
        let location = gesture.location(in: superview)
        let draggedView = gesture.view
        draggedView?.center = location
        
        if gesture.state == .ended {
            if self.frame.midX >= superview.layer.frame.width / 2 {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                    self.center.x = superview.layer.frame.width - (self.viewMargin.right + self.bounds.width / 2)
                    
                    //Bottom Safe
                    if (self.frame.midY + (self.bounds.height / 2)) > superview.layer.frame.maxY {
                        self.center.y = superview.layer.frame.maxY - (self.viewMargin.bottom + self.bounds.height / 2)
                    }
                    
                    //Top Safe
                    if (self.frame.midY + (self.bounds.height / 2)) < self.viewMargin.top {
                        self.center.y = self.viewMargin.top + self.bounds.height / 2
                    }
                }, completion: nil)
            } else {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                    self.center.x = (self.viewMargin.left + self.bounds.width / 2)
                    
                    //Bottom Safe
                    if (self.frame.midY + (self.bounds.height / 2)) > superview.layer.frame.maxY {
                        self.center.y = superview.layer.frame.maxY - (self.viewMargin.bottom + self.bounds.height / 2)
                    }
                    
                    //Top Safe
                    if (self.frame.midY + (self.bounds.height / 2)) < self.viewMargin.top {
                        self.center.y = self.viewMargin.top + self.bounds.height / 2
                    }
                }, completion: nil)
            }
        }
    }
}
