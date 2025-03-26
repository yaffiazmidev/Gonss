//
//  NotificationSocialView.swift
//  KipasKipas
//
//  Created by movan on 13/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol NotificationSocialViewDelegate where Self: UIViewController {

}

final class NotificationSocialView: UIView {
	
	weak var delegate: NotificationSocialViewDelegate?
	
	enum ViewTrait {
		static let padding: CGFloat = 16.0
		static let cellId: String = "cellId"
	}
	
	lazy var tableView: UITableView = {
		let table = UITableView(frame: .zero)
		table.translatesAutoresizingMaskIntoConstraints = false
		table.allowsMultipleSelection = false
		table.isMultipleTouchEnabled = false
		table.tableFooterView = UIView()
		table.separatorStyle = .none
		table.rowHeight = UITableView.automaticDimension
		table.estimatedRowHeight = 140
		table.backgroundColor = .clear
		table.register(NotificationSocialItemCell.self, forCellReuseIdentifier: ViewTrait.cellId)
        table.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
		return table
	}()
	
	lazy var refreshControl: UIRefreshControl = {
		let refresh = UIRefreshControl()
		refresh.tintColor = .primary
		return refresh
	}()
   
    lazy var labelEmptyPlaceholder: UILabel = {
        let label = UILabel(text: String.get(.emptyNotifSocial), font: UIFont.Roboto(.bold, size: 14), textColor: .placeholder, textAlignment: .center, numberOfLines: 0)
        label.isHidden = true
        return label
    }()
   
    
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .white
		
		addSubview(tableView)
		tableView.fillSuperviewSafeAreaLayoutGuide(padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        
        tableView.addSubview(labelEmptyPlaceholder)
        labelEmptyPlaceholder.centerXTo(tableView.centerXAnchor)
        labelEmptyPlaceholder.centerYTo(tableView.centerYAnchor)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
