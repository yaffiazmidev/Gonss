//
//  ProfileMenuView.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 10/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.

import UIKit

protocol ProfileMenuViewDelegate where Self: UIViewController {

	func sendDataBackToParent(_ data: Data)
}


final class ProfileMenuView: UIView {

	weak var delegate: ProfileMenuViewDelegate?

	private enum ViewTrait {
		static let leftMargin: CGFloat = 10.0
		static let padding: CGFloat = 16.0
		static let iconSearch: String = "iconSearch"
		static let placeHolderSearch: String = "Cari Pengaturan.."
	}

    let versionLabel: UILabel = {
        let label = UILabel(font: .Roboto(.medium, size: 14), textColor: .placeholder, numberOfLines: 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

	var table = UITableView()
	
	convenience init() {
			self.init(frame: UIScreen.main.bounds)
			initView()
	}

	func initView() {
		backgroundColor = .white
		table.backgroundColor = .white

		addSubview(table)
        addSubview(versionLabel)

		table.anchor(top: safeAreaLayoutGuide.topAnchor, left: safeAreaLayoutGuide.leftAnchor, right: safeAreaLayoutGuide.rightAnchor, paddingTop: 8)
        
        versionLabel.anchor(top: table.bottomAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingLeft: 16, paddingBottom: hasTopNotch ? 0 : 16, paddingRight: 16, height: 16)

	}
    
    private var hasTopNotch: Bool {
        if #available(iOS 11.0, tvOS 11.0, *) {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
        return false
    }
}
