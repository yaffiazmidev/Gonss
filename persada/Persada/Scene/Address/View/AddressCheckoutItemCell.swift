//
//  AddressItemCell.swift
//  KipasKipas
//
//  Created by movan on 11/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class AddressCheckoutItemCell: UITableViewCell {
	
	lazy var background : UIView = {
		let view: UIView = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.masksToBounds = false
		view.backgroundColor = .white
		view.layer.borderWidth = 1
		view.layer.cornerRadius = 5
		view.layer.borderColor = UIColor.whiteSmoke.cgColor
		return view
	}()
	
	lazy var alamatUtamaNotifyLabel : UILabel = {
		let label: UILabel = UILabel(text: String.get(.alamatUtama), font: .Roboto(.medium, size: 12), textColor: .primary, textAlignment: .left, numberOfLines: 0)
		return label
	}()
	
	lazy var nameLabel : UILabel = {
		let label: UILabel = UILabel(text: String.get(.alamatUtama), font: .Roboto(.medium, size: 12), textColor: .black, textAlignment: .left, numberOfLines: 0)
		return label
	}()
	
	lazy var phoneLabel : UILabel = {
		let label: UILabel = UILabel(font: .Roboto(.medium, size: 12), textColor: .black, textAlignment: .left, numberOfLines: 0)
		return label
	}()
	
	lazy var alamatLabel : UILabel = {
		let label: UILabel = UILabel(font: .Roboto(.regular, size: 10), textColor: .grey, textAlignment: .left, numberOfLines: 0)
		return label
	}()
	
	lazy var editButton : UIButton = {
		let button: UIButton = UIButton()
		button.titleLabel?.font = UIFont.Roboto(.regular, size: 10)
		button.setTitle(StringEnum.ubahAlamat.rawValue, for: .normal)
		button.setTitleColor(.black, for: .normal)
		button.isUserInteractionEnabled = true
		return button
	}()
	
	lazy var viewSeparator : UIView = {
		let view: UIView = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.masksToBounds = false
		view.backgroundColor = .whiteSmoke
		view.layer.borderWidth = 1
		view.layer.borderColor = UIColor.whiteSmoke.cgColor
		return view
	}()
	
	lazy var radioButton : UIButton = {
		let button = UIButton()
		button.setImage(UIImage(named: String.get(.iconRadioButtonChecked)), for: .normal)
		return button
	}()
	
	var address : Address?
	var handleEdit: (() -> Void)?
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		backgroundColor = .clear
		selectionStyle = .none
		contentView.isUserInteractionEnabled = false
		
		addSubview(background)
		[alamatUtamaNotifyLabel, nameLabel, phoneLabel, alamatLabel, viewSeparator, editButton, radioButton].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			background.addSubview($0)
		}
		
		alamatUtamaNotifyLabel.anchor(left: background.leftAnchor, right: background.rightAnchor, paddingLeft: 12, paddingRight: 8)
		nameLabel.anchor(top: alamatUtamaNotifyLabel.bottomAnchor, left: background.leftAnchor, right: radioButton.leftAnchor, paddingTop: 8, paddingLeft: 12, paddingRight: 8)
        phoneLabel.anchor(top: nameLabel.bottomAnchor, left: background.leftAnchor, right: radioButton.leftAnchor, paddingTop: 4, paddingLeft: 12, paddingRight: 8)
		alamatLabel.anchor(top: phoneLabel.bottomAnchor, left: background.leftAnchor, right: radioButton.leftAnchor, paddingTop: 8, paddingLeft: 12, paddingRight: 8)
		viewSeparator.anchor(top: alamatLabel.bottomAnchor, left: background.leftAnchor, right: background.rightAnchor, paddingTop: 14, height: 1)
		editButton.anchor(top: viewSeparator.bottomAnchor, left: background.leftAnchor, bottom: background.bottomAnchor, right: background.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, height: 33)
        
		background.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor,
											paddingTop: 8, paddingBottom: 8, height: 150)
		radioButton.anchor(top: nameLabel.topAnchor, bottom: viewSeparator.topAnchor, right: background.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 16, width: 13)
		
		
		editButton.addTarget(self, action: #selector(editButtonHandler), for: .touchUpInside)
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		if selected {
			self.radioButton.setImage(UIImage(named: String.get(.iconRadioButtonChecked)), for: .normal)
			AddressPreference.instance.address = alamatLabel.text
			AddressPreference.instance.selectedAddressID = address?.id
		} else {
			self.radioButton.setImage(UIImage(named: String.get(.iconRadioButtonUncheck)), for: .normal)
		}
	}
	
	@objc
	func editButtonHandler(){
		self.handleEdit?()
	}
	
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure(with value: Address) {
		address = value
		
		if let name = value.senderName {
			if name.isEmpty {
				nameLabel.text = value.receiverName
			} else {
				nameLabel.text = value.senderName
			}
		}

		
		if value.isDefault ?? false {
			alamatUtamaNotifyLabel.isHidden = false
		} else {
			alamatUtamaNotifyLabel.isHidden = true
		}
		
		phoneLabel.text = value.phoneNumber
		alamatLabel.text = "\(value.detail ?? ""), \(value.subDistrict ?? "") \(value.city ?? "") \(value.postalCode ?? "")"
	}
}
