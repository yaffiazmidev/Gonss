//
//  HistoryOfBalanceItemCell.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 04/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class HistoryOfBalanceItemCell: UITableViewCell {
	
	let dateLabel: UILabel = {
		let label = UILabel(text: "", font: .Roboto(.regular, size: 13), textColor: .grey, textAlignment: .left, numberOfLines: 1)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let balanceLabel: UILabel = {
		let label = UILabel(text: "".toMoney(), font: .Roboto(.regular, size: 13), textColor: .secondary, textAlignment: .left, numberOfLines: 1)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.backgroundColor = .whiteSnow
		dateLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
		balanceLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
		let stackView = hstack(dateLabel, balanceLabel, spacing: 0, alignment: .fill, distribution: .fillProportionally)
		contentView.addSubview(stackView)
		stackView.fillSuperviewSafeAreaLayoutGuide()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	func configure(date epoch: Int, balance: String) {
		let epochConvertToDate = Date(timeIntervalSince1970: TimeInterval((epoch)/1000 )).timeAgoDisplay()
			
		dateLabel.text = epochConvertToDate
		balanceLabel.text = balance
	}
}
