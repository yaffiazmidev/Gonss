//
//  CheckoutView.swift
//  Persada
//
//  Created by movan on 22/07/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol CheckoutViewDelegate where Self: UIViewController {
	
	func changeAddress()
}

final class CheckoutView: UIView {
	
	
	let scrollView = UIScrollView()
	let contentView = UIView()
	
	lazy var itemImage : UIImageView = {
		let image = UIImageView(image: UIImage(named: String.get(.empty)))
		image.layer.cornerRadius = 8.0
		image.layer.masksToBounds = true
        image.contentMode = .scaleAspectFill
		return image
	}()
	
	lazy var itemNameLabel : UILabel = {
		let label = UILabel(text: "Tote bag", font: .Roboto(.bold, size: 12), textColor: .black, textAlignment: .left, numberOfLines: 0)
		return label
	}()
	
	lazy var itemPriceLabel : UILabel = {
		let label = UILabel(text: "Rp 123.123,00", font: .Roboto(.bold, size: 12), textColor: .primary, textAlignment: .left, numberOfLines: 0)
		return label
	}()
	
	lazy var addressTitleLabel : UILabel = {
		let label = UILabel(text: String.get(.diKirimKe), font: .Roboto(.medium, size: 12), textColor: .black, textAlignment: .left, numberOfLines: 1)
			return label
	}()
	
	lazy var addAddressButton : UILabel = {
		let label = UILabel(text: String.get(.pilihAlamatLain), font: .Roboto(.regular, size: 12), textColor: .secondary, textAlignment: .right, numberOfLines: 1)
		label.isUserInteractionEnabled = true
			return label
	}()
	
	lazy var addressLabel : UILabel = {
		let label = UILabel(text: String.get(.belumAdaAlamatTerpilih), font: .Roboto(.regular, size: 12), textColor: .placeholder, textAlignment: .left, numberOfLines: 0)
			return label
	}()
	
	lazy var notesTitleLabel : UILabel = {
		let label = UILabel(text: String.get(.catatan), font: .Roboto(.medium, size: 12), textColor: .black, textAlignment: .left, numberOfLines: 1)
			return label
	}()
	
	lazy var notesTextField : InsetTextField = {
		let textfield = InsetTextField()
		textfield.placeholderText = String.get(.notesPlaceholder)
        textfield.textColor = .black
        textfield.font = .Roboto(.regular, size: 12)
		textfield.maxLength = 30
		return textfield
	}()
	
	lazy var notesCounterLabel : UILabel = {
		let label = UILabel(text: String.get(.nolper30), font: .Roboto(.medium, size: 10), textColor: .grey, textAlignment: .right, numberOfLines: 1)
			return label
	}()
	
	lazy var courierTitleLabel : UILabel = {
		let label = UILabel(text: String.get(.chooseCourierAndDuration), font: .Roboto(.medium, size: 12), textColor: .black, textAlignment: .left, numberOfLines: 1)
			return label
	}()
	
