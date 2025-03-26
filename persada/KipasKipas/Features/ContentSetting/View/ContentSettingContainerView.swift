//
//  ContentSettingContainerView.swift
//  KipasKipas
//
//  Created by DENAZMI on 15/01/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import UIKit
import FeedCleeps

enum ContentSettingMenu: CaseIterable {
    case report
    case notInterested
    case saveVideo
    case savePhoto
    case clearDisplay
    case playbackSpeed
    case pictureInPicture
    case deletePost
    
    var item: ContentSettingItem {
        switch self {
        case .report:
            return ContentSettingItem(icon: UIImage(named: "ic_flag_solid_black"), title: "Report")
        case .notInterested:
            return ContentSettingItem(icon: UIImage(named: "ic_not_interested_solid_black"), title: "Not interested")
        case .saveVideo:
            return ContentSettingItem(icon: UIImage(named: "ic_download_solid_black"), title: "Save video")
        case .savePhoto:
            return ContentSettingItem(icon: UIImage(named: "ic_download_solid_black"), title: "Save photo")
        case .clearDisplay:
            return ContentSettingItem(icon: UIImage(named: "ic_clear_solid_black"), title: "Clear display")
        case .playbackSpeed:
            return ContentSettingItem(icon: UIImage(named: "ic_speed_solid_black"), title: "Playback speed")
        case .pictureInPicture:
            return ContentSettingItem(icon: UIImage(named: "ic_pip_solid_black"), title: "Picture-in-Picture")
        case .deletePost:
            return ContentSettingItem(icon: UIImage(named: "ic_trashCan_solid_black"), title: "Delete")
        }
    }
}

struct ContentSettingItem {
    let icon: UIImage?
    let title: String
}

protocol ContentSettingContainerViewDelegate: AnyObject {
    func didClickCopyLink()
    func didClickSettingItem(with menu: ContentSettingMenu)
    func didClickRepost()
    func didClickMoreFollowing()
    func didRefresh()
    func didClickSendContentTo(userId: String)
}

class ContentSettingContainerView: UIView {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var copyLinkImageView: UIImageView!
    @IBOutlet weak var shareToIGImageView: UIImageView!
    @IBOutlet weak var shareToMessagerImageView: UIImageView!
    @IBOutlet weak var emptyFollowingContainerStackView: UIStackView!
    @IBOutlet weak var shareToWhatsappImageView: UIImageView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl(backgroundColor: .white)
        refresh.tintColor = .primary
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refresh
    }()
    
    weak var delegate: ContentSettingContainerViewDelegate?
    var settingItems: [ContentSettingMenu] = []
    var followings: [RemoteFollowingContent] = []
    var alreadySendToUsers: [RemoteFollowingContent] = []
    let longTitleItems: [ContentSettingMenu] = [.notInterested, .clearDisplay, .playbackSpeed, .pictureInPicture , .savePhoto, .saveVideo]
    
    enum ContentShareSection: Int, CaseIterable {
        case repost     = 0
        case following  = 1
        case more       = 2
    }
    
    var feed: FeedItem? {
        didSet {
            settingItems.append(feed?.account?.id ?? "" == getIdUser() ? .deletePost : .report)
            
            let mediaType = feed?.post?.medias?.first?.type
            
            if mediaType == "image" {
                settingItems.append(.savePhoto)
            } else if mediaType == "video" {
                settingItems.append(.saveVideo)
            }
            
            if settingItems.contains(where: { longTitleItems.contains($0) }) {
                collectionViewHeightConstraint.constant = 89.0
                containerView.layoutIfNeeded()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubViews()
        setupComponent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubViews()
    }
    
    private func initSubViews() {
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: Bundle(for: type(of: self)))
        nib.instantiate(withOwner: self, options: nil)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        addConstraints()
    }
    
    func setupComponent() {
        setupTableView()
        setupCollectionView()
        checkAlreadyInstallShareApps()
        
        copyLinkImageView.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didClickCopyLink()
        }
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: containerView.topAnchor),
            bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerXibCell(ContentSettingSection0ItemCell.self)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.layer.cornerRadius = 8
        tableView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        tableView.refreshControl = refreshControl
        tableView.registerNibCell(ContentSettingSection2Cell.self)
        tableView.registerNibCell(ContentSettingFollowingTableViewCell.self)
    }
    
    private func checkAlreadyInstallShareApps() {
        let isAlreadyInstallInstagram = UIApplication.shared.canOpenURL(URL(string: "instagram://sharesheet")!)
        let isAlreadyInstallWhatsapp = UIApplication.shared.canOpenURL(URL(string: "whatsapp://app")!)
        shareToIGImageView.isHidden = !isAlreadyInstallInstagram
        shareToWhatsappImageView.isHidden = !isAlreadyInstallWhatsapp
    }
    
    @objc private func handleRefresh() {
        delegate?.didRefresh()
    }
}

extension ContentSettingContainerView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = ContentShareSection(rawValue: indexPath.section) else { return }
        
        switch section {
        case .repost: 
            delegate?.didClickRepost()
        case .following:
            delegate?.didClickSendContentTo(userId: followings[indexPath.row].id ?? "")
        case .more: 
            delegate?.didClickMoreFollowing()
        }
    }
}

extension ContentSettingContainerView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return ContentShareSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = ContentShareSection(rawValue: section) else { return 0 }
        
        switch section {
        case .repost: return 0
        case .following: return followings.count
        case .more: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = ContentShareSection(rawValue: indexPath.section) else { return UITableViewCell() }
        
        switch section {
        case .repost:
            let cell: ContentSettingSection2Cell = tableView.dequeueReusableCell(for: indexPath)
            cell.setupView(iconImage: UIImage(named: "ic_loop"), title: "Repost")
            return cell
        case .following:
            let cell: ContentSettingFollowingTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            let item = followings[indexPath.row]
            cell.setupView(item: item)
            cell.alreadySendToUser = alreadySendToUsers.contains(where: { $0.id == item.id })
            return cell
        case .more:
            let cell: ContentSettingSection2Cell = tableView.dequeueReusableCell(for: indexPath)
            cell.setupView(iconImage: UIImage(named: "ic_search"), title: "More friends")
            return cell
        }
    }
}

extension ContentSettingContainerView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settingItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ContentSettingSection0ItemCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.titleLabel.text = settingItems[indexPath.item].item.title
        cell.iconImageView.image = settingItems[indexPath.item].item.icon
        return cell
    }
}

extension ContentSettingContainerView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didClickSettingItem(with: settingItems[indexPath.item])
    }
}

extension ContentSettingContainerView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = settingItems.contains(where: { longTitleItems.contains($0) }) ? 89 : 77
        return CGSize(width: collectionView.frame.width / 6, height: height)
    }
}
