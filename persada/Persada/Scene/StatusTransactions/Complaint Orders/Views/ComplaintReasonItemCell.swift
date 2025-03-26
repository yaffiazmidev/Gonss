//
//  ComplaintReasonItemCell.swift
//  KipasKipas
//
//  Created by NOOR on 02/02/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

final class ComplaintReasonItemCell: UITableViewCell, UITextViewDelegate {
	
	var handleWhenUserTappedText: (() -> Void)?
	
	lazy var captionCTV: CustomTextView = {
		let ctv = CustomTextView(backgroundColor: .white)
		ctv.nameTextField.backgroundColor = .white
		ctv.nameTextField.layer.cornerRadius = 8
		ctv.nameTextField.layer.borderColor = UIColor.whiteSmoke.cgColor
		ctv.nameTextField.layer.borderWidth = 1
		ctv.nameTextField.font = .Roboto(.regular, size: 12)
		ctv.nameTextField.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 0, right: 0)
        ctv.placeholder = "Tulis alasan Anda..."
		ctv.nameTextField.delegate = self
		ctv.draw(.zero)
		ctv.isUserInteractionEnabled = true
		ctv.translatesAutoresizingMaskIntoConstraints = false
		ctv.heightAnchor.constraint(equalToConstant: 120).isActive = true
		let gesture = UITapGestureRecognizer(target: self, action: #selector(handleGestureReason(_:)))
		ctv.addGestureRecognizer(gesture)
		return ctv
	}()
	
	lazy var counterLabel: UILabel = {
		let label = UILabel(font: .Roboto(.regular, size: 12), textColor: .lightGray, textAlignment: .right, numberOfLines: 0)
		label.translatesAutoresizingMaskIntoConstraints = true
        label.layer.masksToBounds = true
		label.text = ""
		return label
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		backgroundColor = .white
		
		[captionCTV, counterLabel].forEach {
			contentView.addSubview($0)
		}
		
		counterLabel.anchor(bottom: contentView.safeAreaLayoutGuide.bottomAnchor, right: contentView.safeAreaLayoutGuide.rightAnchor, paddingBottom: 4, paddingRight: 20, width: 50, height: 20)
		captionCTV.anchor(top: contentView.safeAreaLayoutGuide.topAnchor, left: contentView.safeAreaLayoutGuide.leftAnchor, bottom: counterLabel.topAnchor, right: contentView.safeAreaLayoutGuide.rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 8, paddingRight: 20)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		let newLength = textView.text.utf16.count + text.utf16.count - range.length

		counterLabel.text = "\(newLength)/500"
		return textView.text.count - range.length + text.count < 500
	}
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.placeholder {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty{
            textView.text = "Tulis alasan Anda..."
            textView.textColor = UIColor.placeholder
        }
    }
    
	
	@objc func handleGestureReason(_ sender: UITapGestureRecognizer) {
		handleWhenUserTappedText?()
	}

}

