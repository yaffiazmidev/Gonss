//
//  CustomDatePicker.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 05/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class CustomDatePicker: UIView, UITextViewDelegate {
	
	// MARK: - Public Property
	
	var type: UIKeyboardType = .default
	var placeholder: String = ""
	var title: String = "" {
		didSet {
			self.nameLabel.text = title
		}
	}
	var titleColor: String = ""
	
	lazy var nameLabel: UILabel = {
		let label = UILabel(text: title, font: .Roboto(.medium, size:12), textColor: .placeholder, textAlignment: .left, numberOfLines: 0)
		label.translatesAutoresizingMaskIntoConstraints = false
		
		return label
	}()
	
	lazy var datePicker: UIDatePicker = {
		let view = UIDatePicker(frame: .zero)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.calendar = .autoupdatingCurrent
		view.datePickerMode = .date
		view.addTarget(self, action: #selector(dateChanged(_:)), for: .allEvents)
		return view
	}()
	
	lazy var nameTextField: UITextView = {
		let textView = UITextView()
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.textAlignment = .left
		textView.delegate = self
		textView.font = .Roboto(.medium, size:14)
		textView.textColor = .black
		textView.backgroundColor = .white
		if !self.placeholder.isEmpty {
			textView.text = self.placeholder
			textView.textColor = .placeholder
		}
		return textView
	}()
	
	let viewFrame = UIView(frame: .zero)
	
	// MARK: - Public Method
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		let doneButton = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(self.datePickerDone))
		let toolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: 44))
		toolBar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButton], animated: true)
		
		addSubview(viewFrame)
		viewFrame.translatesAutoresizingMaskIntoConstraints = false
		viewFrame.fillSuperview()
		
		viewFrame.addSubview(nameLabel)
		viewFrame.addSubview(nameTextField)
		
		nameLabel.anchor(top: viewFrame.topAnchor, left: viewFrame.leftAnchor, bottom: nil, right: viewFrame.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
		
		nameTextField.anchor(top: nameLabel.bottomAnchor, left: viewFrame.leftAnchor, bottom: viewFrame.safeAreaLayoutGuide.bottomAnchor, right: viewFrame.rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 5, paddingRight: 0, width: 0, height: 0)
		
		if !self.titleColor.isEmpty{
			nameLabel.textColor = UIColor(hexString: self.titleColor)
		}
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	@objc private func datePickerDone() {
		nameTextField.resignFirstResponder()
	}
	
	@objc private func dateChanged(_ sender: UIDatePicker) {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "dd/MM/yy"
		nameTextField.text = dateFormatter.string(from: sender.date)
	}
	
	func textFieldIsEmpty() -> Bool  {
		if nameTextField.text?.isEmpty ?? false {
			return false
		} else {
			return true
		}
	}

	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.textColor == UIColor.placeholder {
			textView.text = nil
			textView.textColor = UIColor.black
		}
	}

	func textViewDidEndEditing(_ textView: UITextView) {
		if textView.text.isEmpty{
			textView.text = placeholder
			textView.textColor = UIColor.placeholder
		}
	}
}
