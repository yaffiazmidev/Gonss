//
//  AddressView.swift
//  KipasKipas
//
//  Created by movan on 11/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

final class AddressView: UIView {
	
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
        textfield.accessibilityIdentifier = "searchtextfield-addressview"
		return textfield
	}()
	
	lazy var tableView: UITableView = {
		let table = UITableView()
		table.register(AddressItemCell.self, forCellReuseIdentifier: ViewTrait.cellId)
		table.backgroundColor = .clear
		table.estimatedRowHeight = UITableView.automaticDimension
		table.separatorStyle = .none
        table.accessibilityIdentifier = "tableview-addressview"
		return table
	}()
	
	lazy var buttonAddAddress: UIButton = {
		let button = UIButton(title: String.get(.tambahAlamatWithPlus), titleColor: .white, font: UIFont.Roboto(.bold, size: 12))
		button.backgroundColor = .primary
		button.layer.cornerRadius = 8.0
        button.accessibilityIdentifier = "buttonadd-addressview"
        button.isHidden = true
		return button
	}()
	
	lazy var refreshControl: UIRefreshControl = {
		let refresh = UIRefreshControl()
		refresh.tintColor = .primary
		return refresh
	}()
    
	lazy var buttonSave: PrimaryButton = {
		let button = PrimaryButton(type: .system)
		button.setTitle(String.get(.simpan), for: .normal)
		button.setup(color: .primary, textColor: .white, font: .Roboto(.bold, size: 14))
        button.accessibilityIdentifier = "buttonsave-addressview"
		return button
	}()
    
    lazy var emptyView: EmptyAddressView = {
        let view = EmptyAddressView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = "emptyview-addressview"
        view.isHidden = true
        return view
    }()
    
    lazy var imageEmptyPlaceholder: UIImageView = {
        let image = UIImageView(image: UIImage(named: String.get(.iconPinPoint)))
        image.accessibilityIdentifier = "imageempty-addressview"
        image.isHidden = true
        return image
    }()
    
    lazy var labelEmptyPlaceholder: UILabel = {
        let label = UILabel(text: "", font: UIFont.Roboto(.bold, size: 14), textColor: .placeholder, textAlignment: .center, numberOfLines: 0)
        label.accessibilityIdentifier = "labelempty-addressview"
        label.isHidden = true
        return label
    }()

	
	var handlerEditAddress: (() -> Void)?
	
	var isAlreadyHaveData = true {
		didSet {
			if !isAlreadyHaveData {
				changeButtonStyleToBorder()
				hideEmptyPlaceholder()
//				searchBar.isHidden = false
                emptyView.isHidden = true
			} else {
				changeButtonStyleToSolid()
				showEmptyPlaceholder()
//				searchBar.isHidden = true
                if searchBar.text == "" {
                    emptyView.isHidden = false
                }
			}
		}
	}
    
    var topTableViewConstraint: NSLayoutConstraint? = nil
    
	
	// MARK:- Public Methods
	
	override init(frame: CGRect) {
		super.init(frame: frame)
        [searchBar, buttonAddAddress, imageEmptyPlaceholder, labelEmptyPlaceholder].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			$0.layer.masksToBounds = false
			$0.layer.cornerRadius = 8
			addSubview($0)
		}
		
		addSubview(tableView)
		tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(emptyView)
        emptyView.fillSuperview()
        
        
        imageEmptyPlaceholder.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        imageEmptyPlaceholder.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        labelEmptyPlaceholder.anchor(top: imageEmptyPlaceholder.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingLeft: 105, paddingRight: 105, width: 151, height: 100)

		
		searchBar.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: ViewTrait.padding, paddingLeft: ViewTrait.padding, paddingRight: ViewTrait.padding, height: 40)
		
		buttonAddAddress.anchor(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingLeft: ViewTrait.padding, paddingBottom: 8, paddingRight: ViewTrait.padding, height: 48)
		
		tableView.anchor(left: leftAnchor, bottom: buttonAddAddress.topAnchor, right: rightAnchor, paddingLeft: ViewTrait.padding, paddingBottom: 8, paddingRight: ViewTrait.padding)
        
        topTableViewConstraint = tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16)
        topTableViewConstraint?.isActive = true
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func changeButtonStyleToBorder(){
//		buttonAddAddress.isHidden = false
//		buttonAddAddress.layer.borderWidth = 1.0
//		buttonAddAddress.layer.borderColor = .white
		buttonAddAddress.setTitleColor(.contentGrey, for: .normal)
		buttonAddAddress.backgroundColor = .white
	}
	
	func changeButtonStyleToSolid(){
//		buttonAddAddress.isHidden = false
		buttonAddAddress.layer.borderWidth = 0
		buttonAddAddress.layer.borderColor = UIColor.orange.cgColor
		buttonAddAddress.setTitleColor(.white, for: .normal)
		buttonAddAddress.backgroundColor = .orange
	}
	
	func showEmptyPlaceholder(){
//		buttonAddAddress.isHidden = false
		imageEmptyPlaceholder.isHidden = false
		labelEmptyPlaceholder.isHidden = false
		imageEmptyPlaceholder.image = UIImage(named: String.get(.iconPinPoint))
        labelEmptyPlaceholder.text = "'\(searchBar.text ?? "")' tidak ditemukan."
	}
	
	func hideEmptyPlaceholder(){
//		buttonAddAddress.isHidden = false
		imageEmptyPlaceholder.isHidden = true
		labelEmptyPlaceholder.isHidden = true
	}
	
	
	func searchNoData(query: String){
//		buttonAddAddress.isHidden = true
//		searchBar.isHidden = false
		imageEmptyPlaceholder.isHidden = false
		labelEmptyPlaceholder.isHidden = false
		imageEmptyPlaceholder.image = UIImage(named: String.get(.iconPinPointQuestionMark))
		labelEmptyPlaceholder.text = "'\(query)' tidak ditemukan."
	}
	
	func searchHasData(){
//		buttonAddAddress.isHidden = false
		imageEmptyPlaceholder.isHidden = true
		labelEmptyPlaceholder.isHidden = true
	}
}
