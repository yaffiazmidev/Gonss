//
//  EditProductView.swift
//  KipasKipas
//
//  Created by Ibrohim Dasuqi on 20/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class EditProductView: UIView {
    
    lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.registerCustomCell(PostItemCell.self)
        collectionView.isScrollEnabled = true
        collectionView.isUserInteractionEnabled = true
        collectionView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return collectionView
    }()
    
    lazy var labelNameProduct: UILabel = {
        let label: UILabel = UILabel(text: "Nama Produk", font: .Roboto(.medium, size: 12), textColor: .grey, textAlignment: .left, numberOfLines: 0)
        return label
    }()
    
    lazy var labelPriceProduct: UILabel = {
        let label: UILabel = UILabel(text: "Harga Produk", font: .Roboto(.medium, size: 12), textColor: .grey, textAlignment: .left, numberOfLines: 0)
        return label
    }()
    
    lazy var labelStockProduct: UILabel = {
        let label: UILabel = UILabel(text: "Stok Produk Tersedia", font: .Roboto(.medium, size: 12), textColor: .grey, textAlignment: .left, numberOfLines: 0)
        return label
    }()
    
    lazy var labelDescriptionProduct: UILabel = {
        let label: UILabel = UILabel(text : "Deskripsi Produk", font: .Roboto(.medium, size: 12), textColor: .grey, textAlignment: .left, numberOfLines: 0)
        return label
    }()
    
    lazy var labelCategoryProduct: UILabel = {
        let label: UILabel = UILabel(text : "Kategory Produk", font: .Roboto(.medium, size: 12), textColor: .grey, textAlignment: .left, numberOfLines: 0)
        return label
    }()
    
    var labelLengthProduct: UILabel = {
        let label: UILabel = UILabel(text: "Panjang", font: .Roboto(.medium, size: 12), textColor: .contentGrey, textAlignment: .left, numberOfLines: 0)
        return label
    }()
    var labelwidthProduct: UILabel = {
        let label: UILabel = UILabel(text: "Lebar", font: .Roboto(.medium, size: 12), textColor: .contentGrey, textAlignment: .left, numberOfLines: 0)
        return label
    }()
    var labelHighProduct: UILabel = {
        let label: UILabel = UILabel(text: "Tinggi", font: .Roboto(.medium, size: 12), textColor: .contentGrey, textAlignment: .left, numberOfLines: 0)
        return label
    }()
    
    lazy var labelWeightProduct: UILabel = {
        let label: UILabel = UILabel(text: "Berat (kilogram)", font: .Roboto(.medium, size: 12), textColor: .contentGrey, textAlignment: .left, numberOfLines: 0)
        return label
    }()
    
    lazy var labelLengthNameProduct: UILabel = {
        let label: UILabel = UILabel(text: "0/70", font: .Roboto(.medium, size: 12), textColor: .grey, textAlignment: .left, numberOfLines: 0)
        return label
    }()
    lazy var labelLengthDescriptionProduct: UILabel = {
        let label: UILabel = UILabel(text: "0/1000", font: .Roboto(.medium, size: 12), textColor: .grey, textAlignment: .left, numberOfLines: 0)
        return label
    }()
    
    lazy var categoryProductButtonSelectView: CustomSelectView = {
        let csb = CustomSelectView(name: "Kategori Produk", rightImage: UIImage(named: .get(.iconNavigateNext)))
        csb.isUserInteractionEnabled = true
        csb.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleCategoryProductButton)))
        return csb
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
        ctv.nameTextField.textColor = .black
        ctv.placeholderFloating = "Tulis Deskripsi"
        ctv.heightAnchor.constraint(equalToConstant: 120).isActive = true
        ctv.maxLength = 1000
        return ctv
    }()
    
    lazy var nameItemView: CustomIndentedTextField = {
        let textField = CustomIndentedTextField(placeholder: "Nama Produk", padding: 16, cornerRadius: 8, keyboardType: .default, backgroundColor: .white, isSecureTextEntry: false, borderWidth: 1, borderColor: .whiteSmoke, prefix: nil)
        textField.textColor = .black
        textField.maxLength = 70
        return textField
    }()
    
    lazy var priceItemView: CustomIndentedTextField = {
        let textField = CustomIndentedTextField(placeholder: "Harga Barang", padding: 16, cornerRadius: 8, keyboardType: .decimalPad, backgroundColor: .white, isSecureTextEntry: false, borderWidth: 1, borderColor: .whiteSmoke, prefix: nil, isNumberOnly: true)      
        textField.onEndEditing = { string in
            textField.text = string.digits() == "0" ? "" : string.digits().toMoney()
        }
        textField.textColor = .black
        return textField
    }()
    
    lazy var stockItemView: CustomIndentedTextField = {
        let textField = CustomIndentedTextField(placeholder: "Stok Tersedia", padding: 16, cornerRadius: 8, keyboardType: .numberPad, backgroundColor: .white, isSecureTextEntry: false, borderWidth: 1, borderColor: .whiteSmoke, prefix: nil, isNumberOnly: true)
        
        let font = UIFont(name: "AirbnbCerealApp-Book", size: 12)
        let suffix = UILabel(text: "pcs", font: font, textColor: .lightGray, textAlignment: .center)
        
        textField.rightViewMode = .always
        textField.rightView = suffix
        textField.textColor = .black
        textField.rightView?.widthAnchor.constraint(equalToConstant: 50).isActive = true
        return textField
    }()
    
    
    lazy var stockWarningView: UIView = {
        let view = UIView()
        view.backgroundColor = .whiteSnow
        view.layer.borderColor = UIColor.whiteSmoke.cgColor
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let image = UIImageView(image:  UIImage(named: .get(.iconInfoProduct)), contentMode: .center)
        let title = UILabel(text: " Hitung stok tersedia", font: .Roboto(.medium, size: 11), textColor: .secondary, textAlignment: .left, numberOfLines: 1)
        let description = UILabel()
        description.font = .Roboto(.medium, size: 10)
        description.textColor = .black
        description.numberOfLines = 0
        description.text = "Jumlah stok tersedia disini adalah jumlah stok dikurangi stok yang sedang ada dalam proses pembelian produk oleh pembeli."
        
        let titles = UIStackView(arrangedSubviews: [image, title])
        titles.axis = .horizontal
        titles.translatesAutoresizingMaskIntoConstraints = false
        
        let container = UIStackView(arrangedSubviews: [titles, description])
        container.axis = .vertical
        container.spacing = 6
        container.alignment = .leading
        container.distribution = .fill
        container.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(container)
        container.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10)
        
        return view
    }()
    
    var lengthItemView: CustomIndentedTextField = {
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
        textField.anchor(height: 46)
        return textField
    }()
    
    var widthItemView: CustomIndentedTextField = {
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
        textField.anchor(height: 46)
        return textField
    }()
    
    var highItemView: CustomIndentedTextField = {
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
        textField.anchor(height: 46)
        return textField
    }()
    
    var weightItemView: CustomIndentedTextField = {
        let textField = CustomIndentedTextField(placeholder: "Berat kg", padding: 16, cornerRadius: 8, keyboardType: .decimalPad, backgroundColor: .white, isSecureTextEntry: false, borderWidth: 1, borderColor: .whiteSmoke, prefix: nil)
        
        textField.onBeginEditing = { string in
            if string.suffix(3) == " kg" {
                textField.text = String(string.dropLast(3))
            }
        }
        
        textField.onEndEditing = { string in
            let weight = Measurement(
                value: Double(string.replacingOccurrences(of: ",", with: ".")) ?? 0.0,
                unit: UnitMass.kilograms
            )
            textField.text = weight.description
        }
        
        textField.textColor = .black
        
        textField.anchor(width: 200, height: 46)
        textField.maxLength = 3
        return textField
    }()
    
    let labelWeightError = UILabel(text: .get(.minimalBerat01), font: .Roboto(.regular, size: 12), textColor: .redError, textAlignment: .left, numberOfLines: 1)
    
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
        weightInfo.onTap { [weak self] in
            self?.handleInfo()
        }
        return weightInfo
    }()
    
    lazy var vwPopBerat: POPViewMessage = {
        let view = POPViewMessage()
        return view
    }()
    
    lazy var weightStackView: UIStackView = {
        let weightTextInputStackView = UIStackView(arrangedSubviews: [weightItemView])
        weightTextInputStackView.axis = .vertical
        weightTextInputStackView.alignment = .leading
        weightTextInputStackView.isLayoutMarginsRelativeArrangement = true
        
        let view = UIStackView(arrangedSubviews: [weightInfo, weightTextInputStackView, labelWeightError])
        view.axis = .vertical
        view.spacing = 10
        view.alignment = .fill
        view.distribution = .fillProportionally
        view.isLayoutMarginsRelativeArrangement = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var handleInfo : () -> () = { }
    func handleInfoButton(){
//        weightItemView.addIndicator(.iconInfo, .gray) {
//            self.handleInfo()
//        }
    }
    
    lazy var lengthStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [lengthItemView])
        view.axis = .vertical
