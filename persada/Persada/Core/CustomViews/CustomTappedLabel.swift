//
//  CustomTappedLabel.swift
//  KipasKipas
//
//  Created by movan on 18/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class CustomTappedLabel: UIView {
	
	let titleLabel = UILabel(font: .Roboto(.bold, size: 13), textColor: .black, textAlignment: .left, numberOfLines: 0)
	
	let durationLabel = UILabel(font: .Roboto(.medium, size: 11), textColor: .black, textAlignment: .left, numberOfLines: 0)
	
	let subtitleLabel = UILabel(font: .Roboto(.bold, size: 13), textColor: .black, textAlignment: .left, numberOfLines: 0)
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		[titleLabel, subtitleLabel, durationLabel].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			addSubview($0)
		}
		
		subtitleLabel.anchor(top: topAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 16, paddingBottom: 16, paddingRight: 8, width: 100)
		titleLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 16, paddingLeft: 8, paddingBottom: 16, paddingRight: 8)
        durationLabel.anchor(top: titleLabel.bottomAnchor, left: leftAnchor, paddingLeft: 8, paddingBottom: 8)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure(texts: [String], colors: [UIColor]) {
		
		let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: "\(texts.first ?? "")", attributes: [NSAttributedString.Key.font: UIFont.Roboto(.bold, size: 13), NSAttributedString.Key.foregroundColor: colors[0] ])
		
		attributedText.append(NSMutableAttributedString(string: "\n \(texts[1])", attributes: [NSAttributedString.Key.font: UIFont.Roboto(.regular, size: 13), NSAttributedString.Key.foregroundColor: colors[1] ]))
		
		attributedText.append(NSMutableAttributedString(string: "\n \(texts[2])", attributes: [NSAttributedString.Key.font: UIFont.Roboto(.regular, size: 13), NSAttributedString.Key.foregroundColor: colors[2] ]))
		
		let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = 8
		attributedText.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedText.length))
		
		titleLabel.attributedText = attributedText
		titleLabel.numberOfLines = 0
		
		subtitleLabel.text = texts[3]
		subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = colors[3]
	}
	
	func configure(title: String, subtitle: String) {
        
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.font: UIFont.Roboto(.bold, size: 13), NSAttributedString.Key.foregroundColor: UIColor.black])
        
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        attributedText.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedText.length))
        
        if subtitle == .get(.sudahDiterima) {
            subtitleLabel.textColor = UIColor.secondary
        }
		
		
		titleLabel.attributedText = attributedText
		titleLabel.numberOfLines = 0
		
		subtitleLabel.text = subtitle
		subtitleLabel.textAlignment = .center
	}
}

