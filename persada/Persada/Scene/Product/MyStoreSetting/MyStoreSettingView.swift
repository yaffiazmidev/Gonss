//
//  MyStoreSettingView.swift
//  KipasKipas
//
//  Created by IEN-Yasin-MacbookPro on 18/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class MyStoreSettingView: UIView {
    
    var table = UITableView()
    
    private enum ViewTrait {
        static let leftMargin: CGFloat = 10.0
        static let padding: CGFloat = 16.0
        static let iconSearch: String = String.get(.iconSearch)
        static let placeHolderSearch: String = String.get(.placeHolderSearchArchiveProduct)
    }
    
    private lazy var searchBar: UITextField = {
        var textfield = UITextField(frame: CGRect(x: 0, y: 0, width: 30, height: 40))
        textfield.clipsToBounds = true
        textfield.placeholder = ViewTrait.placeHolderSearch
        textfield.layer.borderWidth = 1
        textfield.layer.borderColor = UIColor.whiteSmoke.cgColor
        textfield.layer.cornerRadius = 8
        textfield.textColor = .grey
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.placeholder,
            NSAttributedString.Key.font : UIFont.Roboto(.medium, size: 12) // Note the !
        ]
        textfield.backgroundColor = UIColor.white
        
        textfield.attributedPlaceholder = NSAttributedString(string: ViewTrait.placeHolderSearch, attributes: attributes)
        textfield.rightViewMode = .always
        
        textfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 16))
        textfield.leftViewMode = .always
        
        let containerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width:50, height: self.frame.height))
        let imageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
        imageView.image = UIImage(named: ViewTrait.iconSearch)
        containerView.addSubview(imageView)
        imageView.center = containerView.center
        textfield.rightView = containerView
        
        
        return textfield
    }()
    
    convenience init() {
        self.init(frame: UIScreen.main.bounds)
        initView()
    }
    
    func initView() {
        backgroundColor = .white
        table.backgroundColor = .white
        
        addSubview(searchBar)
        addSubview(table)
        searchBar.anchor(top: safeAreaLayoutGuide.topAnchor, left: safeAreaLayoutGuide.leftAnchor, right: safeAreaLayoutGuide.rightAnchor, paddingTop: 8, paddingLeft: 16, paddingRight: 16, height: 40)
        
        table.anchor(top: searchBar.bottomAnchor, left: safeAreaLayoutGuide.leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: safeAreaLayoutGuide.rightAnchor, paddingTop: ViewTrait.padding)
        
    }
}
