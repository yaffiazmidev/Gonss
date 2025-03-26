//
//  ComplaintView.swift
//  KipasKipas
//
//  Created by NOOR on 01/02/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import UIKit

protocol ComplaintViewDelegate where Self: UIViewController {
}

final class ComplaintView: UIView {
	
	weak var delegate: ComplaintViewDelegate?
	
	private enum ViewTrait {
		static let padding: CGFloat = 16.0
	}
	
	lazy var tableView: UITableView = {
		let table = UITableView(frame: .zero)
		table.translatesAutoresizingMaskIntoConstraints = false
		table.allowsMultipleSelection = false
		table.isMultipleTouchEnabled = false
		table.tableFooterView = UIView()
		table.rowHeight = UITableView.automaticDimension
		table.estimatedRowHeight = 300
		table.backgroundColor = .white
		table.isUserInteractionEnabled = true
		table.separatorStyle = .none
		table.registerCustomCell(ComplaintTextItemCell.self)
		table.registerCustomCell(ComplaintReasonItemCell.self)
		table.registerCustomCell(ComplaintProveVideoItemCell.self)
		table.registerCustomCell(ComplaintChoiceVideoItemCell.self)
		table.registerCustomCell(ComplaintConfirmItemCell.self)
		return table
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .white
		
		addSubview(tableView)
		tableView.fillSuperviewSafeAreaLayoutGuide()
        tableView.anchor(paddingTop: 20, paddingLeft: 20, paddingRight: 20)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

