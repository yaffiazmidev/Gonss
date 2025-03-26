//
//  KKCameraPreviewView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 28/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class KKCameraPreviewView: UIView{
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
    lazy var closeView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.12)
        view.layer.cornerRadius = 21
        
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFit
        icon.image = UIImage(named: .get(.iconCameraClose))
        
        view.addSubview(icon)
        view.translatesAutoresizingMaskIntoConstraints = false
        icon.anchor(width: 32, height: 32)
        icon.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        return view
    }()
    
    lazy var doneLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "Selesai"
        label.textAlignment = .center
        label.font = .roboto(.black, size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        
        addSubviews([imageView, closeView, doneLabel])
        closeView.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, paddingTop: 12, paddingLeft: 12, width: 42, height: 42)
        imageView.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: doneLabel.topAnchor, right: rightAnchor, paddingBottom: 32)
        doneLabel.anchor(bottom: safeAreaLayoutGuide.bottomAnchor, paddingBottom: 16, width: 64, height: 42)
        doneLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
