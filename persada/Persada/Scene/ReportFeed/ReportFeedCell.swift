//
//  ReportFeedCell.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 23/08/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class ReportFeedCell: UITableViewCell {
    
    var item: String? {
        didSet {
            nameLabel.text = item
        }
    }
    
    private var nameLabel: UILabel = {
        let lbl = UILabel(font: .Roboto(.medium, size: 14), textColor: .black, textAlignment: .left, numberOfLines: 0)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 0
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(nameLabel)
        selectionStyle = .none
        layer.cornerRadius = 8
        nameLabel.anchor(top: nil, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 270, height: 0)
        nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bottomPadding: CGFloat = 10
        contentView.frame = self.contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: bottomPadding, right: 0))
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        backgroundColor = selected ? .secondaryLowTint : .clear
        nameLabel.textColor = selected ? .secondary : .contentGrey
        nameLabel.font = selected ? .Roboto(.bold, size: 14) : .Roboto(.medium, size: 14)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
