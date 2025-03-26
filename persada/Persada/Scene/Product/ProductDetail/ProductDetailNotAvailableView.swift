//
//  ProductDetailNotAvailableView.swift
//  KipasKipas
//
//  Created by PT.Koanba on 08/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import UIKit

class ProductDetailNotAvailableView : UIView {
    
    lazy var buttonLeft: UIButton = {
        let image = UIImage(named: .get(.iconBack))?.withRenderingMode(.alwaysOriginal)
        let button = UIButton(image: image!, target: self, action: #selector(onClickBackFunc))
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.clipsToBounds = true
        button.layer.masksToBounds = false
        button.backgroundColor = UIColor.black25
        return button
    }()
    
    lazy var imageBoxArchive : UIImageView = {
        let imageView = UIImageView(image: UIImage(named: .get(.iconArchiveBox)))
        return imageView
    }()
    
    lazy var textTitle : UILabel = {
        let label = UILabel(text: .get(.produkTidakTersedia), font: .Roboto(.regular, size: 14), textColor: .contentGrey, textAlignment: .center, numberOfLines: 0)
        return label
    }()
    
    lazy var textDesc : UILabel = {
        let label = UILabel(text: .get(.produkTidakTersediaDeskripsi), font: .Roboto(.regular, size: 12), textColor: .grey, textAlignment: .center, numberOfLines: 0)
        return label
    }()
    
    
    
    var onClickBack: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        [buttonLeft, imageBoxArchive, textTitle, textDesc].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.layer.masksToBounds = false
            addSubview($0)
        }
        buttonLeft.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        
        textDesc.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        textDesc.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        textDesc.anchor(left: leftAnchor, right: rightAnchor, paddingLeft: 50, paddingRight: 50)
        textTitle.anchor(left: leftAnchor, bottom: textDesc.topAnchor, right: rightAnchor, paddingLeft: 50, paddingRight: 50)
        imageBoxArchive.anchor(bottom: textTitle.topAnchor, width: 50, height: 50)
        imageBoxArchive.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func onClickBackFunc(){
        self.onClickBack?()
    }
}
