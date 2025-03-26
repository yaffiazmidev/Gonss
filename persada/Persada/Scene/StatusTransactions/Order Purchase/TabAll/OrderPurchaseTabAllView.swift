//
//  OrderPurchaseTabAllView.swift
//  KipasKipas
//
//  Created by NOOR on 26/01/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import UIKit

protocol OrderPurchaseViewDelegate : UIView {
    var tableView : UITableView { get set }
}

class OrderPurchaseTabAllView : UIView, OrderPurchaseViewDelegate {
    
    
    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.register(UINib(nibName:
                                    "OrderTransactionPurchaseWithButtonCell", bundle: nil), forCellReuseIdentifier: "OrderTransactionPurchaseWithButtonCell")
        tableView.register(UINib(nibName:
                                    "OrderTransactionPurchaseWithoutButtonCell", bundle: nil), forCellReuseIdentifier: "OrderTransactionPurchaseWithoutButtonCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 138
        tableView.separatorStyle = .none
        return tableView
    }()
    
    lazy var emptyView: OrderEmptyView = OrderEmptyView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(tableView)
        tableView.fillSuperviewSafeAreaLayoutGuide(padding: UIEdgeInsets(horizontal: 12, vertical: 12))
        
        tableView.addSubview(emptyView)
        emptyView.anchor(top: tableView.topAnchor, left: tableView.leftAnchor, bottom: tableView.bottomAnchor, right: tableView.rightAnchor)
        emptyView.centerYTo(tableView.centerYAnchor)
        emptyView.centerXTo(tableView.centerXAnchor)
        emptyView.fillSuperview()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
