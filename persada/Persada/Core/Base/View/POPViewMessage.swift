//
//  POPView.swift
//  KipasKipas
//
//  Created by Icon+ Gaenael on 27/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import UIKit

class POPViewMessage : UIView{
    
    private let vw_card     : UILabel  = UILabel()
    private let lbl_title   : UILabel  = UILabel()
    private let lbl_msg     : UILabel  = UILabel()
    private let btn_done    : UIButton = UIButton(type: .system)
    
    init() {
        super.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupView(){
        alpha = 0
        backgroundColor = UIColor.black.withAlphaComponent(0.2)
        vw_card.backgroundColor = .white
        vw_card.roundCorners(corners: .allCorners, radius: 8)
        vw_card.translatesAutoresizingMaskIntoConstraints = false
        lbl_title.translatesAutoresizingMaskIntoConstraints = false
        lbl_msg.translatesAutoresizingMaskIntoConstraints = false
        btn_done.translatesAutoresizingMaskIntoConstraints = false
        addSubview(vw_card)
        vw_card.addSubview(lbl_title)
        vw_card.addSubview(lbl_msg)
        vw_card.addSubview(btn_done)
        
        lbl_title.font            = .Roboto(.medium, size: 14)
        lbl_msg.font              = .Roboto(.medium, size: 14)
        btn_done.titleLabel?.font = .Roboto(.medium, size: 14)
        btn_done.onTap {
            self.dismissView()
        }
        
        lbl_title.textColor = .black
        lbl_msg.textColor   = .grey
        btn_done.tintColor  = .secondary
        
        lbl_title.numberOfLines = 1
        lbl_msg.numberOfLines = 0
        
        NSLayoutConstraint.activate([
            vw_card.centerYAnchor.constraint(equalTo: centerYAnchor),
            vw_card.centerXAnchor.constraint(equalTo: centerXAnchor),
            vw_card.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - (24*2)),
            lbl_title.leadingAnchor.constraint(equalTo: vw_card.leadingAnchor, constant: 24),
            lbl_title.topAnchor.constraint(equalTo: vw_card.topAnchor, constant: 24),
            lbl_title.trailingAnchor.constraint(equalTo: vw_card.trailingAnchor, constant: -24),
            lbl_msg.leadingAnchor.constraint(equalTo: vw_card.leadingAnchor, constant: 24),
            lbl_msg.topAnchor.constraint(equalTo: lbl_title.bottomAnchor, constant: 16),
            lbl_msg.trailingAnchor.constraint(equalTo: vw_card.trailingAnchor, constant: -24),
            btn_done.topAnchor.constraint(equalTo: lbl_msg.bottomAnchor, constant: 16),
            btn_done.trailingAnchor.constraint(equalTo: vw_card.trailingAnchor, constant: -24),
            btn_done.bottomAnchor.constraint(equalTo: vw_card.bottomAnchor, constant: -24)
        ])
        
        self.onTap {
            self.dismissView()
        }
    }
    private func dismissView(){
        self.fadeOut()
    }
    
    //MARK:- Public Function
    
    func addToSuperview(_ view: UIView){
        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
        setupView()
    }
    
    func setupText(_ title: String,
                   _ msg: String,
                   _ btn: String){
        lbl_title.text = title
        lbl_msg.text = msg
        btn_done.setTitle(btn, for: .normal)
    }
    
    func showView(){
        self.fadeIn()
    }
    
}
