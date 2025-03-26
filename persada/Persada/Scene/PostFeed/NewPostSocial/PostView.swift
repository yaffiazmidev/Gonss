//
//  PostView.swift
//  Persada
//
//  Created by NOOR on 30/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.

import Foundation
import UIKit
import AVKit

protocol DisplayListable where Self: UIViewController {

	associatedtype DataSource: DataSourceable

	init(dataSource: DataSource)
}

protocol PostViewDelegate where Self: UIViewController {
	
	func changeType(type: String)
	func whenChannelClicked()
    func whenTagProductClicked()
}

final class PostView: UIView {

    var onSwitchAsProductChange: (Bool) -> () = {_ in }
    
	private enum SwitchType : Int {
		case switchPost = 0
		case switchShipping = 1
	}
	
	weak var delegate: PostViewDelegate?
	
	private var isCreateFeed = false

	init(isCreateFeed: Bool) {
		self.isCreateFeed = isCreateFeed
		super.init(frame: .zero)
		draw(.zero)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	let scrollView: UIScrollView = {
		let scrollView = UIScrollView()

		scrollView.translatesAutoresizingMaskIntoConstraints = false
		return scrollView
	}()

	let scrollViewContainer: UIStackView = {
		let view = UIStackView()

		view.axis = .vertical
		view.spacing = 20
        view.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
		view.isLayoutMarginsRelativeArrangement = true
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	lazy var collectionView: UICollectionView = {
		let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.backgroundColor = .white
		collectionView.registerCustomCell(PostItemCell.self)
		collectionView.isScrollEnabled = false
		collectionView.isUserInteractionEnabled = true
		collectionView.heightAnchor.constraint(equalToConstant: 80).isActive = true
		return collectionView
	}()
    
    lazy var labelNameProduct: UILabel = {
        let label: UILabel = UILabel(text: "Nama Produk", font: .Roboto(.medium, size: 12), textColor: .grey, textAlignment: .left, numberOfLines: 0)
        return label
    }()
    
    lazy var labelPriceProduct: UILabel = {
        let label: UILabel = UILabel(text: "Harga", font: .Roboto(.medium, size: 12), textColor: .grey, textAlignment: .left, numberOfLines: 0)
        return label
    }()
    
    lazy var labelStockProduct: UILabel = {
        let label: UILabel = UILabel(text: "Stok Tersedia", font: .Roboto(.medium, size: 12), textColor: .grey, textAlignment: .left, numberOfLines: 0)
        return label
    }()
    
    lazy var labelLengthCaption: UILabel = {
        let label: UILabel = UILabel(text: "0/1000", font: .Roboto(.medium, size: 12), textColor: .grey, textAlignment: .right, numberOfLines: 0)
        return label
    }()
    
    lazy var labelLengthProductName: UILabel = {
        let label: UILabel = UILabel(text: "0/70", font: .Roboto(.medium, size: 12), textColor: .grey, textAlignment: .right, numberOfLines: 0)
        return label
    }()
    
	lazy var captionCTV: CustomTextView = {
		let ctv = CustomTextView(backgroundColor: .white)
		ctv.nameTextField.backgroundColor = .white
		ctv.nameTextField.layer.cornerRadius = 8
		ctv.nameTextField.layer.borderColor = UIColor.whiteSmoke.cgColor
		ctv.nameTextField.layer.borderWidth = 1
		ctv.nameTextField.font = .Roboto(.regular, size: 12)
		ctv.nameTextField.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 0, right: 0)
		ctv.draw(.zero)
        ctv.placeholderFloating = .get(.writeCaption)
        ctv.maxLength = 1000
		ctv.heightAnchor.constraint(equalToConstant: 120).isActive = true
		return ctv
	}()
    
    lazy var captionContainer : UIView  = {
       let view = UIView()
        view.addSubview(captionCTV)
        view.addSubview(labelLengthCaption)
        captionCTV.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor)
        labelLengthCaption.anchor(top: captionCTV.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 6, paddingRight: 12)
        return view
    }()
    
