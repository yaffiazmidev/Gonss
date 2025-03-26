//
//  DetailTransactionPurchaseView.swift
//  KipasKipas
//
//  Created by movan on 13/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol DetailTransactionPurchaseViewDelegate where Self: UIViewController {
	func hideDialog()
	func showDialog()
	func whenHandleConfirmation()
}

final class DetailTransactionPurchaseViewOld: UIView {
	
	weak var delegate: DetailTransactionPurchaseViewDelegate?
	
	lazy var tableView: UITableView = {
		let table = UITableView(frame: .zero)
		table.translatesAutoresizingMaskIntoConstraints = false
		table.allowsMultipleSelection = false
		table.isMultipleTouchEnabled = false
		table.tableFooterView = UIView()
		table.backgroundColor = .white
		table.isSkeletonable = true
		table.registerCustomCell(DetailTransactionHeaderItemCell.self)
		table.registerCustomCell(DetailItemUsernameTableViewCell.self)
		table.registerCustomCell(AreasItemCell.self)
		table.registerCustomCell(DetailLabelTappedItemCell.self)
		table.registerCustomCell(DetailImageTappedItemCell.self)
		table.registerCustomCell(DetailTotalTableViewCell.self)
		table.registerCustomCell(DetailTransactionButtonItemCell.self)
		return table
	}()
	
	let viewDialogPopup: UIView = {
		let mainView = UIView()
		let titleLabel = UILabel(text: .get(.confirmMessage) , font: .AirBnbCereal(.bold, size: 14), textColor: .black, textAlignment: .left, numberOfLines: 1)
		let textLabel = UILabel(text: .get(.confirmationTransactionPurchase),
			font: .AirBnbCereal(.book, size: 14), textColor: .grey, textAlignment: .left, numberOfLines: 0)
		
		var backButton = UIButton(title: .get(.back), titleColor: .darkGray, font: .AirBnbCereal(.book, size: 14), backgroundColor: .white, target: self, action: #selector(handleBack))
		var confirmButton = UIButton(title: .get(.done), titleColor: .primary, font: .AirBnbCereal(.book, size: 14), backgroundColor: .white, target: self, action: #selector(handleConfirm))
		
		backButton.height(25).width(50)
		confirmButton.height(25).width(50)
		
		let stackButton = UIStackView(arrangedSubviews: [UIView(), backButton, confirmButton])
		stackButton.distribution = .fillProportionally
		stackButton.alignment = .trailing
		stackButton.spacing = 32
		
		mainView.addSubview(titleLabel)
		mainView.addSubview(textLabel)
		mainView.addSubview(stackButton)
		
		titleLabel.anchor(top: mainView.topAnchor, left: mainView.leftAnchor, right: mainView.rightAnchor, paddingTop: 16, paddingLeft: 16, paddingRight: 16, height: 26)
		textLabel.anchor(top: titleLabel.bottomAnchor, left: mainView.leftAnchor, right: mainView.rightAnchor, paddingTop: 16, paddingLeft: 16, paddingRight: 16, height: 120)
		stackButton.anchor(top: textLabel.bottomAnchor, left: mainView.leftAnchor, bottom: mainView.bottomAnchor, right: mainView.rightAnchor, paddingTop: 16, paddingLeft: 16, paddingBottom: 16, paddingRight: 16)
		
		mainView.backgroundColor = .white
		mainView.translatesAutoresizingMaskIntoConstraints = false
		mainView.layer.masksToBounds = false
		mainView.layer.cornerRadius = 4
		mainView.isHidden = true
		return mainView
	}()
	
	let viewPopupBackground: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .black
		view.alpha = 0.4
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGestureBack(sender:)))
		tapGesture.numberOfTapsRequired = 1
		tapGesture.isEnabled = true
		tapGesture.cancelsTouchesInView = false
		view.addGestureRecognizer(tapGesture)
		view.isHidden = true
		view.isUserInteractionEnabled = true
		return view
	}()
	
	lazy var refreshControl: UIRefreshControl = {
		let refresh = UIRefreshControl()
		refresh.tintColor = .primary
		return refresh
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .white
		isSkeletonable = true
		startSkeletonAnimation()
		[tableView, viewDialogPopup, viewPopupBackground].forEach {
			addSubview($0)
		}
		
		viewDialogPopup.centerXToSuperview()
		viewDialogPopup.centerYToSuperview()
		viewDialogPopup.width(0.76).height(0.4)
		viewPopupBackground.fillSuperviewSafeAreaLayoutGuide()
		tableView.fillSuperviewSafeAreaLayoutGuide()
		tableView.refreshControl = refreshControl
	}
	
	@objc func handleGestureBack(sender: UITapGestureRecognizer) {
		delegate?.hideDialog()
	}
	
	@objc func handleBack() {
		delegate?.hideDialog()
	}

	@objc func handleConfirm() {
		delegate?.whenHandleConfirmation()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
}
