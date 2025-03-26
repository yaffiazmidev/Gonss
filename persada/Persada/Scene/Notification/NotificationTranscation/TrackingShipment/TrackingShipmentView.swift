//
//  TrackingShipmentView.swift
//  KipasKipas
//
//  Created by movan on 18/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol TrackingShipmentViewDelegate where Self: UIViewController {
	
}

final class TrackingShipmentView: UIView {
	
	weak var delegate: TrackingShipmentViewDelegate?

	lazy var tableView: UITableView = {
		let table = UITableView(frame: .zero)
		table.translatesAutoresizingMaskIntoConstraints = false
		table.allowsMultipleSelection = false
		table.isMultipleTouchEnabled = false
		table.tableFooterView = UIView()
		table.separatorStyle = .none
		table.backgroundColor = .white
        table.rowHeight = UITableView.automaticDimension
        table.register(UINib(nibName: "TrackingItemCell", bundle: nil), forCellReuseIdentifier: String.get(.cellID))
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
		
		addSubview(tableView)
		tableView.refreshControl = refreshControl
        
        tableView.anchor(top: safeAreaLayoutGuide.topAnchor, left: safeAreaLayoutGuide.leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: safeAreaLayoutGuide.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 20, paddingRight: 20)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
