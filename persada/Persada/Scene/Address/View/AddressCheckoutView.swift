//
//  AddressView.swift
//  KipasKipas
//
//  Created by movan on 11/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

final class AddressCheckoutView: UIView {
	
	// MARK:- Public Property
	
	enum ViewTrait {
		static let leftMargin: CGFloat = 10.0
		static let padding: CGFloat = 16.0
		static let cellId: String = String.get(.cellID)
		static let iconSearch: String = String.get(.iconSearch)
		static let widht = UIScreen.main.bounds.width - 24
		static let placeHolderSearch: String = String.get(.cariAlamatPlaceholder)
	}
	
	lazy var searchBar: UITextField = {
		var textfield = UITextField(frame: CGRect(x: 0, y: 0, width: 30, height: 40))
		textfield.clipsToBounds = true
		textfield.textColor = .grey
		textfield.placeholder = ViewTrait.placeHolderSearch
		textfield.layer.borderWidth = 1
		textfield.layer.borderColor = UIColor.whiteSmoke.cgColor
		textfield.layer.cornerRadius = 8
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
		imageView.image = UIImage(named: ViewTrait.iconSearch)
		containerView.addSubview(imageView)
		imageView.center = containerView.center
		textfield.rightView = containerView
        textfield.isHidden = true
		
		return textfield
	}()
	
	lazy var tableView: UITableView = {
		let table = UITableView(frame: .zero, style: .grouped)
		table.register(AddressCheckoutItemCell.self, forCellReuseIdentifier: ViewTrait.cellId)
		table.backgroundColor = .clear
		table.estimatedRowHeight = UITableView.automaticDimension
		table.separatorStyle = .none
		table.contentInset = UIEdgeInsets(top: -40, left: 0, bottom: 0, right: 0)
		return table
	}()
	
	lazy var buttonAddAddress: UIButton = {
		let button = UIButton(title: String.get(.tambahAlamatWithPlus), titleColor: .white, font: UIFont.Roboto(.bold, size: 12))
		button.backgroundColor = .primary
		button.layer.cornerRadius = 8.0
        button.isHidden = true
		return button
	}()
	
	lazy var buttonAddAddressBottom: UIButton = {
		let button = UIButton(title: String.get(.tambahAlamatWithPlus), titleColor: .white, font: UIFont.Roboto(.bold, size: 12))
		button.backgroundColor = .primary
		button.layer.cornerRadius = 8.0
        button.isHidden = true
		return button
	}()
	
	lazy var refreshControl: UIRefreshControl = {
		let refresh = UIRefreshControl()
		refresh.tintColor = .primary
		return refresh
	}()
	
	
	lazy var imageEmptyPlaceholder: UIImageView = {
		let image = UIImageView(image: UIImage(named: String.get(.iconPinPoint)))
        image.isHidden = true
		return image
	}()
	
	lazy var labelEmptyPlaceholder: UILabel = {
		let label = UILabel(text: String.get(.kamuBelumMenambahkanAlamat), font: UIFont.Roboto(.bold, size: 14), textColor: .placeholder, textAlignment: .center, numberOfLines: 0)
        label.isHidden = true
		return label
	}()
	
	lazy var buttonSave: PrimaryButton = {
		let button = PrimaryButton(type: .system)
		button.setTitle(String.get(.simpan), for: .normal)
		button.setup(color: .primary, textColor: .white, font: .Roboto(.bold, size: 14))
		return button
	}()
	
	var handlerEditAddress: (() -> Void)?
	
	var isAlreadyHaveData = false {
		didSet {
			if !isAlreadyHaveData {
				changeButtonStyleToBorder()
				hideEmptyPlaceholder()
				searchBar.isHidden = false
			} else {
				changeButtonStyleToSolid()
				showEmptyPlaceholder()
				searchBar.isHidden = true
			}
		}
	}
	
	// MARK:- Public Methods
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		[searchBar, imageEmptyPlaceholder, labelEmptyPlaceholder, buttonSave, buttonAddAddressBottom].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			$0.layer.masksToBounds = false
			$0.layer.cornerRadius = 8
			addSubview($0)
		}
		
		addSubview(tableView)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(buttonAddAddress)
		buttonAddAddress.layer.masksToBounds = false
		buttonAddAddress.layer.cornerRadius = 8
		
		imageEmptyPlaceholder.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		imageEmptyPlaceholder.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		
		labelEmptyPlaceholder.anchor(top: imageEmptyPlaceholder.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingLeft: 105, paddingRight: 105, width: 151, height: 100)
		
		
		searchBar.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: ViewTrait.padding, paddingLeft: ViewTrait.padding, paddingRight: ViewTrait.padding, height: 40)
		
		buttonSave.anchor(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingLeft: ViewTrait.padding, paddingBottom: 8, paddingRight: ViewTrait.padding, height: 48)
		
		buttonAddAddressBottom.anchor(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingLeft: ViewTrait.padding, paddingBottom: 8, paddingRight: ViewTrait.padding, height: 48)
		
		tableView.anchor(top: searchBar.bottomAnchor, left: leftAnchor, bottom: buttonSave.topAnchor, right: rightAnchor, paddingTop: 24, paddingLeft: ViewTrait.padding, paddingBottom: 8, paddingRight: ViewTrait.padding)
		
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func changeButtonStyleToBorder(){
		buttonAddAddress.isHidden = false
		buttonAddAddress.layer.borderWidth = 1.0
		buttonAddAddress.layer.borderColor = UIColor.primary.cgColor
		buttonAddAddress.setTitleColor(.primary, for: .normal)
		buttonAddAddress.backgroundColor = .white
	}
	
	func changeButtonStyleToSolid(){
		buttonAddAddress.isHidden = false
		buttonAddAddress.layer.borderWidth = 0
		buttonAddAddress.layer.borderColor = UIColor.orange.cgColor
		buttonAddAddress.setTitleColor(.white, for: .normal)
		buttonAddAddress.backgroundColor = .orange
	}
	
	func showEmptyPlaceholder(){
		buttonAddAddress.isHidden = true
		buttonAddAddressBottom.isHidden = false
		buttonSave.isHidden = true
		imageEmptyPlaceholder.isHidden = false
		labelEmptyPlaceholder.isHidden = false
		imageEmptyPlaceholder.image = UIImage(named: String.get(.iconPinPoint))
	}
	
	func hideEmptyPlaceholder(){
		buttonAddAddress.isHidden = false
		buttonAddAddressBottom.isHidden = true
		buttonSave.isHidden = false
		imageEmptyPlaceholder.isHidden = true
		labelEmptyPlaceholder.isHidden = true
	}
	
	
	func searchNoData(query: String){
		buttonAddAddress.isHidden = true
		searchBar.isHidden = false
		imageEmptyPlaceholder.isHidden = false
		labelEmptyPlaceholder.isHidden = false
		imageEmptyPlaceholder.image = UIImage(named: String.get(.iconPinPointQuestionMark))
		labelEmptyPlaceholder.text = "'\(query)' tidak ditemukan."
	}
	
	func searchHasData(){
		buttonAddAddress.isHidden = false
		imageEmptyPlaceholder.isHidden = true
		labelEmptyPlaceholder.isHidden = true
	}
}
