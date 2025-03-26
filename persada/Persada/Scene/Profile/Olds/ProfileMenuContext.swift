//
//  ProfileMenuContext.swift
//  Persada
//
//  Created by Muhammad Noor on 17/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import ContextMenu

private let cellId: String = "cellId"

class ProfileMenuContext: UITableViewController {
    
    let rows = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.reloadData()
        tableView.separatorColor = .clear
        tableView.alwaysBounceVertical = false
        tableView.layoutIfNeeded()
        preferredContentSize = CGSize(width: 200, height: tableView.contentSize.height)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        tableView.backgroundColor = .white
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.font = .boldSystemFont(ofSize: 17)
        cell.backgroundColor = .clear
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "Edit Profile"
            cell.textLabel?.textColor = .darkGray
        } else if (indexPath.row == 1) {
            cell.textLabel?.text = "Business Account"
            cell.textLabel?.textColor = .darkGray
        } else if (indexPath.row == 2) {
            cell.textLabel?.text = "Setting"
            cell.textLabel?.textColor = .darkGray
        } else if (indexPath.row == 3) {
            cell.textLabel?.text = "Log Out"
            cell.textLabel?.textColor = .darkGray
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            let editProfile = EditProfileViewController(mainView: EditProfileView(), dataSource: EditProfileModel.DataSource(id: getIdUser()))
            self.navigationController?.present(editProfile, animated: true, completion: nil)
        } else if indexPath.row == 3 {
            removeToken()

			self.view.window?.rootViewController?.dismiss(animated: false, completion: {
				NotificationCenter.default.post(name: .showOnboardingView, object: nil, userInfo: [:])
			})
        }
        
    }
}
