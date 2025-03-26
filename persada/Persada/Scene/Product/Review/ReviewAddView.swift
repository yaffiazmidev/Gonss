//
//  ReviewAddView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 18/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit
import Cosmos

class ReviewAddView: UIView{
    var mediaViewHeightAnchor = NSLayoutConstraint()
    
    lazy var closeView: UIImageView = {
        let image = UIImage(named: .get(.iconClose))
        let view = UIImageView(image: image)
        return view
    }()
    
    lazy var productImageView: UIImageView = {
        let image = UIImage(named: .get(.iconKipasKipas))
        let view = UIImageView(image: image)
        view.setCornerRadius = 6
        view.clipsToBounds = true
        return view
    }()
    
    lazy var productNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Memuat"
        label.font = .Roboto(.regular, size: 12)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    lazy var productView: UIView = {
        let view = UIView()
        view.addSubview(productImageView)
        view.addSubview(productNameLabel)
        
        productImageView.anchor(top: view.topAnchor, left: view.leftAnchor, width: 48, height: 48)
        productNameLabel.anchor(top: view.topAnchor, left: productImageView.rightAnchor, right: view.rightAnchor, paddingLeft: 8)
        
        return view
    }()
    
    lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .Roboto(.medium, size: 11)
        label.textColor = .grey
        label.text = "Sangat bagus"
        return label
    }()
    
    lazy var ratingView: CosmosView = {
        let view = CosmosView()
        view.rating = 5
        
        let gold = UIColor(hexString: "#FFBC10")
        view.settings.filledColor = gold
        view.settings.emptyBorderColor = gold
        view.settings.filledBorderColor = gold
        
        view.settings.starMargin = 10
        view.settings.starSize = 34
        view.settings.emptyImage = UIImage(named: .get(.iconProductStarEmpty))
        view.settings.filledImage = UIImage(named: .get(.iconProductStarFill))
        
        return view
    }()
    
    lazy var reviewLabel: UILabel = {
        let label = UILabel()
        label.text = "Apa yang membuat kamu puas?"
        label.font = .Roboto(.medium, size: 12)
        label.textColor = .black
        return label
    }()
    
    lazy var reviewCTV: CustomTextView = {
        let ctv = CustomTextView(backgroundColor: .white)
        ctv.nameTextField.backgroundColor = .white
        ctv.nameTextField.layer.cornerRadius = 8
        ctv.nameTextField.layer.borderColor = UIColor.whiteSmoke.cgColor
        ctv.nameTextField.layer.borderWidth = 1
        ctv.nameTextField.font = .Roboto(.regular, size: 12)
        ctv.nameTextField.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 0, right: 0)
        ctv.draw(.zero)
        ctv.nameTextField.textColor = .black
        ctv.placeholderFloating = "Ceritakan pendapat kamu tentang produk yang kamu terima.."
        ctv.heightAnchor.constraint(equalToConstant: 120).isActive = true
        ctv.maxLength = 1000
        return ctv
    }()
    
    lazy var reviewMinLengthCaption: UILabel = {
        let label: UILabel = UILabel(text: "Tulis minimal 40 karakter.", font: .Roboto(.regular, size: 10), textColor: .grey, textAlignment: .left, numberOfLines: 0)
        return label
    }()
    
    lazy var reviewMaxLengthCaption: UILabel = {
        let label: UILabel = UILabel(text: "0/1000", font: .Roboto(.regular, size: 10), textColor: .grey, textAlignment: .right, numberOfLines: 0)
        label.isHidden = true
        return label
    }()
    
    lazy var mediaView: ReviewAddMediaView = {
        let view = ReviewAddMediaView.loadViewFromNib()
        mediaViewHeightAnchor = view.heightAnchor.constraint(equalToConstant: 64)
        mediaViewHeightAnchor.isActive = true
        view.handleHeightUpdated = { [weak self] (height) in
            self?.mediaViewHeightAnchor.constant = height
        }
        return view
    }()
    
    lazy var submitView: ReviewAddSubmitView = {
        let view = ReviewAddSubmitView.loadViewFromNib()
        view.submitButton.backgroundColor = .gradientStoryOne
        view.hideUsernameCheckBox.style = .tick
        view.hideUsernameCheckBox.borderStyle = .roundedSquare(radius: 2)
//        view.submitButton.isEnabled = trye
//        view.submitButton.backgroundColor = .whiteSmoke
        return view
    }()
    
    lazy var addPhotoEmptyView: UIView = {
        let view = DashedBorderView(dashedLineColor: UIColor.whiteSmoke.cgColor, dashedLineWidth: 1.0)
        
        let icon = UIImageView(image: UIImage(named: .get(.iconCamera)))
        let caption = UILabel(text: "Tambahkan foto/video produk yang kamu terima", font: .Roboto(.regular, size: 12), textColor: .placeholder, textAlignment: .center, numberOfLines: 0)
        
        view.addSubview(icon)
        view.addSubview(caption)
        icon.anchor(top: view.topAnchor, paddingTop: 8, paddingLeft: 12, paddingRight: 12, width: 24, height: 24)
        caption.anchor(top: icon.bottomAnchor, bottom: view.bottomAnchor, paddingTop: 8, paddingLeft: 12, paddingBottom: 8, paddingRight: 12)
        icon.centerXTo(view.centerXAnchor)
        caption.centerXTo(view.centerXAnchor)
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateRatingLabel(){
        switch(ratingView.rating){
        case 1.0:
            ratingLabel.text = "Sangat buruk"
            break;
        case 2.0:
            ratingLabel.text = "Mengecewakan"
            break;
        case 3.0:
            ratingLabel.text = "Cukup bagus"
            break;
        case 4.0:
            ratingLabel.text = "Bagus"
            break;
        case 5.0:
            ratingLabel.text = "Sangat bagus"
            break;
        default:
            ratingLabel.text = ""
            break;
        }
    }
}
