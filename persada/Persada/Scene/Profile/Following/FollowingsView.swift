//
//  FollowingsView.swift
//  KipasKipas
//
//  Created by movan on 31/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol FollowingsViewDelegate where Self: UIViewController {
	
	func refresh()
}

final class FollowingsView: UIView {
	
	weak var delegate: FollowingsViewDelegate?
	
	enum ViewTrait {
		static let padding: CGFloat = 16.0
	}
	
	lazy var tableView: UITableView = {
		let table = UITableView(frame: .zero)
		table.translatesAutoresizingMaskIntoConstraints = false
		table.allowsMultipleSelection = false
		table.isMultipleTouchEnabled = false
		table.tableFooterView = UIView()
		table.rowHeight = UITableView.automaticDimension
		table.separatorStyle = .none
		table.estimatedRowHeight = 300
		table.backgroundColor = .white
		table.registerCustomCell(FollowingsItemCell.self)
		return table
	}()
	
    lazy var searchBar: UITextField = {
        var textfield = UITextField(frame: CGRect(x: 0, y: 0, width: 30, height: 40))
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.clipsToBounds = true
        textfield.textColor = .contentGrey
        textfield.placeholder = .get(.findFollowers)
        textfield.layer.borderWidth = 1
        textfield.layer.borderColor = UIColor.whiteSnow.cgColor
        textfield.layer.cornerRadius = 8
        textfield.font = UIFont.Roboto(.medium, size: 14)
        textfield.autocapitalizationType = .none
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.placeholder,
            NSAttributedString.Key.font : UIFont.Roboto(.medium, size: 14)
        ]
        textfield.backgroundColor = .whiteSnow
        textfield.attributedPlaceholder = NSAttributedString(string: .get(.findFollowers), attributes: attributes)
        textfield.leftViewMode = .always
        
        let containerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: self.frame.height))
        let imageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
        imageView.image = UIImage(systemName: "magnifyingglass")?.withTintColor(.grey, renderingMode: .alwaysOriginal)
        containerView.addSubview(imageView)
        imageView.center = containerView.center
        textfield.leftView = containerView
        
        return textfield
    }()
	
	lazy var refreshControl: UIRefreshControl = {
		let refresh = UIRefreshControl()
		refresh.tintColor = .primary
		refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
		return refresh
	}()
	
	@objc private func handleRefresh() {
		self.delegate?.refresh()
	}
	
	lazy var labelEmptyPlaceholder: UILabel = UILabel(text: .get(.dontHaveAFollowings), font: UIFont.Roboto(.bold, size: 14), textColor: .placeholder, textAlignment: .center, numberOfLines: 0)
    
    lazy var labelEmptySearchView: ProfileSearchEmptyView = ProfileSearchEmptyView()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .white
        addSubview(tableView)
        addSubview(searchBar)
        tableView.refreshControl = refreshControl
		tableView.addSubview(labelEmptyPlaceholder)
        tableView.addSubview(labelEmptySearchView)

		searchBar.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: ViewTrait.padding, paddingLeft: ViewTrait.padding, paddingRight: ViewTrait.padding, height: 40)

        tableView.anchor(top: searchBar.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: ViewTrait.padding, paddingRight: ViewTrait.padding)
        tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
		
		labelEmptyPlaceholder.centerYTo(tableView.centerYAnchor)
		labelEmptyPlaceholder.centerXTo(tableView.centerXAnchor)
        labelEmptySearchView.fillSuperview()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
