//
//  CancelSalesOrderView.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 03/02/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import UIKit

protocol CancelSalesOrderViewDelegate where Self: UIViewController {
	func dismiss()
	func showDialog()
	func confirmFinalCancel()
	func dismissBacktoRoot()
}

final class CancelSalesOrderView: UIView {
	
	weak var delegate: CancelSalesOrderViewDelegate?
	
	lazy var tableView: UITableView = {
		let table = UITableView(frame: .zero)
		table.translatesAutoresizingMaskIntoConstraints = false
		table.allowsMultipleSelection = false
		table.isMultipleTouchEnabled = false
		table.tableFooterView = UIView()
		table.rowHeight = UITableView.automaticDimension
		table.estimatedRowHeight = 380
		table.backgroundColor = .white
		table.isUserInteractionEnabled = true
		table.separatorStyle = .none
		table.registerCustomCell(ReportFeedCell.self)
		return table
	}()
	
	let viewDialogPopup: UIView = {
		let mainView = UIView()
		let titleLabel = UILabel(text: .get(.orderAlreadyCanceled), font: .Roboto(.bold, size: 14), textColor: .black, textAlignment: .left, numberOfLines: 1)
		let subtitleLabel = UILabel(text: .get(.dontGiveupYourShop),
			font: .Roboto(.regular, size: 14), textColor: .grey, textAlignment: .left, numberOfLines: 0)
		
		let backButton = PrimaryButton(title: .get(.done), titleColor: .white, font: .Roboto(.regular, size: 13), backgroundColor: .secondary, target: self, action: #selector(backToRoot(_:)))
		
		mainView.addSubview(titleLabel)
		mainView.addSubview(subtitleLabel)
		mainView.addSubview(backButton)
		
		titleLabel.anchor(top: mainView.topAnchor, left: mainView.leftAnchor, right: mainView.rightAnchor, paddingTop: 24, paddingLeft: 24, paddingRight: 24, height: 26)
		subtitleLabel.anchor(top: titleLabel.bottomAnchor, left: mainView.leftAnchor, right: mainView.rightAnchor, paddingTop: 24, paddingLeft: 24, paddingRight: 24, height: 60)
		backButton.anchor(top: subtitleLabel.bottomAnchor, left: mainView.leftAnchor, bottom: mainView.bottomAnchor, right: mainView.rightAnchor, paddingTop: 24, paddingLeft: 24, paddingBottom: 24, paddingRight: 24)
		
		mainView.backgroundColor = .white
		mainView.translatesAutoresizingMaskIntoConstraints = false
		mainView.layer.masksToBounds = false
		mainView.layer.cornerRadius = 4
		mainView.isHidden = true
		return mainView
	}()
	
	let viewPopupBackground: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .black
		view.alpha = 0.4
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGestureBack(sender:)))
		tapGesture.numberOfTapsRequired = 1
		tapGesture.isEnabled = true
		tapGesture.cancelsTouchesInView = false
		view.addGestureRecognizer(tapGesture)
		view.isHidden = true
		view.isUserInteractionEnabled = true
		return view
	}()
	
	lazy var submitReportButton: UIButton = {
		let button = BadgedButton(type: .system)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.layer.cornerRadius = 8
		button.layer.masksToBounds = false
		button.setTitleColor(.grey, for: .normal)
		button.backgroundColor = .whiteSnow
		button.titleLabel?.font = .Roboto(.bold, size: 14)
		button.titleLabel?.textColor = .grey
		button.addTarget(self, action: #selector(requestCancelOrder(_:)), for: .touchUpInside)
		button.setTitle(.get(.confirmCanceledOrder), for: .normal)
		return button
	}()
	
	lazy var reasonCTV: CustomTextView = {
		let ctv: CustomTextView = CustomTextView(backgroundColor: .white)
		ctv.placeholder = .get(.writeYourReason)
		ctv.nameLabel.font = .Roboto(.regular, size: 12)
        ctv.nameTextField.backgroundColor = .white
		ctv.nameTextField.layer.cornerRadius = 8
		ctv.nameTextField.layer.borderColor = UIColor.whiteSmoke.cgColor
		ctv.nameTextField.layer.borderWidth = 1
        ctv.nameTextField.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 0, right: 0)
        ctv.nameTextField.delegate = self

		
		ctv.draw(.zero)
		return ctv
	}()
    
    lazy var counterLabel: UILabel = {
        let label = UILabel(font: .Roboto(.regular, size: 12), textColor: .lightGray, textAlignment: .right, numberOfLines: 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0/200"
        return label
    }()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .white
		tableView.separatorStyle = .none

		addSubview(submitReportButton)
		addSubview(reasonCTV)
		addSubview(viewDialogPopup)
		addSubview(viewPopupBackground)
        reasonCTV.nameTextField.addSubview(counterLabel)
        reasonCTV.nameTextField.bringSubviewToFront(counterLabel)
		
		viewPopupBackground.fillSuperviewSafeAreaLayoutGuide()
		viewDialogPopup.centerXToSuperview()
		viewDialogPopup.centerYToSuperview()
		viewDialogPopup.widthAnchor.constraint(equalToConstant: 310).isActive = true
		viewDialogPopup.heightAnchor.constraint(equalToConstant: 220).isActive = true
		
		submitReportButton.anchor(top: nil, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 24, paddingRight: 20, width: 0, height: 50)
		addSubview(tableView)
		tableView.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 10, paddingLeft: 20, paddingBottom: 10, paddingRight: 20)
		tableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 380).isActive = true
		reasonCTV.anchor(top: tableView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, height: 150)
        counterLabel.anchor(bottom: reasonCTV.bottomAnchor, right: reasonCTV.rightAnchor, paddingBottom: 16, paddingRight: 12)
        
		reasonCTV.isHidden = true

		tableView.estimatedRowHeight = 50
		tableView.alwaysBounceVertical = false
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc func dismiss(_ sender: UIButton) {
		self.delegate?.dismiss()
	}
	
	@objc func backToRoot(_ sender: UIButton) {
		self.delegate?.dismissBacktoRoot()
	}
	
	@objc func handleGestureBack(sender: UITapGestureRecognizer) {
		self.delegate?.dismiss()
	}
	
	@objc func requestCancelOrder(_ sender: UIButton) {
		self.delegate?.confirmFinalCancel()
	}
}

extension CancelSalesOrderView : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength = textView.text.utf16.count + text.utf16.count - range.length

        counterLabel.text = "\(newLength)/200"
        return textView.text.count - range.length + text.count < 200
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
}

