//
//  PaidDirectMessageRankView.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 05/08/23.
//

import UIKit
import KipasKipasDirectMessage

protocol PaidDirectMessageRankViewDelegate: AnyObject {
    func didSelectUser(id: String)
}

class PaidDirectMessageRankView: UIView {

    @IBOutlet weak var top1ContainerView: UIView!
    @IBOutlet weak var top2ContainerView: UIView!
    @IBOutlet weak var top3ContainerView: UIView!
    
    @IBOutlet weak var top1ProfileImageView: UIImageView!
    @IBOutlet weak var top2ProfileImageView: UIImageView!
    @IBOutlet weak var top3ProfileImageView: UIImageView!
    
    @IBOutlet weak var top1UsernameLabel: UILabel!
    @IBOutlet weak var top2UsernameLabel: UILabel!
    @IBOutlet weak var top3UsernameLabel: UILabel!
    
    @IBOutlet weak var top1ChatReplyCountLabel: UILabel!
    @IBOutlet weak var top2ChatReplyCountLabel: UILabel!
    @IBOutlet weak var top3ChatReplyCountLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topRankContainerStackView: UIStackView!
    
    weak var delegate: PaidDirectMessageRankViewDelegate?
    
    var users: [RemoteChatRankData] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var topUsers: [RemoteChatRankData] = [] {
        didSet {
            setupUserTopRank(users: topUsers)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTableView()
        handleOnTap()
    }
    
    private func handleOnTap() {
        top1ContainerView.onTap { [weak self] in
            guard let self = self else { return }
            
            guard !self.topUsers.isEmpty else { return }
            self.delegate?.didSelectUser(id: self.topUsers[0].accountId ?? "")
        }
        
        top2ContainerView.onTap { [weak self] in
            guard let self = self else { return }
            
            guard self.topUsers.count >= 2 else { return }
            self.delegate?.didSelectUser(id: self.topUsers[1].accountId ?? "")
        }
        
        top3ContainerView.onTap { [weak self] in
            guard let self = self else { return }
            
            guard self.topUsers.count >= 3 else { return }
            self.delegate?.didSelectUser(id: self.topUsers[2].accountId ?? "")
        }
    }
    
    private func setupUserTopRank(users: [RemoteChatRankData]) {
        guard users.count >= 3 else {
            topRankContainerStackView.isHidden = true
            return
        }
        
        topRankContainerStackView.isHidden = false
        
        top1ProfileImageView.loadImage(from: users[0].photo)
        top2ProfileImageView.loadImage(from: users[1].photo)
        top3ProfileImageView.loadImage(from: users[2].photo)
        
        top1UsernameLabel.text = users[0].name ?? ""
        top2UsernameLabel.text = users[1].name ?? ""
        top3UsernameLabel.text = users[2].name ?? ""
        
        top1ChatReplyCountLabel.text = "\(users[0].chatReplyCount ?? 0) dibalas"
        top2ChatReplyCountLabel.text = "\(users[1].chatReplyCount ?? 0) dibalas"
        top3ChatReplyCountLabel.text = "\(users[2].chatReplyCount ?? 0) dibalas"
    }

    private func setupTableView() {
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.registerNib(PaidDirectMessageRankTableViewCell.self)
    }
}

extension PaidDirectMessageRankView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard users[indexPath.row].accountId ?? "" != UserManager.shared.accountId else {
            return
        }
        
        delegate?.didSelectUser(id: users[indexPath.row].accountId ?? "")
    }
}

extension PaidDirectMessageRankView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PaidDirectMessageRankTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(user: users[indexPath.row])
        cell.rankNumberLabel.text = "\(indexPath.row + 4)"
        return cell
    }
}
