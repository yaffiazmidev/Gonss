//
//  CommentCell.swift
//  Persada
//
//  Created by NOOR on 25/06/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

final class CommentEmptyCell: UICollectionViewCell {
    
    lazy var emptyTextView: ActiveLabel = {
        let label: ActiveLabel = ActiveLabel(font: .AirBnbCereal(.book, size: 12), textColor: .placeholder, textAlignment: .center, numberOfLines: 1)
//        label.mentionColor = .secondary
//        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
//        label.heightAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
        label.backgroundColor = .white
        label.text = String.get(.emptyComment)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white

        contentView.addSubViews(views: [emptyTextView])
        
        emptyTextView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, paddingTop: 79, paddingLeft: 0, paddingBottom: 79, paddingRight: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var width: NSLayoutConstraint = {
        let width = contentView.widthAnchor.constraint(equalToConstant: bounds.size.width)
        width.isActive = true
        return width
    }()

    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        width.constant = bounds.size.width
        return contentView.systemLayoutSizeFitting(CGSize(width: targetSize.width, height: 1))
    }
}
