//
//  CustomTappedLabel.swift
//  KipasKipas
//
//  Created by movan on 18/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class SelectedCourierView: UIView {
    
    let selectCourierLabel = UILabel(font: .Roboto(.regular, size: 12), textColor: .placeholder, textAlignment: .left, numberOfLines: 0)
    
    let titleLabel = UILabel(font: .Roboto(.bold, size: 12), textColor: .black, textAlignment: .left, numberOfLines: 0)
    
    let durationLabel = UILabel(font: .Roboto(.regular, size: 10), textColor: .black, textAlignment: .left, numberOfLines: 0)
    
    let subtitleLabel = UILabel(font: .Roboto(.regular, size: 12), textColor: .black, textAlignment: .left, numberOfLines: 0)
    
    private lazy var loading: UIActivityIndicatorView = {
        let loading = UIActivityIndicatorView(style: .medium)
        loading.hidesWhenStopped = true
        loading.color = .primary
        addSubview(loading)
        return loading
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.borderColor = UIColor.black25.cgColor
        layer.cornerRadius = 8
        layer.borderWidth = 0.5

        
        let button = UIButton(type: .custom)
        let image = UIImage(named: String.get(.iconRightGray))?.withRenderingMode(.alwaysOriginal)
        let imageView = UIImageView(image: image, contentMode: .scaleAspectFit)
        
        [selectCourierLabel, titleLabel, subtitleLabel, durationLabel, imageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        loading.centerInSuperview()
        subtitleLabel.anchor(top: topAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingBottom: 8, paddingRight: 0, width: 100)
        selectCourierLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8)
        titleLabel.anchor(top: nil, left: leftAnchor, bottom: centerYAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 2, paddingRight: 8)
        durationLabel.anchor(top: centerYAnchor, left: leftAnchor, bottom: nil, paddingTop: 2, paddingLeft: 8)
        
        imageView.anchor(top: topAnchor, left: nil,bottom: bottomAnchor, right: rightAnchor, paddingRight: 8, height: 25)
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
    
    func startLoading() {
        self.isUserInteractionEnabled = false
        loading.startAnimating()
    }
    
    func stopLoading() {
        self.isUserInteractionEnabled = true
        loading.stopAnimating()
    }
}

