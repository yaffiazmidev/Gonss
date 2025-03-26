//
//  OrderSalesTabAllView.swift
//  KipasKipas
//
//  Created by NOOR on 21/01/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import UIKit

protocol OrderSalesTabAllViewDelegate: UIView {
    var tableView: UITableView { get set }
}

class OrderSalesTabAllView: UIView, OrderSalesTabAllViewDelegate {
    
    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.register(UINib(nibName:
                                    "OrderTransactionWithoutButtonCell", bundle: nil), forCellReuseIdentifier: OrderTransactionWithoutButtonCell.className)
        tableView.register(UINib(nibName:
                                    "OrderTransactionWithButtonCell", bundle: nil), forCellReuseIdentifier: OrderTransactionWithButtonCell.className)
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