	lazy var courierTextField : InsetTextField = {
		let textfield = InsetTextField()
		textfield.text = String.get(.pilihKurir)
        textfield.isUserInteractionEnabled = true
		let button = UIButton(type: .custom)
		let image = UIImage(named: String.get(.iconRightArrow))?.withRenderingMode(.alwaysOriginal)
		button.setImage(image, for: .normal)
		button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
		button.frame = CGRect(x: CGFloat(textfield.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
		textfield.rightView = button
		textfield.rightViewMode = .always
        textfield.isEnabled = false
        textfield.isHidden = true
		return textfield
	}()
	
	lazy var courierNotCoveredView : UIView = {
		let view = UIView()
		view.isHidden = true
		view.layer.cornerRadius = 8
		view.backgroundColor = .white
		view.layer.borderColor = UIColor.primary.cgColor
		view.layer.borderWidth = 1
		let label = UILabel(text: .get(.courierNotAvailableDesc), font: .Roboto(.regular, size: 10), textColor: .primary, textAlignment: .left, numberOfLines: 0)
		view.addSubview(label)
		label.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10)
		return view
	}()
    
    lazy var selectedCourier : SelectedCourierView = {
        let view = SelectedCourierView()
        view.selectCourierLabel.text = String.get(.pilihKurir)
        view.titleLabel.text = ""
        view.subtitleLabel.text = ""
        view.durationLabel.text = ""
        return view
    }()
	
	lazy var insuranceView : UIView = {
		let view = UIView()
		view.backgroundColor = .greenWhite
		view.layer.cornerRadius = 8.0
		view.isHidden = true
		return view
	}()
	
	lazy var insuranceIconImage : UIImageView = {
		let image = UIImageView(image: UIImage(named: String.get(.iconInsurance)))
		return image
	}()
	
	lazy var insuranceDescriptionLabel : UILabel = {
		let label = UILabel(text: String.get(.asuransi), font: .Roboto(.regular, size: 10), textColor: .grey, textAlignment: .left, numberOfLines: 0)
			return label
	}()
	
	lazy var checkBoxInsurance : UIButton = {
		let button =  UIButton()
		button.setImage(UIImage(named: String.get(.iconCheckboxUncheckGreen)), for: .normal)
		return button
	}()
	
	lazy var subtotalLabel : UILabel = {
		let label = UILabel(text: String.get(.subTotal), font: .Roboto(.medium, size: 12), textColor: .black, textAlignment: .left, numberOfLines: 0)
			return label
	}()
	
	lazy var biayaKirimLabel : UILabel = {
		let label = UILabel(text: String.get(.biayaKirim), font: .Roboto(.medium, size: 12), textColor: .black, textAlignment: .left, numberOfLines: 0)
			return label
	}()
	
	lazy var totalLabel : UILabel = {
		let label = UILabel(text: String.get(.total), font: .Roboto(.medium, size: 12), textColor: .black, textAlignment: .left, numberOfLines: 0)
			return label
	}()
	
	lazy var subtotalPriceLabel : UILabel = {
		let label = UILabel(text: "", font: .Roboto(.regular, size: 12), textColor: .black, textAlignment: .right, numberOfLines: 0)
			return label
	}()
	
	
	lazy var biayaKirimPriceLabel : UILabel = {
		let label = UILabel(text: String.get(.pilihKurirTerlebihDahulu), font: .Roboto(.regular, size: 12), textColor: .grey, textAlignment: .right, numberOfLines: 0)
			return label
	}()
	
	lazy var totalPriceLabel : UILabel = {
		let label = UILabel(text: "", font: .Roboto(.medium, size: 12), textColor: .black, textAlignment: .right, numberOfLines: 0)
			return label
	}()
	
	lazy var metodePembayaranButton: PrimaryButton = {
		let button = PrimaryButton(type: .system)
		button.setTitle(String.get(.metodePembayaran), for: .normal)
		button.setup(color: .primary, textColor: .white, font: .Roboto(.bold, size: 14))
		return button
	}()
	

	override init(frame: CGRect) {
		super.init(frame: frame)

		backgroundColor = .white
		
		scrollView.showsVerticalScrollIndicator = false
		scrollView.fillSuperview()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		contentView.translatesAutoresizingMaskIntoConstraints = false
		
		self.addSubview(scrollView)
		scrollView.addSubview(contentView)
		
        scrollView.anchor(top: safeAreaLayoutGuide.topAnchor, left: nil, bottom: scrollView.superview?.bottomAnchor, right: scrollView.superview?.rightAnchor)
		scrollView.centerXAnchor.constraint(equalTo: scrollView.superview!.centerXAnchor).isActive = true
		scrollView.widthAnchor.constraint(equalTo: scrollView.superview!.widthAnchor).isActive = true
		scrollView.heightAnchor.constraint(equalTo: scrollView.superview!.heightAnchor).isActive = true
		
		contentView.anchor(top: scrollView.topAnchor, left: nil, bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor)
		contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
		contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
		
		[metodePembayaranButton, subtotalLabel, biayaKirimLabel, totalLabel, subtotalPriceLabel, biayaKirimPriceLabel, totalPriceLabel].forEach {
			addSubview($0)
			$0.translatesAutoresizingMaskIntoConstraints = false
		}

		[insuranceIconImage, insuranceDescriptionLabel, checkBoxInsurance].forEach {
			insuranceView.addSubview($0)
			$0.translatesAutoresizingMaskIntoConstraints = false
		}
		
		[itemImage, itemNameLabel, itemPriceLabel, addressLabel, addAddressButton, addressTitleLabel, notesTextField, notesTitleLabel, notesCounterLabel, courierTitleLabel, selectedCourier, courierNotCoveredView, insuranceView].forEach {
			contentView.addSubview($0)
			$0.translatesAutoresizingMaskIntoConstraints = false
		}
		
		
        metodePembayaranButton.anchor(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingLeft: 20, paddingBottom: 20, paddingRight: 20)
		
		totalLabel.anchor(left: leftAnchor, bottom: metodePembayaranButton.topAnchor, paddingLeft: 20, paddingBottom: 20)
		biayaKirimLabel.anchor(left: leftAnchor, bottom: totalLabel.topAnchor, paddingLeft: 20, paddingBottom: 8)
		subtotalLabel.anchor(left: leftAnchor, bottom: biayaKirimLabel.topAnchor, paddingLeft: 20, paddingBottom: 8)
		
		totalPriceLabel.anchor(bottom: metodePembayaranButton.topAnchor, right: rightAnchor, paddingBottom: 20, paddingRight: 20)
		biayaKirimPriceLabel.anchor(bottom: totalPriceLabel.topAnchor, right: rightAnchor, paddingBottom: 8, paddingRight: 20)
		subtotalPriceLabel.anchor(bottom: biayaKirimPriceLabel.topAnchor, right: rightAnchor, paddingBottom: 8, paddingRight: 20)
		
		insuranceIconImage.anchor(top: insuranceView.topAnchor, left: insuranceView.leftAnchor, bottom: insuranceView.bottomAnchor, paddingTop: 25, paddingLeft: 16, paddingBottom: 25)
		
		insuranceDescriptionLabel.anchor(top: insuranceView.topAnchor, left: insuranceIconImage.leftAnchor, bottom: insuranceView.bottomAnchor, right: checkBoxInsurance.rightAnchor, paddingTop: 22, paddingLeft: 40, paddingBottom: 22, paddingRight: 44)
		
		checkBoxInsurance.anchor(top: insuranceView.topAnchor, bottom: insuranceView.bottomAnchor, right: insuranceView.rightAnchor, paddingTop:25, paddingBottom: 25, paddingRight: 16)
		
		itemImage.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, paddingTop: 20, paddingLeft: 20, width: 50, height: 50)
		itemNameLabel.anchor(top: contentView.topAnchor, left: itemImage.rightAnchor, right: contentView.rightAnchor, paddingTop: 26, paddingLeft: 18, paddingRight: 20)
		itemPriceLabel.anchor(top: itemNameLabel.bottomAnchor, left: itemImage.rightAnchor, right: contentView.rightAnchor, paddingTop: 2, paddingLeft: 18, paddingRight: 20)
		
		addressTitleLabel.anchor(top: itemImage.bottomAnchor, left: contentView.leftAnchor, paddingTop: 32, paddingLeft: 20)
		addAddressButton.anchor(top: itemImage.bottomAnchor, right: contentView.rightAnchor, paddingTop: 32, paddingRight: 20)
		addressLabel.anchor(top: addressTitleLabel.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 8, paddingLeft: 20, paddingRight: 20)
		
		notesTitleLabel.anchor(top: addressLabel.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 32, paddingLeft: 20, paddingRight: 20)
		notesTextField.anchor(top: notesTitleLabel.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 8, paddingLeft: 20, paddingRight: 20, height: 48)
		notesCounterLabel.anchor(top: notesTextField.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 4, paddingLeft: 20, paddingRight: 20)
		
		courierTitleLabel.anchor(top: notesCounterLabel.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 12, paddingLeft: 20, paddingRight: 20)
        selectedCourier.anchor(top: courierTitleLabel.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 8, paddingLeft: 20, paddingRight: 20, height: 48)
		
				courierNotCoveredView.anchor(top: courierTitleLabel.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 8, paddingLeft: 20, paddingRight: 20, height: 48)
		
		insuranceView.anchor(top: selectedCourier.bottomAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, paddingTop: 24, paddingLeft: 20, paddingBottom: 100, paddingRight: 20)
		
		checkBoxInsurance.addTarget(self, action: #selector(setCheckboxClick), for: .touchUpInside)
		notesTextField.addTarget(self, action: #selector(notesDidChange), for: .editingChanged)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc
	func setCheckboxClick(){
			if self.checkBoxInsurance.currentImage == UIImage(named: String.get(.iconCheckboxUncheckGreen)) {
			 self.checkBoxInsurance.setImage(UIImage(named: String.get(.iconCheckboxCheckedGreen)), for: .normal)
		 } else {
			 self.checkBoxInsurance.setImage(UIImage(named: String.get(.iconCheckboxUncheckGreen)), for: .normal)
		 }
	}
	
	@objc
	func notesDidChange(){
		let textCount = notesTextField.text?.count
		notesCounterLabel.text = "\(textCount ?? 0)/30"
	}
	
    func setData(product: Product, quantity : Int, shipmentPrice: Int){
        itemImage.loadImage(at: product.medias?.first?.thumbnail?.small ?? "")
		itemNameLabel.text = product.name
        let price = (product.type == "ORIGINAL" ? product.price : ((product.modal ?? 0) + (product.commission ?? 0)))
        itemPriceLabel.text = price?.toMoney()

		subtotalPriceLabel.text = "\(quantity)x \(price?.toMoney() ?? "0")"
		if let price = price {
			let total = Double(quantity) * price + Double(shipmentPrice)
			totalPriceLabel.text = total.toMoney()
		}
		
//		if let address = AddressPreference.instance.address {
//			updateAddress(address: address)
//		}
	}

	func updateAddress(address: String){
		if !(AddressPreference.instance.address?.isEmpty ?? false) {
				addressLabel.text = address
				addressLabel.textColor = .black
		}
	}
}


