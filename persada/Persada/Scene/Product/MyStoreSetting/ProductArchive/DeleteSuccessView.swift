//
//  DeleteSuccessView.swift
//  KipasKipas
//
//  Created by PT.Koanba on 14/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
protocol DeleteSuccessViewDelegate where Self: UIViewController {
    func dismisTrashProduct()
}

class DeleteSuccessView: UIView {
    
    var delegate: DeleteSuccessViewDelegate?
    
    private lazy var trashView: UIView = {
        let view: UIView = UIView()
        
        let image: UIImageView = UIImageView(image: UIImage(named: String.get(.iconTrashGrey)))
        let tittleLabel = UILabel(text: String.get(.tittleTrashProduct), font: .Roboto(.medium, size: 14), textColor: .contentGrey, textAlignment: .center, numberOfLines: 1)
        let captionLabel = UILabel(text: String.get(.captionTrashPoduct), font:  .Roboto(.medium, size: 12), textColor: .grey, textAlignment: .center, numberOfLines: 1)
        
        view.addSubview(image)
        view.addSubview(tittleLabel)
        view.addSubview(captionLabel)
        
        image.translatesAutoresizingMaskIntoConstraints = false
        tittleLabel.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        tittleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        tittleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        
        image.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        image.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        image.anchor(bottom: tittleLabel.topAnchor, paddingBottom: 12)
        
        captionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        captionLabel.anchor(top: tittleLabel.bottomAnchor, paddingTop: 8)
        
        return view
    }()
    
    private lazy var backButton:UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(String.get(.backArchiveProduct), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .Roboto(.medium, size: 14)
        button.backgroundColor = .primary
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(didTapBack(_:)), for: .touchUpInside)
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        self.frame = UIScreen.main.bounds
        
        addSubview(trashView)
        addSubview(backButton)
        
        trashView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 32, paddingRight: 0)
        backButton.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingLeft: 20, paddingBottom: 20, paddingRight: 20, height: 48)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selectors
    @objc func didTapBack(_ sender: UIButton) {
        delegate?.dismisTrashProduct()
    }
}
