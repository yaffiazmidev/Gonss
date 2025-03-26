//
//  HistoryOfBalanceView.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 01/03/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import UIKit

protocol HistoryOfBalanceViewDelegate where Self: UIViewController {
	func refreshUI()
	func filter()
}

final class HistoryOfBalanceView: UIView {
	
	weak var delegate: HistoryOfBalanceViewDelegate?
	
	private let widthScreen = UIScreen.main.bounds.width
	private enum ViewTrait {
		static let placeHolderSearch: String = "Cari Invoice..."
	}
	
	lazy var tableView: UITableView = {
		let table = UITableView(frame: .zero, style: .grouped)
		table.translatesAutoresizingMaskIntoConstraints = false
		table.allowsMultipleSelection = false
		table.isMultipleTouchEnabled = false
		table.refreshControl = refreshController
		table.rowHeight = UITableView.automaticDimension
		table.estimatedRowHeight = 50
		table.contentInset = UIEdgeInsets(top: -30, left: 0, bottom: 0, right: 0)
		table.separatorStyle = .none
		table.backgroundColor = .whiteSnow
		table.allowsSelection = false
		table.registerCustomCell(HistoryOfBalanceItemCell.self)
		table.showsVerticalScrollIndicator = false
		return table
	}()
	
	lazy var searchBar: UITextField = {
		var textfield = UITextField(frame: CGRect(x: 0, y: 0, width: 30, height: 40))
		textfield.clipsToBounds = true
		textfield.placeholder = ViewTrait.placeHolderSearch
		textfield.layer.borderWidth = 1
		textfield.layer.borderColor = UIColor.whiteSmoke.cgColor
		textfield.layer.cornerRadius = 8
		textfield.textColor = .grey
		let attributes = [
			NSAttributedString.Key.foregroundColor: UIColor.placeholder,
			NSAttributedString.Key.font : UIFont.Roboto(.medium, size: 12) // Note the !
		]
		textfield.backgroundColor = UIColor.white
		
		textfield.attributedPlaceholder = NSAttributedString(string: ViewTrait.placeHolderSearch, attributes: attributes)
		textfield.rightViewMode = .always
		
		textfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 16))
		textfield.leftViewMode = .always
		
		let containerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width:50, height: self.frame.height))
		let imageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
		imageView.image = UIImage(named: .get(.iconSearch))
		containerView.addSubview(imageView)
		imageView.center = containerView.center
		textfield.rightView = containerView
		return textfield
	}()
	
	lazy var refreshController: UIRefreshControl = {
		let refresh = UIRefreshControl(backgroundColor: .white)
		refresh.tintColor = .primary
		refresh.addTarget(self, action: #selector(handlePullToRefresh), for: .valueChanged)
		return refresh
	}()
	
	lazy var filterButton: UIButton = {
		let button = UIButton(title: "Filter", titleColor: .white, font: .Roboto(.regular, size: 13), backgroundColor: .secondary, target: self, action: #selector(handleFilterButton(_:)))
		button.translatesAutoresizingMaskIntoConstraints = false
		button.layer.masksToBounds = false
		button.layer.cornerRadius = 8
		return button
	}()
	
	func getHeaderView() -> UIView {
		
		let headerView = UIView(frame: CGRect(x: 0, y: 0, width: widthScreen, height: 35))
		headerView.backgroundColor = .whiteSmoke
		
		let dateLabel = UILabel(text: "Tanggal", font: .Roboto(.regular, size: 13), textColor: .black, textAlignment: .left, numberOfLines: 1)
		let transactionLabel = UILabel(text: "Transaksi", font: .Roboto(.regular, size: 13), textColor: .black, textAlignment: .left, numberOfLines: 1)
		
		let stackView = UIStackView(arrangedSubviews: [dateLabel, transactionLabel])
		stackView.axis = .horizontal
		stackView.alignment = .fill
		stackView.spacing = 4
		stackView.distribution = .fillProportionally
		headerView.addSubview(stackView)
		stackView.anchor(top: headerView.topAnchor, leading: headerView.leadingAnchor, bottom: headerView.bottomAnchor, trailing: headerView.trailingAnchor)
		
		return headerView
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .white
		
        searchBar.heightAnchor.constraint(equalToConstant: 48).isActive = true
		filterButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
		let stack = UIStackView(arrangedSubviews: [searchBar, filterButton])
		stack.axis = .horizontal
		stack.distribution = .fillEqually
		stack.spacing = 4
		
		let headerView = getHeaderView()
		addSubview(stack)
		addSubview(headerView)
		addSubview(tableView)
		
		stack.anchor(top: safeAreaLayoutGuide.topAnchor, left: safeAreaLayoutGuide.leftAnchor, right: safeAreaLayoutGuide.rightAnchor, paddingTop: 16, paddingLeft: 16, paddingRight: 16, height: 50)
		
		headerView.anchor(top: stack.safeAreaLayoutGuide.bottomAnchor, left: stack.leftAnchor, right: stack.rightAnchor, paddingTop: 24, paddingLeft: 0, paddingRight: 0, width: widthScreen, height: 40)
		
		tableView.anchor(top: headerView.safeAreaLayoutGuide.bottomAnchor, left: safeAreaLayoutGuide.leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 16, paddingRight: 16)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	@objc private func handlePullToRefresh() {
		self.delegate?.refreshUI()
	}
	
	@objc private func handleFilterButton(_ sender: UIButton) {
		self.delegate?.filter()
	}
}