    lazy var productNameContainer : UIView  = {
        let view = UIView()
        view.addSubview(labelNameProduct)
        view.addSubview(nameItemView)
        view.addSubview(labelLengthProductName)
        labelNameProduct.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor)
        nameItemView.anchor(top: labelNameProduct.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 6)
        labelLengthProductName.anchor(top: nameItemView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 6, paddingRight: 12)
        view.anchor(height: 72)
        return view
    }()

	lazy var channelButtonSelectView: CustomSelectView = {
		let csb = CustomSelectView(name: "Channel", rightImage: UIImage(named: .get(.iconNavigateNext)))
		csb.isUserInteractionEnabled = true
		csb.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleChannelButton)))
		return csb
	}()

	lazy var postProductCSWL: CustomSwitchWithLabel = {
		let cswl = CustomSwitchWithLabel(label: "Post sebagai product", sizeScale: 0.75, isChecked: false, id: SwitchType.switchPost.rawValue)
		cswl.delegate = self
		return cswl
	}()

	lazy var nameItemView: CustomIndentedTextField = {
		let label = self.isCreateFeed ? "" : "Nama Barang"
		let placeholder = self.isCreateFeed ? "Nama Produk" : "Masukan nama barang"
        let textField = CustomIndentedTextField(placeholder: placeholder, padding: 16, cornerRadius: 8, keyboardType: .default, backgroundColor: .white, isSecureTextEntry: false, borderWidth: 1, borderColor: .whiteSmoke, prefix: nil)
        textField.textColor = .black
        textField.anchor(height: 46)
        textField.maxLength = 70
		return textField
	}()

    lazy var priceItemView: CustomIndentedTextField = {
        let label = self.isCreateFeed ? "" : "Harga Barang (Rp)"
        let placeholder = self.isCreateFeed ? "Harga (Rp)" : ""
        let currency = "Rp "
        let textField = CustomIndentedTextField(placeholder: placeholder, padding: 16, cornerRadius: 8, keyboardType: .numberPad, backgroundColor: .white, isSecureTextEntry: false, borderWidth: 1, borderColor: .whiteSmoke, prefix: nil, isNumberOnly: true)
        
        textField.onEndEditing = { string in
            textField.text = string.digits() == "0" ? "" : string.digits().toMoney()
        }
        
        textField.textColor = .black
        textField.anchor(height: 46)
        return textField
    }()
    
    lazy var productPriceContainer : UIView  = {
        let view = UIView()
        view.addSubview(labelPriceProduct)
        view.addSubview(priceItemView)
        labelPriceProduct.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor)
        priceItemView.anchor(top: labelPriceProduct.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 6)
        view.anchor(height: 66)
        return view
    }()
    
    lazy var stockItemView: CustomIndentedTextField = {
        let label = self.isCreateFeed ? "" : "Stok Tersedia"
        let placeholder = self.isCreateFeed ? "Stok Tesedia" : ""
        let textField = CustomIndentedTextField(placeholder: placeholder, padding: 16, cornerRadius: 8, keyboardType: .numberPad, backgroundColor: .white, isSecureTextEntry: false, borderWidth: 1, borderColor: .whiteSmoke, prefix: nil, isNumberOnly: true)
        
        let font = UIFont(name: "AirbnbCerealApp-Book", size: 12)
        let suffix = UILabel(text: "pcs", font: font, textColor: .lightGray, textAlignment: .center)
        
        textField.rightViewMode = .always
        textField.rightView = suffix
        textField.textColor = .black
        textField.anchor(height: 46)
        textField.rightView?.widthAnchor.constraint(equalToConstant: 50).isActive = true
        return textField
    }()
    
    lazy var productStockContainer : UIView  = {
        let view = UIView()
        view.addSubview(labelStockProduct)
        view.addSubview(stockItemView)
        labelStockProduct.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor)
        stockItemView.anchor(top: labelStockProduct.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 6)
        view.anchor(height: 66)
        return view
    }()
	
	lazy var shippingLabelView: UIView = {
		let title: UILabel = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textColor = .black
        title.text = "Shipping"
        title.font = .Roboto(.medium, size: 12)
        
        let info: UILabel = UILabel()
        info.translatesAutoresizingMaskIntoConstraints = false
        info.textColor = .black
        info.text = "Minimum ukuran produk 1cm untuk setiap sisi"
        info.font = .Roboto(size: 11)
        
        let infoIcon: UIImageView = UIImageView()
        infoIcon.translatesAutoresizingMaskIntoConstraints = false
        infoIcon.contentMode = .scaleAspectFit
        infoIcon.image = UIImage(named: "icon_warning")?.withRenderingMode(.alwaysOriginal).withTintColor(UIColor(hexString: "FFA360"))
		
		let view: UIView = UIView()
		view.addSubview(title)
        view.addSubview(info)
        view.addSubview(infoIcon)
        
        title.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        infoIcon.anchor(top: title.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 6, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 12, height: 12)
        info.anchor(top: title.bottomAnchor, left: infoIcon.rightAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 6, paddingLeft: 4, paddingBottom: 0, paddingRight: 16)
		return view
	}()


	lazy var descriptionProductCTV: CustomTextView = {
		let ctv = CustomTextView(backgroundColor: .white)
		ctv.placeholderFloating = "Isi deskripsi barangmu"
		ctv.title = "Deskripsi Barang"
		ctv.nameLabel.textColor = .black
		ctv.nameTextField.backgroundColor = .whiteSnow
		ctv.nameTextField.font = .Roboto(.medium, size: 12)
		ctv.nameTextField.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 0, right: 0)
		ctv.draw(.zero)
		ctv.heightAnchor.constraint(equalToConstant: 120).isActive = true
		return ctv
	}()

	lazy var shippingCSWL: CustomSwitchWithLabel = {
		let cswl = CustomSwitchWithLabel(label: "Include Shipping", sizeScale: 0.75, isChecked: false, id: SwitchType.switchShipping.rawValue)
		cswl.delegate = self
		return cswl
	}()

    var lengthTextInput: CustomIndentedTextField = {
        let textField = CustomIndentedTextField(placeholder: "Panjang cm", padding: 16, cornerRadius: 8, keyboardType: .decimalPad, backgroundColor: .white, isSecureTextEntry: false, borderWidth: 1, borderColor: .whiteSmoke, prefix: nil)
        
        textField.onBeginEditing = { string in
            if string.suffix(3) == " cm" {
                textField.text = String(string.dropLast(3))
            }
        }
        textField.onEndEditing = { string in
            textField.text = string == "" ? "": "\(string) cm"
        }
        textField.textColor = .black
        textField.maxLength = 3
        return textField
    }()
    
    var widthTextInput: CustomIndentedTextField = {
        let textField = CustomIndentedTextField(placeholder: "Lebar cm", padding: 16, cornerRadius: 8, keyboardType: .decimalPad, backgroundColor: .white, isSecureTextEntry: false, borderWidth: 1, borderColor: .whiteSmoke, prefix: nil)
        
        textField.onBeginEditing = { string in
            if string.suffix(3) == " cm" {
                textField.text = String(string.dropLast(3))
            }
        }
        textField.onEndEditing = { string in
            textField.text = string == "" ? "": "\(string) cm"
        }
        textField.textColor = .black
        textField.maxLength = 3
        return textField
    }()
    
    var heightTextInput: CustomIndentedTextField = {
        let textField = CustomIndentedTextField(placeholder: "Tinggi cm", padding: 16, cornerRadius: 8, keyboardType: .decimalPad, backgroundColor: .white, isSecureTextEntry: false, borderWidth: 1, borderColor: .whiteSmoke, prefix: nil)
        
        textField.onBeginEditing = { string in
            if string.suffix(3) == " cm" {
                textField.text = String(string.dropLast(3))
            }
        }
        textField.onEndEditing = { string in
            textField.text = string == "" ? "": "\(string) cm"
        }
        textField.textColor = .black
        textField.maxLength = 3
        return textField
    }()
    
    var weightTextInput: CustomIndentedTextField = {
        let textField = CustomIndentedTextField(placeholder: "Berat kg", padding: 16, cornerRadius: 8, keyboardType: .decimalPad, backgroundColor: .white, isSecureTextEntry: false, borderWidth: 1, borderColor: .whiteSmoke, prefix: nil)
        
        textField.onBeginEditing = { string in
            if string.suffix(3) == " kg" {
                textField.text = String(string.dropLast(3))
            }
        }
        
        textField.onEndEditing = { string in
            let weight = Measurement(value: Double(string) ?? 0.0, unit: UnitMass.kilograms)
            textField.text = weight.description
        }
        
        textField.textColor = .black
        textField.anchor(width: 200, height: 46)
        textField.maxLength = 4
        return textField
    }()

    let labelWeightError = UILabel(text: "", font: .Roboto(.regular, size: 12), textColor: .redError, textAlignment: .left, numberOfLines: 1)
    
    lazy var weightStackView: UIStackView = {
        let weightTextInputStackView = UIStackView(arrangedSubviews: [weightTextInput])
        weightTextInputStackView.axis = .vertical
        weightTextInputStackView.alignment = .leading
        weightTextInputStackView.isLayoutMarginsRelativeArrangement = true
        
        let view = UIStackView(arrangedSubviews: [weightInfo, weightTextInputStackView, labelWeightError])
        view.axis = .vertical
        view.alignment = .fill
        view.spacing = 10
        view.distribution = .fillProportionally
        view.isLayoutMarginsRelativeArrangement = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var weightInfo: UIStackView = {
        let infoIcon: UIImageView = UIImageView()
        infoIcon.contentMode = .scaleAspectFit
        infoIcon.image = UIImage(named: "icon_warning")?.withRenderingMode(.alwaysOriginal).withTintColor(UIColor(hexString: "FFA360"))
        infoIcon.anchor(width: 12, height: 12)
        
        let weightInfoText = "Min 0.1 Kg - Max 50 Kg"
        let weightInfoLabel = UILabel(font: .Roboto(.medium, size: 11), textAlignment: .left, numberOfLines: 1)
        let textRange = NSRange(location: 0, length: weightInfoText.count)
        let attributedText = NSMutableAttributedString(string: weightInfoText)
        attributedText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: textRange)
        weightInfoLabel.attributedText = attributedText
        
        let weightInfo = UIStackView(arrangedSubviews: [infoIcon, weightInfoLabel])
        weightInfo.axis = .horizontal
        weightInfo.alignment = .fill
        weightInfo.spacing = 4
        weightInfo.distribution = .fillProportionally
        weightInfo.isHidden = true
        weightInfo.onTap { [weak self] in
            self?.vwPopBerat.showView()
        }
        return weightInfo
    }()
    
    
    
	lazy var shippingView: UIStackView = {
		let view = UIStackView(arrangedSubviews: [self.lengthTextInput, self.widthTextInput, self.heightTextInput])
		view.axis = .horizontal
		view.spacing = 12
		view.distribution = .fillEqually
        view.anchor(height: 46)
		return view
	}()

    let productSelectedView = Bundle.main.loadNibNamed("ProductSelectedView", owner: self, options: nil)?[0] as! ProductSelectedView
    let channelSelectedView = Bundle.main.loadNibNamed("ChannelSelectedView", owner: self, options: nil)?[0] as! ChannelSelectedView

    
    lazy var productButtonSelectView: CustomSelectView = {
        let csb = CustomSelectView(name: "Tag Produk", rightImage: UIImage(named: .get(.iconNavigateNext)))
        csb.isUserInteractionEnabled = true
        csb.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleProductButton)))
        return csb
    }()
    
    lazy var vwPopBerat: POPViewMessage = {
        let view = POPViewMessage()
        return view
    }()
    
    lazy var mentionTableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.backgroundColor = .white
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UINib(nibName: "MentionCellTableViewCell", bundle: nil), forCellReuseIdentifier: "MentionCellTableViewCell")
        return tableView
    }()
    
    lazy var floatingTitleField: CustomIndentedTextField = {
        let field = CustomIndentedTextField(placeholder: "Title Link", padding: 16, cornerRadius: 8, keyboardType: .default, backgroundColor: .white, isSecureTextEntry: false, borderWidth: 1, borderColor: .whiteSmoke, prefix: nil)
        
        field.anchor(height: 46)
        field.textColor = .contentGrey
        field.returnKeyType = .next
        field.maxLength = 30
        field.onEditing = { s in
            if s.count == 1 {
                field.text = s.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            self.validateFloatingTitleField()
        }
        
        field.onEndEditing = { s in
            let s = s.trimmingCharacters(in: .whitespacesAndNewlines)
            field.text = s
            
            self.validateFloatingTitleField()
        }
        
        return field
    }()
    
    func validateFloatingTitleField() {
        
        let s = floatingTitleField.text ?? ""
        
        var hasError = false
        if(self.hasSpecialCharacter(text: s)){
            hasError = true
        }
        
        self.floatingTitleLengthLabel.text = "\(s.count)/30"
        if s.count < 4 && s.count > 0 {
            hasError = true
        }
        
        if(hasError){
            floatingTitleField.layer.borderColor = UIColor.redError.cgColor
            self.floatingTitleErrorLabel.isHidden = false
        } else {
            floatingTitleField.layer.borderColor = UIColor.whiteSmoke.cgColor
            self.floatingTitleErrorLabel.isHidden = true
        }

    }
    
    func hasSpecialCharacter(text: String?) -> Bool {
        // From Backend only allow Alphanumeric and Space
        
        if(text == nil) { return true }
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ")
        if text?.rangeOfCharacter(from: characterset.inverted) != nil {
            return true
        }

        return false
    }
    
    lazy var floatingTitleLengthLabel: UILabel = {
        let label: UILabel = UILabel(text: "0/30", font: .Roboto(.medium, size: 12), textColor: .grey, textAlignment: .right, numberOfLines: 1)
        return label
    }()
    
    lazy var floatingTitleErrorLabel: UILabel = {
        let label = UILabel()
        label.text = "Gunakan minimal 4 karakter, tanpa karakter spesial"
        label.font = .Roboto(.regular, size: 12)
        label.numberOfLines = 1
        label.textColor = .redError
        label.isHidden = true
        return label
    }()
    
    lazy var floatingLinkField: CustomIndentedTextField = {
        let link = UIImage(named: .get(.iconLinkGrey))
        let valid = UIImage(named: .get(.iconConfirm))
        let invalid = UIImage(named: .get(.iconWrong))
        let rightView =  UIImageView(image: link, contentMode: .scaleAspectFit)
        
        let field = CustomIndentedTextField(placeholder: "https://...", padding: 16, cornerRadius: 8, keyboardType: .URL, backgroundColor: .white, isSecureTextEntry: false, borderWidth: 1, borderColor: .whiteSmoke, prefix: nil)
        
        field.anchor(height: 46)
        field.textColor = .contentGrey
        field.returnKeyType = .done
        field.rightView = rightView
        field.rightViewMode = .always
        field.rightView?.anchor(width: 32, height: 12)
        
        field.onEditing = { s in updateView(s) }
        field.onEndEditing = { s in updateView(s) }
        
        func updateView(_ string: String){
            let s = string.trimmingCharacters(in: .whitespacesAndNewlines)
            field.text = s
            if s.isEmpty {
                field.layer.borderColor = UIColor.whiteSmoke.cgColor
                rightView.image = link
                self.floatingLinkErrorLabel.isHidden = true
                return
            }
            
            let isValid = isValidURL(urlString: s)
            self.floatingLinkErrorLabel.isHidden = isValid
            field.layer.borderColor = isValid ? UIColor.whiteSmoke.cgColor : UIColor.redError.cgColor
            field.textColor = isValid ? .secondary : .contentGrey
            rightView.image = isValid ? valid : invalid
        }
        
        return field
    }()
    
    
    func isValidURL(urlString: String) -> Bool {
        if !urlString.hasPrefix("https://") && !urlString.hasPrefix("http://") && !urlString.hasPrefix("www.") {
            return false
        }

        var modifiedURLString = urlString
        if urlString.hasPrefix("www.") {
            modifiedURLString = urlString.replacingOccurrences(of: "www.", with: "")
            modifiedURLString = "https://" + modifiedURLString
        }

        guard let urlComponents = URLComponents(string: modifiedURLString) else {
            return false
        }

        // Check if the scheme is valid and host is present
        if let scheme = urlComponents.scheme, (scheme == "https" || scheme == "http"), let host = urlComponents.host, !host.isEmpty {
            // Additional check for a valid domain name
            let domainNamePattern = "^[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
            let domainNameRegex = try! NSRegularExpression(pattern: domainNamePattern, options: [])
            let range = NSRange(location: 0, length: host.utf16.count)
            if domainNameRegex.firstMatch(in: host, options: [], range: range) != nil {
                return true
            }
        }

        return false
    }
    
    lazy var floatingLinkErrorLabel: UILabel = {
        let label = UILabel()
        let error = NSMutableAttributedString(string: "Gunakan format link yang sesuai contohnya ", attributes: [NSAttributedString.Key.font : UIFont.Roboto(.regular, size: 12)])
        let boldString = NSMutableAttributedString(string: "https://youtube.com", attributes: [NSAttributedString.Key.font : UIFont.Roboto(.bold, size: 12)])
        error.append(boldString)
        label.attributedText = error
        label.numberOfLines = 1
        label.textColor = .redError
        label.isHidden = true
        return label
    }()
    
    lazy var floatingSectionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        
        let divider = UIView()
        divider.backgroundColor = .whiteSmoke
        
        let caption = UILabel()
        caption.text = "Link dari postingan ini"
        caption.font = .Roboto(.regular, size: 12)
        caption.textColor = .contentGrey
        
        view.addSubViews([divider, caption, floatingTitleField, floatingTitleLengthLabel, floatingTitleErrorLabel, floatingLinkField, floatingLinkErrorLabel])
        divider.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 1)
        caption.anchor(top: divider.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20)
        floatingTitleField.anchor(top: caption.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 8, paddingLeft: 20, paddingRight: 20)
        floatingTitleLengthLabel.anchor(top: floatingTitleField.bottomAnchor, right: view.rightAnchor, paddingTop: 6, paddingRight: 20)
        floatingTitleErrorLabel.anchor(top: floatingTitleField.bottomAnchor, left: view.leftAnchor, right: floatingTitleLengthLabel.leftAnchor, paddingTop: 6, paddingLeft: 20, paddingRight: 8)
        floatingLinkField.anchor(top: floatingTitleErrorLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 12, paddingLeft: 20, paddingRight: 20)
        floatingLinkErrorLabel.anchor(top: floatingLinkField.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 6, paddingLeft: 20, paddingRight: 20)
        
        return view
    }()
    
	// MARK: - Public Property
    
    var selectedChannel: Channel?

	override func draw(_ rect: CGRect) {

		setupScrollView()

		if !isCreateFeed {
            captionContainer.isHidden = true
			postProductCSWL.isHidden = true
			shippingCSWL.isHidden = false
			channelButtonSelectView.isHidden = true
			descriptionProductCTV.isHidden = false
		} else {
            productPriceContainer.isHidden = true
            productStockContainer.isHidden = true
            productNameContainer.isHidden = true
			shippingLabelView.isHidden = true
			descriptionProductCTV.isHidden = true
			shippingCSWL.isHidden = true

			postProductCSWL.isHidden = false
		}
		shippingView.isHidden = true
		weightTextInput.isHidden = true
        floatingSectionView.isHidden = !isCreateFeed

	}

	func setupScrollView(){

		addSubview(scrollView)
		scrollView.addSubview(scrollViewContainer)

		scrollView.anchor(top: safeAreaLayoutGuide.topAnchor, leading: leadingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, trailing: trailingAnchor)
		scrollViewContainer.anchor(top: scrollView.topAnchor, leading: scrollView.leadingAnchor, bottom: scrollView.bottomAnchor, trailing: scrollView.trailingAnchor)

		scrollViewContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true

		setupStackView(scrollViewContainer)
	}

	func setupStackView(_ container: UIStackView){
        
        labelWeightError.isHidden = true
     
        
		[collectionView, captionContainer, labelLengthCaption, mentionTableView, channelButtonSelectView, channelSelectedView, productButtonSelectView, productSelectedView, productNameContainer, productPriceContainer, productStockContainer, shippingLabelView, shippingCSWL, shippingView, weightStackView, floatingSectionView].forEach { view in
			container.addArrangedSubview(view)
            view.anchor(left: container.leftAnchor, right: container.rightAnchor, paddingLeft: view != floatingSectionView ? 20 : 0, paddingRight: view != floatingSectionView ? 20 : 0)
		}
        mentionTableView.anchor(height: 200)
        
        productSelectedView.anchor(height: 74)
        productSelectedView.isHidden = true
        channelSelectedView.anchor(height: 74)
        channelSelectedView.isHidden = selectedChannel == nil
        
        addIndicatorWeightTextField()
	}
    
    func addIndicatorWeightTextField(){
        vwPopBerat.addToSuperview(self)
			vwPopBerat.setupText(.get(.weightInfo),
														 .get(.weightTermCondition),
														 .get(.ok))
//        weightTextInput.addIndicator(.iconInfo, .gray, {
//            self.vwPopBerat.showView()
//        })
    }
    
    func setSelectedChannel(channel: Channel, onClose: @escaping ()->()){
        selectedChannel = channel
        channelSelectedView.isHidden = false
        channelButtonSelectView.isHidden = true
        channelSelectedView.setupData(channel: channel)
        channelSelectedView.onCloseChannelClicked = {
            onClose()
            self.channelSelectedView.isHidden = true
            self.channelButtonSelectView.isHidden = false
        }
    }
    
    func setSelectedProduct(product: Product, onClose: @escaping ()->()){
        productSelectedView.isHidden = false
        productButtonSelectView.isHidden = true
        postProductCSWL.isHidden = true
        delegate?.changeType(type: "product")
        productSelectedView.setupData(product: product)
        productSelectedView.onCloseClicked = { [weak self] in
            self?.delegate?.changeType(type: "social")
            onClose()
            self?.productSelectedView.isHidden = true
            self?.productButtonSelectView.isHidden = false
            self?.postProductCSWL.isHidden = false
        }
    }
    
    func handleTiktokView(){
        captionCTV.nameTextField.text = String(captionCTV.nameTextField.text.prefix(150))
        labelLengthCaption.text = "\(captionCTV.nameTextField.text.count)/150"
        captionCTV.maxLength = 150
    }
    
    func reverseTiktokView(){
        labelLengthCaption.text = "\(captionCTV.nameTextField.text.count)/1000"
        captionCTV.maxLength = 1000
    }
}

