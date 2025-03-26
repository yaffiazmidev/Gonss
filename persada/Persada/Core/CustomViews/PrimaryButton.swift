//
//  PrimaryButton.swift
//  Persada
//
//  Created by monggo pesen 3 on 11/06/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class PrimaryButton: UIButton {
	
	struct ButtonState {
		var state: UIControl.State
		var title: String?
		var image: UIImage?
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}
	
    func setup(color: UIColor = UIColor.primary, textColor: UIColor = .white, font: UIFont = .Roboto(.bold, size: 16), activityColor: UIColor = .lightGray) {
		self.layer.cornerRadius = 8
		self.backgroundColor = color
		self.titleLabel?.font = font
		self.contentEdgeInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
		self.setTitleColor(textColor, for: .normal)
        self.activityIndicator.color = activityColor
	}
	
	private (set) var buttonStates: [ButtonState] = []
	private lazy var activityIndicator: UIActivityIndicatorView = {
		let activityIndicator = UIActivityIndicatorView()
		activityIndicator.hidesWhenStopped = true
        activityIndicator.color = self.titleColor(for: .normal) ?? UIColor.lightGray
		self.addSubview(activityIndicator)
		activityIndicator.translatesAutoresizingMaskIntoConstraints = false
		let xCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0)
		let yCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0)
		self.addConstraints([xCenterConstraint, yCenterConstraint])
		return activityIndicator
	}()
	
	func showLoading() {
		activityIndicator.startAnimating()
		var buttonStates: [ButtonState] = []
		for state in [UIControl.State.disabled] {
			let buttonState = ButtonState(state: state, title: title(for: state), image: image(for: state))
			buttonStates.append(buttonState)
			setImage(UIImage(), for: state)
		}
		self.buttonStates = buttonStates
		isEnabled = false
	}
	
	func hideLoading() {
		activityIndicator.stopAnimating()
		for buttonState in buttonStates {
			setImage(buttonState.image, for: buttonState.state)
		}
		isEnabled = true
	}
	
}
