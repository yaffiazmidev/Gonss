//
//  AnotherUserProfileOptionsView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 09/09/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import UIKit

class AnotherUserProfileOptionsView: UIView{
    
    lazy var blockView: UIStackView = buildItem(image: .get(.iconAnotherBlock), label: "Block")
    lazy var reportView: UIStackView = buildItem(image: .get(.iconAnotherReport), label: "Report")
    lazy var messageView: UIStackView = buildItem(image: .get(.iconAnotherMessage), label: "Message")
    
    lazy var cancelView: UIView = {
        let label = UILabel()
        label.text = "Cancel"
        label.font = UIFont(name: "AirbnbCerealApp-Medium", size: 12)
        label.textColor = .red
        label.textAlignment = .center
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 64))
        view.addSubview(label)
        label.anchor(width: 60, height: 16)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        return view
    }()
    
    lazy var divider: UIView = {
        let view = UIView()
        view.frame.size.width = UIScreen.main.bounds.width
        view.frame.size.height = 1
        view.backgroundColor = .whiteSnow
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let mainMenu = buildMenuItem([blockView, reportView, messageView])
        addSubview(mainMenu)
        addSubview(divider)
        addSubview(cancelView)
        
        mainMenu.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 30, paddingLeft: 20,  paddingRight: 20)
        divider.anchor(top: mainMenu.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 16, width: UIScreen.main.bounds.width, height: 1)
        cancelView.anchor(top: divider.bottomAnchor, left: leftAnchor, right: rightAnchor, width: UIScreen.main.bounds.width, height: 64)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildMenuItem(_ views: [UIStackView]) -> UIStackView {
        let menu = UIStackView(arrangedSubviews: views)
        menu.distribution = .fillEqually
        menu.alignment = .fill
        menu.axis = .horizontal
        return menu
    }
    
    private func buildItem(image: String, label: String) -> UIStackView{
        let itemImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        itemImage.image = UIImage(named: image)
        
        let itemLabel = UILabel()
        itemLabel.text = label
        itemLabel.font = UIFont(name: "AirbnbCerealApp-Medium", size: 12)
        itemLabel.textColor = .contentGrey
        
        let item = UIStackView()
        item.axis = .vertical
        item.distribution = .equalSpacing
        item.alignment = .center
        
        item.spacing = 8
        item.addArrangedSubviews([itemImage, itemLabel])
        item.translatesAutoresizingMaskIntoConstraints = false
        
        return item
    }
}
