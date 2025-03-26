//
//  DetailTransactionSalesCancelView.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 10/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//


import UIKit

protocol DetailTransactionSalesCancelViewDelegate where Self: UIViewController {
	func hideDialog()
	func showDialog()
}

final class DetailTransactionSalesCancelView: UIView {
	
	weak var delegate: DetailTransactionSalesCancelViewDelegate?
	
	lazy var tableView: UITableView = {
		let table = UITableView(frame: .zero)
		table.translatesAutoresizingMaskIntoConstraints = false
		table.allowsMultipleSelection = false
		table.isMultipleTouchEnabled = false
		table.tableFooterView = UIView()
		table.backgroundColor = .white
		table.registerCustomCell(DetailTransactionHeaderItemCell.self)
		table.registerCustomCell(AreasItemCell.self)
		return table
	}()
	
	lazy var priceTermsView: UIView = {
		let view = UIView(frame: .zero)
		
		title.translatesAutoresizingMaskIntoConstraints = false
		subtitle.translatesAutoresizingMaskIntoConstraints = false
		
		[title, subtitle].forEach {
			view.addSubview($0)
		}
		
		subtitle.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingLeft: 20, paddingBottom: 16, paddingRight: 20, height: 20)
		title.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: subtitle.topAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 20, paddingBottom: 8, paddingRight: 20)
		
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .secondaryLowTint
		return view
	}()
	
	let title = UILabel(font: .Roboto(.regular, size: 14), textColor: .grey, textAlignment: .left, numberOfLines: 0)
	let subtitle = UILabel(font: .Roboto(.regular, size: 14), textColor: .secondary, textAlignment: .left, numberOfLines: 1)
	
	var priceTermsAnchorHeight: NSLayoutConstraint?
	var tableViewTopAnchor: NSLayoutConstraint?
	
	var awbNumberLabel = UILabel(font: .Roboto(.bold, size: 14), textColor: .black, textAlignment: .center, numberOfLines: 2)
	
	var barcodeImageView: UIImageView = {
		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isUserInteractionEnabled = true
		view.image = UIImage(named: .get(.LoginBG))
		return view
	}()
	
	lazy var backButton: UIButton = {
		let button = UIButton(image: UIImage(named: .get(.iconClose))! , tintColor: .secondary, target: self, action: #selector(handleBack(_:)))
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	var barcodeView: UIView = {
		let view = UIView()
		view.backgroundColor = .white
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.masksToBounds = false
		view.layer.cornerRadius = 4
		view.isHidden = true
		return view
	}()
	
	var viewBackground: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .black
		view.alpha = 0.4
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGestureBack(sender:)))
		tapGesture.numberOfTapsRequired = 1
		tapGesture.isEnabled = true
		view.addGestureRecognizer(tapGesture)
		view.isUserInteractionEnabled = true
		view.isHidden = true
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
		
		addSubview(priceTermsView)
		addSubview(tableView)
		addSubview(viewBackground)
		addSubview(barcodeView)
		
		let tableHeaderHeight = CGFloat(40)
		let tableWidth = self.tableView.bounds.size.width
		let tableFrame = CGRect(x: 0, y: 0, width: tableWidth , height: tableHeaderHeight)
		tableView.tableHeaderView = UIView(frame: tableFrame)// set the content insets top value
		tableView.contentInset = UIEdgeInsets(top: -tableHeaderHeight, left: 0, bottom: 0, right: 0)
		tableView.separatorStyle = .none
		
		setupBarcodeView()
		
		priceTermsView.anchor(top: safeAreaLayoutGuide.topAnchor, left: safeAreaLayoutGuide.leftAnchor, right: safeAreaLayoutGuide.rightAnchor)
		
		tableView.anchor(left: safeAreaLayoutGuide.leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: safeAreaLayoutGuide.rightAnchor)
		tableView.refreshControl = refreshControl
	}
	
	private func setupBarcodeView() {
		barcodeView.centerXTo(centerXAnchor)
		barcodeView.centerYTo(centerYAnchor)
		let widthScreen = UIScreen.main.bounds.width
		barcodeView.anchor(width: widthScreen - 40, height: widthScreen)
		viewBackground.fillSuperviewSafeAreaLayoutGuide()
		
		barcodeView.addSubview(barcodeImageView)
		barcodeView.addSubview(backButton)
		barcodeView.addSubview(awbNumberLabel)
		
		backButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
		
		backButton.anchor(top: barcodeView.topAnchor, right: barcodeView.rightAnchor, paddingTop: 16, paddingRight: 16, width: 30, height: 30)
		awbNumberLabel.anchor(left: barcodeView.leftAnchor, bottom: barcodeView.bottomAnchor, right: barcodeView.rightAnchor, paddingLeft: 16, paddingBottom: 16, paddingRight: 16, height: 26)
		barcodeImageView.anchor(top: backButton.bottomAnchor, left: barcodeView.leftAnchor, bottom: awbNumberLabel.topAnchor, right: barcodeView.rightAnchor, paddingTop: 8, paddingLeft: 16, paddingBottom: 8, paddingRight: 16)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	func showHiddenPriceTerms(isHidden: Bool, _ title: String = "", _ subtitle: String = "") {
		if !isHidden {
			
			self.priceTermsAnchorHeight = priceTermsView.heightAnchor.constraint(equalToConstant: 0)
			self.priceTermsAnchorHeight?.isActive = false
			self.priceTermsView.isHidden = true
			self.title.text = title
			self.subtitle.text = subtitle
			
			self.tableViewTopAnchor = tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8)
			self.tableViewTopAnchor?.isActive = true
		} else {
			self.priceTermsAnchorHeight = priceTermsView.heightAnchor.constraint(equalToConstant: 104)
			self.priceTermsAnchorHeight?.isActive = true
			self.priceTermsView.isHidden = false
			self.title.text = title
			self.subtitle.text = subtitle
			
			self.tableViewTopAnchor = tableView.topAnchor.constraint(equalTo: priceTermsView.bottomAnchor, constant: 8)
			self.tableViewTopAnchor?.isActive = true
		}
	}
	
	func setup(_ imageData: Data, _ awbNumber: String) {
		barcodeImageView.image = UIImage(data: imageData)
		awbNumberLabel.text = awbNumber
	}
	
	@objc func handleShowBarcode(_ sender: UIButton) {
		self.delegate?.hideDialog()
	}
	
	@objc func handleGestureBack(sender: UITapGestureRecognizer) {
		self.delegate?.hideDialog()
	}
	
	@objc func handleBack(_ sender: UIButton) {
		self.delegate?.hideDialog()
	}
}



