//
//  ComplaintProveVideoItemCell.swift
//  KipasKipas
//
//  Created by NOOR on 02/02/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

final class ComplaintProveVideoItemCell: UITableViewCell {
	
	let titleLabel = UILabel(text: "Bukti Video", font: .Roboto(.bold, size: 14), textColor: .black, textAlignment: .left, numberOfLines: 1)
	let subtitleLabel = UILabel(text: "Upload  video produk yang sudah kamu terima untuk dijadikan bukti dari komplain yang akan kamu ajukan.", font: .Roboto(.regular, size: 12), textColor: .black, textAlignment: .justified, numberOfLines: 0)
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		backgroundColor = .white
		
		[titleLabel, subtitleLabel].forEach {
			contentView.addSubview($0)
		}
		
		titleLabel.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 4, paddingRight: 20)
		subtitleLabel.anchor(top: titleLabel.bottomAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, paddingTop: 8, paddingLeft: 20, paddingBottom: 8, paddingRight: 20)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
}

