//
//  ProfilePostMenuContext.swift
//  Persada
//
//  Created by Muhammad Noor on 11/05/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import ContextMenu

private let cellId: String = "cellId"

class ProfilePostMenuContext: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.reloadData()
        tableView.alwaysBounceVertical = false
        tableView.tableHeaderView = UIView()
        tableView.separatorColor = .clear
        tableView.layoutIfNeeded()
        preferredContentSize = CGSize(width: 200, height: tableView.contentSize.height)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        tableView.backgroundColor = .white
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if getRole() == "ROLE_SELEB" {
            return 2
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.font = .boldSystemFont(ofSize: 17)
        cell.backgroundColor = .clear

        if getRole() == "ROLE_SELEB" {
            if indexPath.row == 0 {
                cell.textLabel?.text = "Add Product"
                cell.textLabel?.textColor = .darkGray

                return cell
            }
        }
        
        cell.textLabel?.text = "Add Post"
        cell.textLabel?.textColor = .darkGray

        return cell
    }
}
