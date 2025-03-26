import UIKit
import KipasKipasShared

extension StoryEditorViewController: UIGestureRecognizerDelegate {
    /*
     Support Multiple Gesture at the same time
     */
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    override public var prefersStatusBarHidden: Bool {
        return true
    }
    
    func addGestures(for view: UIView) {
        view.isUserInteractionEnabled = true
        
        let panGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(panGesture)
        )
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(
            target: self,
            action: #selector(pinchGesture)
        )
        pinchGesture.delegate = self
        view.addGestureRecognizer(pinchGesture)
        
        let rotationGestureRecognizer = UIRotationGestureRecognizer(
            target: self,
            action: #selector(rotationGesture)
        )
        rotationGestureRecognizer.delegate = self
        view.addGestureRecognizer(rotationGestureRecognizer)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        view.addGestureRecognizer(tapGesture)
        
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        view.addGestureRecognizer(longTapGesture)
    }
    
    /**
     UIPanGestureRecognizer - Moving Objects
     Selecting transparent parts of the imageview won't move the object
     */
    @objc private func panGesture(_ recognizer: UIPanGestureRecognizer) {
        if let view = recognizer.view {
            if view is UIImageView {
                //Tap only on visible parts on the image
                if recognizer.state == .began {
                    for imageView in subImageViews(view: overlayView) {
                        let location = recognizer.location(in: imageView)
                        let alpha = imageView.alphaAtPoint(location)
                        if alpha > 0 {
                            imageViewToPan = imageView
                            break
                        }
                    }
                }
                if imageViewToPan != nil {
                    moveView(view: imageViewToPan!, recognizer: recognizer)
                }
            } else {
                moveView(view: view, recognizer: recognizer)
            }
        }
    }
    
    /**
     Moving Objects
     delete the view if it's inside the delete view
     Snap the view back if it's out of the canvas
     */
    
    private func moveView(view: UIView, recognizer: UIPanGestureRecognizer)  {
        
        delegate?.didEnterEditingMode()
        
        deleteButton.isHidden = false
        
        view.superview?.bringSubviewToFront(view)
        let pointToSuperView = recognizer.location(in: self.view)
        
        view.center = CGPoint(x: view.center.x + recognizer.translation(in: overlayView).x,
                              y: view.center.y + recognizer.translation(in: overlayView).y)
        
        recognizer.setTranslation(CGPoint.zero, in: overlayView)
        
        if let previousPoint = lastPanPoint {
            //View is going into deleteView
            if deleteButton.frame.contains(pointToSuperView) && !deleteButton.frame.contains(previousPoint) {
                deleteButton.backgroundColor = .red
                
                if #available(iOS 10.0, *) {
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.impactOccurred()
                }
                UIView.animate(withDuration: 0.3, animations: {
                    view.transform = view.transform.scaledBy(x: 0.25, y: 0.25)
                    view.center = recognizer.location(in: self.overlayView)
                })
                //View is going out of deleteView
            } else if deleteButton.frame.contains(previousPoint) && !deleteButton.frame.contains(pointToSuperView) {
                deleteButton.backgroundColor = .clear
                
                //Scale to original Size
                UIView.animate(withDuration: 0.3, animations: {
                    view.transform = view.transform.scaledBy(x: 4, y: 4)
                    view.center = recognizer.location(in: self.overlayView)
                })
            }
        }
        lastPanPoint = pointToSuperView
        
        if recognizer.state == .ended {
            imageViewToPan = nil
            lastPanPoint = nil
            delegate?.didExitEditingMode()
            deleteButton.isHidden = true
            
            let point = recognizer.location(in: self.view)
            
            if deleteButton.frame.contains(point) { // Delete the view
                view.removeFromSuperview()
                if #available(iOS 10.0, *) {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
            } else if !overlayView.bounds.contains(view.center) { //Snap the view back to canvasImageView
                UIView.animate(withDuration: 0.3, animations: {
                    view.center = self.overlayView.center
                })
            }
        }
    }
    
    /**
     UIPinchGestureRecognizer - Pinching Objects
     If it's a UITextView will make the font bigger so it doen't look pixlated
     */
    @objc private func pinchGesture(_ recognizer: UIPinchGestureRecognizer) {
        if let view = recognizer.view {
            if view is UITextView {
                let textView = view as! UITextView

                let font = UIFont(
                    name: textView.font!.fontName,
                    size: textView.font!.pointSize * recognizer.scale
                )
                textView.font = font
                textView.calculateSize(isUsingGesture: true)
                
            } else {
                view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            }
            
            recognizer.scale = 1
        }
    }
    
    @objc private func longPress(_ recognizer: UILongPressGestureRecognizer) {
        if let view = recognizer.view {
            if let textView = view as? UITextView, recognizer.state == .began {
                textView.removeFromSuperview()
                textView.gestureRecognizers?.removeAll()
                switchToTextEditingMode(editingTextView: textView)
            }
        }
    }
    
    /**
     UIRotationGestureRecognizer - Rotating Objects
     */
    @objc private func rotationGesture(_ recognizer: UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            if recognizer.state == .began || recognizer.state == .changed {
                // Apply the rotation transform to the view
                view.transform = view.transform.rotated(by: recognizer.rotation)
                recognizer.rotation = 0
            }
        }
    }
    
    /**
     UITapGestureRecognizer - Taping on Objects
     Will make scale scale Effect
     Selecting transparent parts of the imageview won't move the object
     */
    @objc private func tapGesture(_ recognizer: UITapGestureRecognizer) {
        if let view = recognizer.view {
            if view is UIImageView {
                //Tap only on visible parts on the image
                for imageView in subImageViews(view: overlayView) {
                    let location = recognizer.location(in: imageView)
                    let alpha = imageView.alphaAtPoint(location)
                    if alpha > 0 {
                        scaleEffect(view: imageView)
                        break
                    }
                }
            } else {
                scaleEffect(view: view)
            }
        }
    }
    
    /**
     Scale Effect
     */
    private func scaleEffect(view: UIView) {
        view.superview?.bringSubviewToFront(view)
        
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
        
        let previouTransform =  view.transform
        UIView.animate(
            withDuration: 0.2,
            animations: {
                view.transform = view.transform.scaledBy(x: 1.2, y: 1.2)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    view.transform  = previouTransform
                }
            })
    }
    
    private func subImageViews(view: UIView) -> [UIImageView] {
        var imageviews: [UIImageView] = []
        for imageView in view.subviews {
            if imageView is UIImageView {
                imageviews.append(imageView as! UIImageView)
            }
        }
        return imageviews
    }
}

