//
//  SelectCourierTableViewCell.swift
//  KipasKipas
//
//  Created by Ibrohim Dasuqi on 29/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class SelectCourierTableViewCell: UITableViewCell {

    //lazy var iconImage : UIImageView = {
    //let image = UIImageView()
    //image.frame = CGRect(x: 0, y: 0, width: 72, height: 36)
    //image.contentMode = .scaleAspectFit
    //return image
    //}()
    
    //lazy var courierView: UIView = {
    //let view: UIView = UIView()
    //view.addSubview(iconImage)
    //iconImage.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant:0).isActive = true
    //iconImage.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
    //return view
    //}()
    
    lazy var selectCourierImage : UIImageView = {
        let image: UIImageView = UIImageView(image: UIImage(named: String.get(.iconCheckboxUncheck)))
        image.frame = CGRect(x: 0, y: 0, width: 16, height: 16)
        image.contentMode = .scaleAspectFit
        return image
    }()
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        
//        // Configure the view for the selected state
//        if selected {
//            let view =  UIView()
//            view.layer.cornerRadius = 8
//            view.backgroundColor = .primaryLowTint
//            self.selectedBackgroundView = view
//        } else {
//            self.backgroundColor = .white
//        }
//    }
    
    func setup(){
				backgroundColor = .white
				selectionStyle = .none
        //contentView.addSubview(iconImage)
        contentView.addSubview(selectCourierImage)
        
        //iconImage.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 12)
        selectCourierImage.anchor(right: rightAnchor, paddingRight: 22)
        selectCourierImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
}
