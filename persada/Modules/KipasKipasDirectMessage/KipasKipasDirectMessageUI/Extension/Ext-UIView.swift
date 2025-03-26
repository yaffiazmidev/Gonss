//
//  Ext-UIView.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 15/07/23.
//

import UIKit

private var tapGestureKey: Void?
//private var longPressGestureKey: Void?

extension UIView {
    func onTap(action: (() -> Void)?) {
        isUserInteractionEnabled = true
        objc_setAssociatedObject(self, &tapGestureKey, action, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapViewGesture(_:)))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func handleTapViewGesture(_ sender: UITapGestureRecognizer) {
        if let completion = objc_getAssociatedObject(self, &tapGestureKey) as? () -> Void {
            completion()
        }
    }
    
//    func onLongPress(action: (() -> Void)?) {
//        isUserInteractionEnabled = true
//        objc_setAssociatedObject(self, &longPressGestureKey, action, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        let longTapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressViewGesture(_:)))
//        longTapGestureRecognizer.minimumPressDuration = 1
//        addGestureRecognizer(longTapGestureRecognizer)
//        
//    }
//    
//    @objc private func handleLongPressViewGesture(_ sender: UITapGestureRecognizer) {
//        if let completion = objc_getAssociatedObject(self, &longPressGestureKey) as? () -> Void {
//            completion()
//        }
//    }
}

extension UIView {
    func loadViewFromNib<T: UIView>() -> T {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        return nib.instantiate(withOwner: self, options: nil).first as! T
    }
}

extension UIView {
    var isDeviceWithHomeButton: Bool {
        get {
            guard UIDevice.current.userInterfaceIdiom == .phone else {
                return false
            }
            
            let nativeBoundsHeight = UIScreen.main.nativeBounds.height
            
            guard nativeBoundsHeight == 1334 || nativeBoundsHeight == 1920 || nativeBoundsHeight == 2208 else {
                return false
            }
            
            return true
        }
    }
    
    func createSwipeImage(imgName:String,title:String,bgColor: String) -> UIImage {
        let view = UIView(frame: CGRectMake(0, 0, 69, 77))
        view.backgroundColor =  UIColor(hexString: bgColor)
        let imageV  = UIImageView.init(frame: CGRectMake(20.5, 13, 28, 28))
        imageV.image = .set(imgName)
        view.addSubview(imageV)
        let label = UILabel.init(frame: CGRectMake(0, 47, 69, 30))
        label.text = title
        label.font = .roboto(.regular, size: 12)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .white
        view.addSubview(label)
         
         let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
         let image = renderer.image { rendererContext in
            view.layer.render(in: rendererContext.cgContext)
          }
          if let cgImage = image.cgImage {
            return UIImage.init(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
          } else {
            return UIImage()
          }
    }
}
