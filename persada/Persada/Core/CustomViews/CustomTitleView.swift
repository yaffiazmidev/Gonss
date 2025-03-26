//
//  CustomTitleView.swift
//  Persada
//
//  Created by NOOR on 29/06/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class CustomTitleView: UIView {
	
	private let logoImageView = UIImageView(image: UIImage(named: "KipasKipas"), contentMode: .scaleAspectFit)
	private lazy var chatButton = UIButton(image: UIImage(named: "iconChat")!, tintColor: .gray)
	private lazy var shopButton = UIButton(image: UIImage(named: "iconLocalMall")!, tintColor: .gray)
	
	override var intrinsicContentSize: CGSize {
		return UIView.layoutFittingExpandedSize
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		[shopButton, chatButton].forEach { (button) in
			button.clipsToBounds = true
			button.backgroundColor = .clear
			button.withSize(.init(width: 34, height: 34))
		}

		backgroundColor = .white
		self.frame = CGRect(x: 0, y: 0, width: frame.width, height: 50)
		let lessWidth: CGFloat = 34 + 34 + 120 + 24 + 34
		let width = (frame.width - lessWidth)
		self.hstack(logoImageView.withWidth(120), UIView().withWidth(width), shopButton, chatButton, spacing: 8).padBottom(8)
		
		//		titleView.addSubview(progressBar)
		//		progressBar.anchor(top: nil, left: titleView.leftAnchor, bottom: titleView.bottomAnchor, right: titleView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 3)
//		navigationItem.titleView = titleView
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
