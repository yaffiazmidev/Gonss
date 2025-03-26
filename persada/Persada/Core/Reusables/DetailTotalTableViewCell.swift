//
//  DetailTotalTableViewCell.swift
//  KipasKipas
//
//  Created by movan on 14/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class DetailTotalTableViewCell: UITableViewCell {
	
	var item: TransactionProduct?{
		didSet{
			
			guard let quantity: Int = item?.orderDetail?.quantity, let price: Double = item?.orderDetail?.productPrice, let cost: Int = item?.orderShipment?.cost, let total: Int = item?.amount else { return }

			let validPrice = String(price).toMoney()
			let validCost = String(cost).toMoney()
			let validTotal = String(total).toMoney()
			let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: "\(quantity) x \(validPrice)",
				attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13), NSAttributedString.Key.foregroundColor: UIColor.black])

			attributedText.append(NSMutableAttributedString(string: "\n \(validCost)",
				attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13), NSAttributedString.Key.foregroundColor: UIColor.black]))

			attributedText.append(NSMutableAttributedString(string: "\n \(validTotal)",
				attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.black ]))
			
			let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
			paragraphStyle.lineSpacing = 8
			attributedText.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedText.length))
			
			self.summaryNumberLabel.attributedText = attributedText
		}
	}
	
	lazy var summaryTextLabel: UILabel = {
		let label: UILabel = UILabel()
		
		let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: "Subtotal \n",
			attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13), NSAttributedString.Key.foregroundColor: UIColor.black ])
		
		attributedText.append(NSMutableAttributedString(string: "Biaya Kirim \n",
			attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13), NSAttributedString.Key.foregroundColor: UIColor.black ]))
		
		attributedText.append(NSMutableAttributedString(string: "Total",
			attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.black ]))
		
		let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = 8
		attributedText.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedText.length))
		
		label.backgroundColor = .white
		label.attributedText = attributedText
		label.textAlignment = .left
		label.numberOfLines = 0
		label.textColor = .black
		
		return label
	}()
	
	lazy var summaryNumberLabel: UILabel = {
		let label: UILabel = UILabel()
		label.textColor = .black
		label.numberOfLines = 0
		label.textAlignment = .right
		label.backgroundColor = .white
		return label
	}()
	
	let mainView: UIView = {
		let view: UIView = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.masksToBounds = false
		view.layer.cornerRadius = 8
		view.backgroundColor = .whiteSnow
		view.backgroundColor = .white
		return view
	}()
	
	private enum ViewTrait {
		static let padding: CGFloat = 16
	}
	
	func setupViewCell(){
		backgroundColor = .white
		addSubview(mainView)
		mainView.fillSuperviewSafeAreaLayoutGuide(padding: UIEdgeInsets(top: ViewTrait.padding, left: ViewTrait.padding, bottom: ViewTrait.padding, right: ViewTrait.padding))
		
		[summaryTextLabel, summaryNumberLabel].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			mainView.addSubview($0)
		}
		
		summaryTextLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, width: 120, height: 0)
		summaryNumberLabel.anchor(top: topAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingBottom: 0, paddingRight: 20, width: 120, height: 0)
	}
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupViewCell()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure(_ quantity: Int, _ price: Int, _ cost: Int, _ total: Int) {
		let validPrice = String(price).toMoney()
		let validCost = String(cost).toMoney()
		let validTotal = String(total).toMoney()
		let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: "\(quantity) x \(validPrice)",
			attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13), NSAttributedString.Key.foregroundColor: UIColor.black])

		attributedText.append(NSMutableAttributedString(string: "\n \(validCost)",
			attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13), NSAttributedString.Key.foregroundColor: UIColor.black]))

		attributedText.append(NSMutableAttributedString(string: "\n \(validTotal)",
			attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.black ]))
		
		
		let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = 8
		attributedText.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedText.length))
		
		self.summaryNumberLabel.attributedText = attributedText
	}
}
