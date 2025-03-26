//
//  AddressItemCell.swift
//  KipasKipas
//
//  Created by movan on 11/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class AddressItemCell: UITableViewCell {
	
	lazy var background : UIView = {
		let view: UIView = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.masksToBounds = false
		view.backgroundColor = .white
		view.layer.borderWidth = 1
		view.layer.cornerRadius = 5
		view.layer.borderColor = UIColor.whiteSmoke.cgColor
        view.accessibilityIdentifier = "background-AddressItemCell"
		return view
	}()
	
	lazy var alamatUtamaNotifyLabel : UILabel = {
		let label: UILabel = UILabel(text: String.get(.alamatUtama), font: .Roboto(.bold, size: 10), textColor: .primary, textAlignment: .left, numberOfLines: 1)
        label.accessibilityIdentifier = "alamatUtama-AddressItemCell"
		return label
	}()
	
	lazy var namaAlamatLabel : UILabel = {
        let label: UILabel = UILabel(text: String.get(.rumah), font: .Roboto(.bold, size: 10), textColor: .black, textAlignment: .left, numberOfLines: 1)
        label.accessibilityIdentifier = "namaAlamat-AddressItemCell"
        return label
    }()

	lazy var nameLabel : UILabel = {
		let label: UILabel = UILabel(text: String.get(.namePlaceholder), font: .Roboto(.medium, size: 10), textColor: .black, textAlignment: .left, numberOfLines: 0)
        label.accessibilityIdentifier = "nameLabel-AddressItemCell"
		return label
	}()
	
	lazy var phoneLabel : UILabel = {
		let label: UILabel = UILabel(font: .Roboto(.medium, size: 10), textColor: .black, textAlignment: .left, numberOfLines: 0)
        label.accessibilityIdentifier = "phoneLabel-AddressItemCell"
		return label
	}()
	
	lazy var alamatLabel : UILabel = {
		let label: UILabel = UILabel(font: .Roboto(.medium, size: 10), textColor: .grey, textAlignment: .left, numberOfLines: 2)
        label.accessibilityIdentifier = "alamatLabel-AddressItemCell"
		return label
	}()
	
	lazy var editButton : UIButton = {
		let button: UIButton = UIButton()
		button.titleLabel?.font = UIFont.Roboto(.medium, size: 10)
		button.setTitle(StringEnum.ubahAlamat.rawValue, for: .normal)
        button.accessibilityIdentifier = "editButton-AddressItemCell"
		button.setTitleColor(.black, for: .normal)
		return button
	}()
	
	lazy var viewSeparator : UIView = {
		let view: UIView = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.masksToBounds = false
		view.backgroundColor = .whiteSmoke
		view.layer.borderWidth = 1
		view.layer.borderColor = UIColor.whiteSmoke.cgColor
        view.accessibilityIdentifier = "viewSeperator-AddressItemCell"
		return view
	}()
	
	
	var handleEdit: (() -> Void)?
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		backgroundColor = .clear
		selectionStyle = .none

		addSubview(background)
		[alamatUtamaNotifyLabel, nameLabel, phoneLabel, alamatLabel, viewSeparator, editButton, namaAlamatLabel].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			background.addSubview($0)
		}

		alamatUtamaNotifyLabel.anchor(top: background.topAnchor, left: background.leftAnchor, right: background.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingRight: 8)
		namaAlamatLabel.anchor(top: alamatUtamaNotifyLabel.bottomAnchor, left: background.leftAnchor, right: background.rightAnchor, paddingTop: 4, paddingLeft: 8, paddingRight: 8)
		nameLabel.anchor(top: namaAlamatLabel.bottomAnchor, left: background.leftAnchor, right: background.rightAnchor, paddingTop: 12, paddingLeft: 8, paddingRight: 8)

		phoneLabel.anchor(top: nameLabel.bottomAnchor, left: background.leftAnchor, right: background.rightAnchor, paddingLeft: 8, paddingRight: 8)
		alamatLabel.anchor(top: phoneLabel.bottomAnchor, left: background.leftAnchor, right: background.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingRight: 8)
		viewSeparator.anchor(top: alamatLabel.bottomAnchor, left: background.leftAnchor, right: background.rightAnchor, paddingTop: 14, height: 1)
		editButton.anchor(top: viewSeparator.bottomAnchor, left: background.leftAnchor, bottom: background.bottomAnchor, right: background.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, height: 33)
		background.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor,
											paddingTop: 8, paddingBottom: 8, height: 160)

	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure(with value: Address) {
		
		if let name = value.senderName {
			if name.isEmpty {
				nameLabel.text = value.receiverName
			} else {
				nameLabel.text = value.senderName
			}
		}
		namaAlamatLabel.text = value.label ?? ""
        
        let showAlamatUtama = value.isDefault ?? false  && value.addressType == "BUYER_ADDRESS"
        alamatUtamaNotifyLabel.isHidden = !showAlamatUtama
		
		phoneLabel.text = value.phoneNumber
		alamatLabel.text = "\(value.detail ?? ""), \(value.subDistrict ?? "") \(value.city ?? "") \(value.postalCode ?? "")\n"
	}
	
	@objc private func handleButton() {
		self.handleEdit?()
	}
}