//        view.spacing = 8
//        view.alignment = .leading
        view.distribution = .fillProportionally
        view.isLayoutMarginsRelativeArrangement = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var widthStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [widthItemView])
        view.axis = .vertical
//        view.spacing = 8
//        view.alignment = .leading
        view.distribution = .fillProportionally
        view.isLayoutMarginsRelativeArrangement = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var highStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [highItemView])
        view.axis = .vertical
//        view.spacing = 8
//        view.alignment = .leading
        view.distribution = .fillProportionally
        view.isLayoutMarginsRelativeArrangement = true
        view.translatesAutoresizingMaskIntoConstraints = false
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
    
    lazy var containerStackView: UIStackView = {
        let items = UIStackView(arrangedSubviews: [lengthStackView, widthStackView, highStackView])
        items.axis = .horizontal
        items.spacing = 13
        items.alignment = .fill
        items.distribution = .fillEqually
        
        let container = UIStackView(arrangedSubviews: [shippingLabelView, items])
        container.axis = .vertical
        container.spacing = 14
        container.alignment = .leading
        container.distribution = .fillProportionally
        container.isLayoutMarginsRelativeArrangement = true
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    var handleTapCategoryProduct: (() -> Void)?
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        labelWeightError.isHidden = true
        //scrollView.showsVerticalScrollIndicator = false
        scrollView.fillSuperview()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.anchor(top: scrollView.superview?.topAnchor, left: nil, bottom: scrollView.superview?.bottomAnchor, right: scrollView.superview?.rightAnchor)
        scrollView.centerXAnchor.constraint(equalTo: scrollView.superview!.centerXAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: scrollView.superview!.widthAnchor).isActive = true
        scrollView.heightAnchor.constraint(equalTo: scrollView.superview!.heightAnchor).isActive = true
        
        contentView.anchor(top: scrollView.topAnchor, left: nil, bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor)
        contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        [collectionView, labelNameProduct, nameItemView, labelLengthNameProduct, labelPriceProduct, priceItemView, labelStockProduct, stockItemView, stockWarningView, labelDescriptionProduct, captionCTV, labelCategoryProduct, categoryProductButtonSelectView, containerStackView, weightStackView, labelLengthDescriptionProduct].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        collectionView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20)
        labelNameProduct.anchor(top: collectionView.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20)
        nameItemView.anchor(top: labelNameProduct.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 8, paddingLeft: 20, paddingRight: 20, height: 46)
        labelLengthNameProduct.anchor(top: nameItemView.bottomAnchor, right: contentView.rightAnchor, paddingTop: 6, paddingRight: 32)
        labelPriceProduct.anchor(top: labelLengthNameProduct.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20)
        priceItemView.anchor(top: labelPriceProduct.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 8, paddingLeft: 20, paddingRight: 20, height: 46)
        labelStockProduct.anchor(top: priceItemView.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20)
        stockItemView.anchor(top: labelStockProduct.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 8, paddingLeft: 20, paddingRight: 20, height: 46)
        stockWarningView.anchor(top: stockItemView.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 4, paddingLeft: 20, paddingRight: 20)
        
        labelDescriptionProduct.anchor(top: stockWarningView.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20)
        captionCTV.anchor(top: labelDescriptionProduct.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 8, paddingLeft: 20, paddingRight: 20, height: 100)
        labelLengthDescriptionProduct.anchor(top: captionCTV.bottomAnchor, right: contentView.rightAnchor, paddingTop: 6, paddingRight: 32)
        
        labelCategoryProduct.anchor(top: labelLengthDescriptionProduct.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20)
        categoryProductButtonSelectView.anchor(top: labelCategoryProduct.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 8, paddingLeft: 20, paddingRight: 20)
        
        containerStackView.anchor(top: categoryProductButtonSelectView.bottomAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20)
        weightStackView.anchor(top: containerStackView.bottomAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, paddingTop: 32, paddingLeft: 20, paddingBottom: 12, paddingRight: 20)
        
        handleInfoButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc
    func handleCategoryProductButton() {
        handleTapCategoryProduct?()
    }
    
}
