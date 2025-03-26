//
//  ComponentViewHeader.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 19/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class ComponentViewHeader: UIView {
		
		private let lblTitle = UILabel(frame: .zero)
		private var actionClick : () -> () = {}
		
		override init(frame: CGRect) {
				super.init(frame: frame)
				backgroundColor = UIColor.white
				addBottomSeparator(margin: 0)
				translatesAutoresizingMaskIntoConstraints = false
				
				let backButton = UIButton(type: .system)
				backButton.addTarget(self, action: #selector(actionBack), for: .touchUpInside)
				backButton.translatesAutoresizingMaskIntoConstraints = false
				backButton.setImage(UIImage(named: .get(.arrowleft)), for: .normal)
				backButton.tintColor = UIColor.black
				addSubview(backButton)
				
				lblTitle.text = ""
				lblTitle.translatesAutoresizingMaskIntoConstraints = false
				lblTitle.textColor = .black
				lblTitle.font = .systemFont(ofSize: 16, weight: .semibold)
				addSubview(lblTitle)
				
				NSLayoutConstraint.activate([
						backButton.topAnchor.constraint(equalTo: topAnchor),
						backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
						lblTitle.centerYAnchor.constraint(equalTo: centerYAnchor),
						lblTitle.centerXAnchor.constraint(equalTo: centerXAnchor)
				])
		}
		
		required init?(coder: NSCoder) {
				super.init(coder: coder)
		}
		
		func addComponent(_ superView: UIView) -> ComponentViewHeader {
				superView.addSubview(self)
				return self
		}
		
		func setupView(_ title: String) -> ComponentViewHeader{
				lblTitle.text = title
				return self
		}
		
		func setupActionClick(_ act: @escaping ()->()) -> ComponentViewHeader{
				actionClick = act
				return self
		}
		
		@objc private func actionBack(){
				actionClick()
		}
}

