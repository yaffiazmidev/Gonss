//
//  ProfileSearchEmptyView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 05/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class ProfileSearchEmptyView: UIView {
    
    var searchText = "" {
        didSet {
            setText(searchText)
        }
    }
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        
        addSubview(label)
        label.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 12, paddingLeft: 6, paddingBottom: 26, paddingRight: 6)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setText(_ text: String){
        if text.isEmpty {
            label.attributedText = nil
            label.text = nil
            return
        }
        
        var trimText = text
        
        if trimText.count > 25 {
            trimText = trimText.prefix(25) + "..."
        }
        
        let myString = NSMutableAttributedString(
            string: "“\(trimText)”",
            attributes: [
                NSAttributedString.Key.font: UIFont.Roboto(.medium, size: 12),
                NSAttributedString.Key.foregroundColor: UIColor.contentGrey
            ]
        )
        
        let attrString = NSAttributedString(
            string: " tidak ditemukan.",
            attributes: [
                NSAttributedString.Key.font: UIFont.Roboto(size: 12),
                NSAttributedString.Key.foregroundColor: UIColor.contentGrey
            ]
        )
        
        myString.append(attrString)
        label.attributedText = myString
    }
}
