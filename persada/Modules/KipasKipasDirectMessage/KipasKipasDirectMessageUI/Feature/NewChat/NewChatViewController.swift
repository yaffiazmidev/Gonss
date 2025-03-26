//
//  NewChatViewController.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 25/07/23.
//

import UIKit
import KipasKipasDirectMessage
import KipasKipasShared

protocol INewChatViewController: AnyObject {
    func displayFollowers(_ users: [RemoteFollowingContent])
    func displayError(_ message: String)
    func displaySearchingUser(_ users: [RemoteFollowingContent])
}

class NewChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var dimmedView: UIView!
    @IBOutlet weak var closeIconImageView: UIImageView!
    @IBOutlet weak var searchBarContainerStackView: UIStackView!
    @IBOutlet weak var searchBarTextField: UITextField!
    
    var interactor: INewChatInteractor!
    var completion: ((TXIMUser) -> Void)?
    
    private var followers: [RemoteFollowingContent] = [] {
        didSet {
            if followers.isEmpty {
                tableView.setEmptyView("Kamu belum mengikuti siapapun, gunakan\n kotak pencarian untuk memulai percakapan\n dengan pengguna lain.")
            } else {
                tableView.deleteEmptyView()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        setupView()
        setupTableView()
        animateDimmedView()
        registerTapGesture()
        
        interactor.isSearching = false
        tableView.setLoadingActivity()
        interactor.requestFollowing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dimmedView.alpha = 0
    }
    
    private func registerTapGesture() {
        dimmedView.onTap { [weak self] in
            guard let self = self else { return }
            self.handleTapDismiss()
        }
        
        closeIconImageView.onTap { [weak self] in
            guard let self = self else { return }
            self.handleTapDismiss()
        }
    }
    
    private func setupView() {
        searchBarTextField.delegate = self
        searchBarTextField.addTarget(self, action: #selector(didEditingChanged(_:)), for: .editingChanged)
        
        containerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        searchBarContainerStackView.layer.borderColor = UIColor(hexString: "#DDDDDD").cgColor
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.registerNib(NewChatTableViewCell.self)
        tableView.contentInset = UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0)
        tableView.keyboardDismissMode = .onDrag
    }
    
    @objc private func didEditingChanged(_ textField: UITextField) {
        searchBarTextField.addDelayedAction(with: 0.5) { [weak self] in
            guard let self = self else { return }
            
            guard let keyword = textField.text, !keyword.isEmpty else {
                self.interactor.isSearching = false
                self.followers = interactor.followings
                self.tableView.reloadData()
                return
            }
            
            self.interactor.isSearching = true
            self.tableView.setLoadingActivity()
            self.interactor.searchUser(by: keyword)
        }
    }
    
    private func animateDimmedView() {
        dimmedView.alpha = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.dimmedView.alpha = 1
            }
        }
    }
    
    @objc private func handleTapDismiss() {
        dimmedView.alpha = 0
        dismiss(animated: true, completion: nil)
    }
}

extension NewChatViewController: UITextFieldDelegate {}

extension NewChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let userId = self.followers[indexPath.row].id, !userId.isEmpty {
            let follow: RemoteFollowingContent = self.followers[indexPath.row]
            let user: TXIMUser = TXIMUser(userID: userId, userName: follow.name ?? "", faceURL: follow.photo ?? "", isVerified: follow.isVerified ?? false)
            completion?(user)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard (searchBarTextField.text?.isEmpty ?? true) else { return }
        interactor.loadMore(isLastIndex: indexPath.row == followers.count - 1)
    }
}

extension NewChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NewChatTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(followers[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.accessibilityIdentifier = "header-rankTableView"
        headerView.backgroundColor = .white
        headerView.layer.cornerRadius = 8
        headerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 20, y: 0, width: tableView.frame.width, height: 20)
        titleLabel.text = "Following"
        titleLabel.font = .Roboto(.medium, size: 12)
        titleLabel.textColor = .boulder
        titleLabel.textAlignment = .left
        headerView.addSubview(titleLabel)
        return headerView
    }
}

extension NewChatViewController: INewChatViewController {
    func displayFollowers(_ users: [RemoteFollowingContent]) {
        if interactor.requestPage == 0 {
            followers = users
        } else {
            followers.append(contentsOf: users)
        }
        
        if !interactor.isSearching {
            interactor.followings = followers
        }
        
        tableView.reloadData()
    }
    
    func displaySearchingUser(_ users: [RemoteFollowingContent]) {
        followers = users
        users.isEmpty ? tableView.setEmptyView("User tidak ditemukan, gunakan pencarian lain.") : tableView.deleteEmptyView()
        tableView.reloadData()
    }
    
    func displayError(_ message: String) {
        presentAlert(title: "Error", message: message)
    }
}
