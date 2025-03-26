//
//  ProfileMenuTableViewCell.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 10/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class ProfileMenuTableViewCell: UITableViewCell {
	
	
	let fullImage = UIImageView()
    let iconImage : UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()
    
    let title : UILabel = {
        let label = UILabel(font: .Roboto(.medium, size: 14), textColor: .contentGrey, textAlignment: .left, numberOfLines: 0)
        return label
    }()
    
    let redDot : UIImageView = {
        let image = UIImageView(image: UIImage(named: .get(.iconRedDot)))
        image.contentMode = .scaleAspectFit
        return image
    }()
    
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		// Configure the view for the selected state
		if selected {
			let view =  UIView()
			view.backgroundColor = .primaryLowTint
			self.selectedBackgroundView = view
		} else {
            self.backgroundColor = .white
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let view =  UIView()
                view.backgroundColor = .white
                self.selectedBackgroundView = view
            }
		}
	}
	
	func setup(){
        
        fullImage.accessibilityIdentifier = "fullImage-profilemenu"
        iconImage.accessibilityIdentifier = "iconImage-profilemenu"
        title.accessibilityIdentifier = "title-profilemenu"
        redDot.accessibilityIdentifier = "redDot-profilemenu"
        
		contentView.addSubview(fullImage)
        contentView.addSubview(iconImage)
        contentView.addSubview(title)
        contentView.addSubview(redDot)
		
		textLabel?.font = UIFont.Roboto(.medium, size: 14)
		textLabel?.textColor = .grey
		
        fullImage.anchor(left: leftAnchor, right: self.rightAnchor, paddingLeft: 30, paddingRight: 30)
        iconImage.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, paddingLeft: 16, paddingRight: 8, width: 24, height: 24)
        title.anchor(top: topAnchor, left: iconImage.rightAnchor, bottom: bottomAnchor, paddingLeft: 15)
        redDot.anchor(top: topAnchor, left: title.rightAnchor, bottom: bottomAnchor)
		fullImage.image = UIImage(named: "divider")
		fullImage.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
	}
}
