//
//  ProfilePictureOptionsView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 15/12/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

class ProfilePictureOptionsView: UIView {
    
    lazy var cancelView: UIView = {
        let label = UILabel()
        label.text = "Cancel"
        label.font = .Roboto(.medium, size: 14)
        label.textColor = .warning
        
        let view = UIView()
        view.addSubview(label)
        label.centerYTo(view.centerYAnchor)
        label.centerXTo(view.centerXAnchor)
        
        return view
    }()
    
    lazy var dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .whiteSmoke
        return view
    }()
    
    lazy var cameraView: UIStackView = {
        let icon = UIImageView()
        icon.image = UIImage(named: .get(.iconCameraButton))
        
        let label = UILabel()
        label.text = "Buka Kamera"
        label.font = .Roboto(.medium, size: 12)
        label.textColor = .grey
        
        let view = UIStackView(arrangedSubviews: [icon, label])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.alignment = .center
        //        view.distribution = .fill
        view.spacing = 8
        
        return view
    }()
    
    lazy var libraryView: UIStackView = {
        let icon = UIImageView()
        icon.image = UIImage(named: .get(.iconLibraryButton))
        
        let label = UILabel()
        label.text = "Upload Foto"
        label.font = .Roboto(.medium, size: 12)
        label.textColor = .grey
        
        let view = UIStackView(arrangedSubviews: [icon, label])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.alignment = .center
        //        view.distribution = .fill
        view.spacing = 8
        
        return view
    }()
    
    lazy var badgeView: UIStackView = {
        let icon = UIImageView()
        icon.image = UIImage(named: .get(.iconBadgeButton))
        
        let label = UILabel()
        label.text = "Badge Saya"
        label.font = .Roboto(.medium, size: 12)
        label.textColor = .grey
        
        let view = UIStackView(arrangedSubviews: [icon, label])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.alignment = .center
        //        view.distribution = .fill
        view.spacing = 8
        
        return view
    }()
    
    lazy var actionView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [cameraView, libraryView, badgeView])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .fill
        view.spacing = 0
        
        cameraView.anchor(width: 100, height: 62)
        libraryView.anchor(width: 100, height: 62)
        badgeView.anchor(width: 100, height: 62)
        
        return view
    }()
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(named: .get(.iconPersonWithCornerRadius))
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