//MARK: PROTOCOL AREA
extension PostView : CustomSwitchWithLabelDelegate {
	func handleSwitch(sender: UISwitch, id: Int) {
			if (sender.isOn == true){
                onSwitchAsProductChange(true)
			}
			else {
                onSwitchAsProductChange(false)
			}

	}
    
    func showView() {
        delegate?.changeType(type: "product")
        productPriceContainer.isHidden = false
        productStockContainer.isHidden = false
        productNameContainer.isHidden = false
        shippingLabelView.isHidden = false
        weightTextInput.isHidden = false
        weightInfo.isHidden = false
        labelWeightError.isHidden = false
        shippingView.isHidden = false
        shippingCSWL.isHidden = true
        productSelectedView.isHidden = true
        productButtonSelectView.isHidden = true
    }
    
    func hideView() {
        delegate?.changeType(type: "social")
        productPriceContainer.isHidden = true
        productStockContainer.isHidden = true
        productNameContainer.isHidden = true
        shippingLabelView.isHidden = true
        shippingCSWL.isHidden = true
        weightTextInput.isHidden = true
        weightInfo.isHidden = true
        labelWeightError.isHidden = true
        shippingView.isHidden = true
        shippingCSWL.isChecked = false
        productSelectedView.isHidden = true
        productButtonSelectView.isHidden = false
    }
    
    func setDimentionDefaultBorderColor() {
        lengthTextInput.setBorderColor = .whiteSmoke
        widthTextInput.setBorderColor = .whiteSmoke
        heightTextInput.setBorderColor = .whiteSmoke
    }
}


//MARK: PRIVATE AREA
private extension PostView {
	@objc func handleSwitchShipping(sender:UISwitch!) {

	}

	@objc func handleProductButton() {
        delegate?.whenTagProductClicked()
	}


	@objc func handleChannelButton() {
		delegate?.whenChannelClicked()
	}

	func handleCheckboxex(isCheck: Bool, option: CustomOption){

	}
}

fileprivate extension NSMutableAttributedString {
    private func setColorForText(_ textToFind: String?, with color: UIColor) {

        let range:NSRange?
        if let text = textToFind{
            range = self.mutableString.range(of: text, options: .caseInsensitive)
        }else{
            range = NSMakeRange(0, self.length)
        }
        if range!.location != NSNotFound {
            addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range!)
        }
    }
}
