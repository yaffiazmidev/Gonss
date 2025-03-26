//
//  MyStoreSettingTableViewCell.swift
//  KipasKipas
//
//  Created by IEN-Yasin-MacbookPro on 20/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class MyStoreSettingTableViewCell: UITableViewCell {

    let iconImage : UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    let title : UILabel = {
        let label = UILabel(font: .Roboto(.medium, size:12), textColor: .contentGrey, textAlignment: .left, numberOfLines: 0)
        return label
    }()
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        if selected {
            let view =  UIView()
            view.backgroundColor = .primaryLowTint
            self.selectedBackgroundView = view
        } else {
            self.backgroundColor = .clear
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let view =  UIView()
                view.backgroundColor = .white
                self.selectedBackgroundView = view
            }
        }
    }
    
    func setup(){
        contentView.addSubview(iconImage)
        contentView.addSubview(title)
        
        textLabel?.font = UIFont.Roboto(.medium, size: 14)
        textLabel?.textColor = .grey
        
        iconImage.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, paddingLeft: 30, paddingRight: 30, width: 16, height: 16)
        title.anchor(top: topAnchor, left: iconImage.rightAnchor, bottom: bottomAnchor, paddingLeft: 15)
    }
}

struct MyStoreSettingData {
	let title: String
	let image: UIImage
	var isDisable: Bool
	
	static func fetchMyStoreSettingData() -> [MyStoreSettingData] {
		return [
			MyStoreSettingData(title: .get(.shopAddress), image: UIImage(named: .get(.iconStore))!, isDisable: false),
			MyStoreSettingData(title: .get(.productKurir), image: UIImage(named: .get(.iconCar))!, isDisable: true),
			MyStoreSettingData(title: .get(.archiveProducts), image: UIImage(named: .get(.iconFilter))!, isDisable: true)
		]
	}
}
