//
//  DetailOfBalanceView.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 15/03/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import UIKit

protocol DetailOfBalanceViewDelegate where Self: UIViewController {
}

final class DetailOfBalanceView: UIView {
	
	weak var delegate: DetailOfBalanceViewDelegate?
	
	lazy var tableView: UITableView = {
		let table = UITableView(frame: .zero)
		table.translatesAutoresizingMaskIntoConstraints = false
		table.allowsMultipleSelection = false
		table.isMultipleTouchEnabled = false
		table.tableFooterView = UIView()
		table.backgroundColor = .white
		table.refreshControl = refreshControl
		table.registerCustomCell(DetailTransactionHeaderItemCell.self)
		table.registerCustomCell(DetailItemUsernameTableViewCell.self)
		table.registerCustomCell(AreasItemCell.self)
		table.registerCustomCell(DetailLabelTappedItemCell.self)
		table.registerCustomCell(DetailImageTappedItemCell.self)
		table.registerCustomCell(DetailTotalTableViewCell.self)
		table.registerCustomCell(DetailTransactionButtonItemCell.self)
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
		tableView.fillSuperviewSafeAreaLayoutGuide()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
