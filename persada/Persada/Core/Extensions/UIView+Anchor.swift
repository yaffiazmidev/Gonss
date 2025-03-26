//
//  UIView+Anchor.swift
//  Formalitas
//
//  Created by NOOR on 18/03/20.
//  Copyright © 2020 NOOR. All rights reserved.
//

import UIKit

extension UIView {
    func setEdges(
        top: CGFloat = 0,
        right: CGFloat = 0,
        bottom: CGFloat = 0,
        left: CGFloat = 0
    ) {
        guard let superview = superview else { return }
        anchor(
            .leading(superview.leadingAnchor, constant: left),
            .top(superview.topAnchor, constant: top),
            .trailing(superview.trailingAnchor, constant: right),
            .bottom(superview.bottomAnchor, constant: bottom)
        )
    }
}

extension UIView {

	// MARK: - Public Methods

	func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?,  paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {

		translatesAutoresizingMaskIntoConstraints = false

		if let top = top {
			self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
		}

		if let left = left {
			self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
		}

		if let bottom = bottom {
			bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
		}

		if let right = right {
			rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
		}

		if width != 0 {
			widthAnchor.constraint(equalToConstant: width).isActive = true
		}

		if height != 0 {
			heightAnchor.constraint(equalToConstant: height).isActive = true
		}
	}

	func anchor(top: NSLayoutYAxisAnchor? = nil,
							left: NSLayoutXAxisAnchor? = nil,
							bottom: NSLayoutYAxisAnchor? = nil,
							right: NSLayoutXAxisAnchor? = nil,
							paddingTop: CGFloat = 0,
							paddingLeft: CGFloat = 0,
							paddingBottom: CGFloat = 0,
							paddingRight: CGFloat = 0,
							width: CGFloat? = nil,
							height: CGFloat? = nil) {

		translatesAutoresizingMaskIntoConstraints = false

		if let top = top {
			topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
		}

		if let left = left {
			leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
		}

		if let bottom = bottom {
			bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
		}

		if let right = right {
			rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
		}

		if let width = width {
			widthAnchor.constraint(equalToConstant: width).isActive = true
		}

		if let height = height {
			heightAnchor.constraint(equalToConstant: height).isActive = true
		}
	}

	func centerY(inView view: UIView, leftAnchor: NSLayoutXAxisAnchor? = nil, paddingLeft: CGFloat? = nil, constant: CGFloat? = 0) {
		translatesAutoresizingMaskIntoConstraints = false

		centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant!).isActive = true

		if let leftAnchor = leftAnchor, let padding = paddingLeft {
			self.leftAnchor.constraint(equalTo: leftAnchor, constant: padding).isActive = true
		}
	}

	func centerX(inView view: UIView, topAnchor: NSLayoutYAxisAnchor? = nil, paddingTop: CGFloat? = 0) {
		translatesAutoresizingMaskIntoConstraints = false
		centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

		if let topAnchor = topAnchor {
			self.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop!).isActive = true
		}
	}
	
	func keepCenterAndApplyAnchorPoint(_ point: CGPoint) {
			
			guard layer.anchorPoint != point else { return }
			
			var newPoint = CGPoint(x: bounds.size.width * point.x, y: bounds.size.height * point.y)
			var oldPoint = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y)
			
			newPoint = newPoint.applying(transform)
			oldPoint = oldPoint.applying(transform)
			
			var c = layer.position
			c.x -= oldPoint.x
			c.x += newPoint.x
			
			c.y -= oldPoint.y
			c.y += newPoint.y
			
			layer.position = c
			layer.anchorPoint = point
	}
	
	func endFunction(){}
	
	public func addBottomSeparator(margin: CGFloat = 8){
			
			let vw_separator = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
			vw_separator.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
			self.addSubview(vw_separator)
			
			vw_separator.translatesAutoresizingMaskIntoConstraints = false
			NSLayoutConstraint.activate([
					//text_field: Constraint
					vw_separator.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: margin),
					self.trailingAnchor.constraint(equalTo: vw_separator.trailingAnchor, constant: margin),
					self.bottomAnchor.constraint(equalTo: vw_separator.bottomAnchor, constant: 0),
					vw_separator.heightAnchor.constraint(equalToConstant: 0.5)
			])
			
	}
	
	public func addTopSeparator(margin: CGFloat = 8){
			
			let vw_separator = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
			vw_separator.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
			self.addSubview(vw_separator)
			
			vw_separator.translatesAutoresizingMaskIntoConstraints = false
			NSLayoutConstraint.activate([
					//text_field: Constraint
					vw_separator.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: margin),
					self.trailingAnchor.constraint(equalTo: vw_separator.trailingAnchor, constant: margin),
					self.topAnchor.constraint(equalTo: vw_separator.topAnchor, constant: 0),
					vw_separator.heightAnchor.constraint(equalToConstant: 0.5)
			])
			
	}
}
