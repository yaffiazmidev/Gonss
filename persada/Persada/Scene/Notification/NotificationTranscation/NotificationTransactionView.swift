//
//  NotificationTransactionView.swift
//  KipasKipas
//
//  Created by movan on 13/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol NotificationTransactionViewDelegate where Self: UIViewController {
	
}

final class NotificationTransactionView: UIView {
	
	weak var delegate: NotificationTransactionViewDelegate?
	
	enum ViewTrait {
		static let padding: CGFloat = 16.0
		static let cellId: String = "cellId"
	}
	
	lazy var tableView: UITableView = {
		let table = UITableView()
		table.backgroundColor = .clear
		table.separatorStyle = .none
		table.register(NotificationTransactionItemCell.self, forCellReuseIdentifier: ViewTrait.cellId)
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
		tableView.fillSuperviewSafeAreaLayoutGuide(padding: UIEdgeInsets(top: 2, left: 16, bottom: 0, right: 16))
	
        tableView.addSubview(labelEmptyPlaceholder)
        labelEmptyPlaceholder.centerXTo(tableView.centerXAnchor)
        labelEmptyPlaceholder.centerYTo(tableView.centerYAnchor)
    }
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
