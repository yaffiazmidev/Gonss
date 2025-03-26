//
//  KKFloatingActionButtonCell.swift
//  KKFloatingActionButton
//
//  Created by Shuhei Kawaguchi on 2016/11/26.
//  Copyright © 2016年 Shuhei Kawaguchi. All rights reserved.
//

import UIKit

open class KKFloatingActionButtonCell: UIView {
    weak var actionButton: KKFloatingActionButton?
    private let imageView = UIImageView()
    open var image: UIImage? {
        didSet {
            imageView.image = image
            addImageView()
        }
    }
    
    open var internalRatio: CGFloat = 0.75
    open var responsible = true
    
    open var size: CGFloat = 42 {
        didSet {
            self.frame.size = CGSize(width: size, height: size)
            self.layer.cornerRadius = self.frame.size.height/2
            self.center = CGPoint(x: size/2, y: size/2)
            resizeSubviews()
        }
    }
    
    open var color = UIColor(red: 0/255.0, green: 157/255.0, blue: 238/255.0, alpha: 1.0) {
        didSet {
            self.backgroundColor = color
        }
    }
    open var touchingColor: UIColor?
    
    open var shadowOffset: CGSize {
        get { return layer.shadowOffset }
        set { layer.shadowOffset = newValue }
    }
    open var shadowOpacity: Float {
        get { return layer.shadowOpacity }
        set { layer.shadowOpacity = newValue }
    }
    open var shadowRadius: CGFloat {
        get { return layer.shadowRadius }
        set { layer.shadowRadius = newValue }
    }
    open var shadowPath: CGPath? {
        get { return layer.shadowPath }
        set { layer.shadowPath = newValue }
    }
    open var shadowColor: UIColor? {
        get {
            guard let color = layer.shadowColor else { return nil }
            return UIColor(cgColor: color)
        }
        set { layer.shadowColor = newValue?.cgColor }
    }
    open var circlePath: CGPath? {
        return UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: size, height: size)).cgPath
    }
    
    
    // MARK: - init
    public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    // MARK: -
    open func setup() {
        self.backgroundColor = color
        self.clipsToBounds = false
        self.layer.cornerRadius = frame.width / 2
    }
    
    open func addImageView() {
        imageView.clipsToBounds = true
        self.addSubview(imageView)
        resizeSubviews()
    }
    
    open func resizeSubviews() {
        let size = CGSize(width: frame.width * 0.5, height: frame.height * 0.5)
        imageView.frame = CGRect(x: frame.width - frame.width, y: frame.height - frame.height,
                                 width: self.size, height: self.size)
        imageView.layer.cornerRadius = self.size * 0.5
    }
    
    
    // MARK: - Event
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if responsible {
            backgroundColor = touchingColor ?? color.withAlphaComponent(0.5)
        }
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if responsible {
            backgroundColor = color
        }
        if touches.count == 1 && touches.first?.tapCount == 1 {
            if touches.first?.location(in: self) == nil { return }
            actionButton?.didTap(cell: self)
        }
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        if responsible {
            backgroundColor = color
        }
    }
    
}
