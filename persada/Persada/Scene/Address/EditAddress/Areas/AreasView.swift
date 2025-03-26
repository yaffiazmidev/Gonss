//
//  AreasView.swift
//  KipasKipas
//
//  Created by movan on 12/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol AreasViewDelegate where Self: UIViewController {
}

final class AreasView: UIView {
	
	enum ViewTrait {
		static let leftMargin: CGFloat = 10.0
		static let padding: CGFloat = 16.0
		static let cellId: String = "cellId"
		static let iconSearch: String = "iconSearch"
		static let widht = UIScreen.main.bounds.width - 24
		static let placeHolderSearch: String = "Cari Alamat.."
	}
	
	lazy var searchBar: UITextField = {
		var textfield = UITextField(frame: CGRect(x: 0, y: 0, width: 30, height: 40))
		textfield.clipsToBounds = true
		textfield.placeholder = "Cari lokasi.."
		textfield.layer.borderWidth = 1
		textfield.layer.borderColor = UIColor.whiteSmoke.cgColor
		textfield.layer.cornerRadius = 8
		textfield.textColor = .grey
		
		let attributes = [
			NSAttributedString.Key.foregroundColor: UIColor.placeholder,
			NSAttributedString.Key.font : UIFont.Roboto(.medium, size: 12)
		]
		textfield.backgroundColor = UIColor.white
		
		textfield.attributedPlaceholder = NSAttributedString(string: ViewTrait.placeHolderSearch, attributes: attributes)
		textfield.rightViewMode = .always
		
		textfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 16))
		textfield.leftViewMode = .always
		
		let containerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width:50, height: self.frame.height))
		
		let imageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
		imageView.image = UIImage(named: "iconSearch")
		containerView.addSubview(imageView)
		imageView.center = containerView.center
		textfield.rightView = containerView
		
		return textfield
	}()
	
	lazy var tableView: UITableView = {
		let table = UITableView(frame: .zero)
		table.allowsMultipleSelection = false
		table.isMultipleTouchEnabled = false
		table.tableFooterView = UIView()
        table.separatorStyle = .singleLine
		table.rowHeight = UITableView.automaticDimension
		table.estimatedRowHeight = 90
		table.backgroundColor = .white
		table.register(AreasItemCell.self, forCellReuseIdentifier: ViewTrait.cellId)
		
		return table
	}()
	
	lazy var refreshControl: UIRefreshControl = {
		let refresh = UIRefreshControl()
		refresh.tintColor = .primary
		return refresh
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .white
		
		[searchBar, tableView].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			addSubview($0)
		}
		
		searchBar.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: ViewTrait.padding, paddingLeft: ViewTrait.padding, paddingRight: ViewTrait.leftMargin, height: 40)
		
		tableView.anchor(top: searchBar.bottomAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingTop: ViewTrait.padding, paddingLeft: ViewTrait.padding, paddingBottom: 8, paddingRight: ViewTrait.padding)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
