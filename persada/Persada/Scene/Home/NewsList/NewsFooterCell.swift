//
//  NewsFooterCell.swift
//  KipasKipas
//
//  Created by movan on 02/12/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

final class NewsFooterCell: UICollectionReusableView {
	
	var handler: (() -> Void)?
	
	lazy var imageSearch: UIImageView = {
		let image = UIImageView()
		image.contentMode = .scaleAspectFit
		image.translatesAutoresizingMaskIntoConstraints = false
		image.isUserInteractionEnabled = true
		image.image = UIImage(named: String.get(.search))
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedImageView))
		image.addGestureRecognizer(tapGesture)
		return image
	}()
	
	lazy var imageNext: UIImageView = {
		let image = UIImageView()
		image.contentMode = .scaleAspectFit
		image.translatesAutoresizingMaskIntoConstraints = false
		image.isUserInteractionEnabled = true
		image.image = UIImage(systemName: String.get(.chevronDown))
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedImageView))
		image.addGestureRecognizer(tapGesture)
		return image
	}()
	
	let containerView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .white
		return view
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		backgroundColor = .white
		addSubview(containerView)
		containerView.fillSuperview()
		
		let stackView = hstack(imageSearch, imageNext, spacing: 1, alignment: .center, distribution: .fillEqually)
		containerView.addSubview(stackView)
		stackView.fillSuperviewSafeAreaLayoutGuide()
	}
	
	@objc func tappedImageView() {
		self.handler?()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

