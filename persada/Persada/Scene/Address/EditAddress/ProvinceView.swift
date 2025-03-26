//
//  ProvinceView.swift
//  MOVANS
//
//  Created by movan on 11/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol ProvinceViewDelegate where Self: UIViewController {
	
	func sendDataBackToParent(_ data: Data)
}

final class ProvinceView: UIView {
	
	weak var delegate: ProvinceViewDelegate?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .white
		
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
