//
//  SelectCourierView.swift
//  KipasKipas
//
//  Created by Ibrohim Dasuqi on 29/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class SelectCourierView: UIView {

    var table = UITableView()
    
    convenience init() {
        self.init(frame: UIScreen.main.bounds)
        initView()
    }
    
    func initView() {
        backgroundColor = .white
        table.backgroundColor = .white
        
        addSubview(table)
        
        table.anchor(top: safeAreaLayoutGuide.topAnchor, left: safeAreaLayoutGuide.leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: safeAreaLayoutGuide.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20)
    }
}

