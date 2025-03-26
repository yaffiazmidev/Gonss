//
//  NotificationDetailActivityController.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 05/04/24.
//

import UIKit
import KipasKipasNotification
import KipasKipasShared

class NotificationDetailActivityController: UITableViewController, NavigationAppearance {
    
    private lazy var refresh: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.backgroundColor = .clear
        refresh.tintColor = .primary
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refresh
    }()
    
    let viewModel: NotificationDetailActivityViewModel
    
    private var activityAccounts: [NotificationSuggestionAccountItem] = []
    
    public var handleShowConversation: ((String) -> Void)?
    public var handleShowUserProfile: ((String) -> Void)?
    public var handleShowSingleFeed: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        setupTableView()
        setNavTitle()
        
        viewModel.fetchActivitiesDetail()
        viewModel.readActivity(by: viewModel.activity.notificationid)
    }
    
    init(viewModel: NotificationDetailActivityViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar(title: "", backIndicator: .iconChevronLeft)
    }
    
    func setNavTitle() {
        if viewModel.activity.actionType == "like" {
            navigationItem.title = "Likes"
        } else if viewModel.activity.actionType == "comment" || viewModel.activity.actionType == "commentSub" {
            navigationItem.title = "Comment"
        } else if viewModel.activity.actionType == "mention" {
            navigationItem.title = "Mention"
            if viewModel.activity.targetType == "feed" {
//                subtitleLabel.text = "\(activity.firstName) menyebut kamu dalam postingan"
            } else {
//                subtitleLabel.text = "\(activity.firstName) menyebut kamu dalam komentar: \(activity.value)"
            }
        }
    }
    
    func setupTableView() {
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.registerNib(NotificationDetailActivityTableViewCell.self)
        tableView.registerNib(NotificationUserRecomTableViewCell.self)
        tableView.refreshControl = refresh
    }
    
    @objc func handleRefresh() {
        viewModel.activitiesCurrentPage = 0
        viewModel.activitiesTotalPage = 0
        viewModel.fetchActivitiesDetail()
    }
}

extension NotificationDetailActivityController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return !ReachabilityNetwork.isConnectedToNetwork() ? 0 : 1
        case 1:
            return activityAccounts.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell: NotificationDetailActivityTableViewCell = tableView.dequeueReusableCell(at: indexPath)
            cell.thumbnailImageView.loadImage(from: viewModel.activity.thumbnailUrl, placeholder: UIImage.emptyProfilePhoto)
            let actionType = viewModel.activity.actionType
            let isComment = viewModel.activity.targetType == "comment" || viewModel.activity.targetType == "commentSub"
            cell.valueCommentLabel.isHidden = actionType == "like" ? !isComment : false
            cell.valueCommentLabel.text = "\(viewModel.activity.targetAccountName):  \(viewModel.activity.value)"
            cell.didCLickThumbnail = { [weak self] in
                guard let self = self else { return }
                self.handleShowSingleFeed?(viewModel.activity.feedId)
            }
            return cell
        case 1:
            let cell: NotificationUserRecomTableViewCell = tableView.dequeueReusableCell(at: indexPath)
            cell.delegate = self
            cell.configureForActivityDetail(activityAccounts[indexPath.row])
            cell.closeIconContainerStackView.isHidden = true
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == activityAccounts.count - 1 {
            guard viewModel.activitiesCurrentPage <= viewModel.activitiesTotalPage else { return }
            viewModel.activitiesCurrentPage += 1
            viewModel.fetchActivitiesDetail()
        }
    }
}

extension NotificationDetailActivityController: NotificationUserRecomTableViewCellDelegate {
    func didClickFollow(by id: String) {
        viewModel.followAccount(by: id)
    }
    
    func didClickFollowing(by id: String) {
        viewModel.unfollowAccount(by: id)
    }
    
    func didClickMessage(by id: String) {
        handleShowConversation?(id)
    }
    
    func navigateToUserProfile(by id: String) {
        handleShowUserProfile?(id)
    }
}

extension NotificationDetailActivityController: NotificationDetailActivityViewModelDelegate {
    func displayActivities(with items: [KipasKipasNotification.NotificationSuggestionAccountItem]) {
        setNavTitle()
        if viewModel.activitiesCurrentPage > 0 {
            activityAccounts.append(contentsOf: items)
        } else {
            activityAccounts = items
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refresh.endRefreshing()
        }
    }
    
    public func displayError(with message: String) {
        setNavTitle()
        if !ReachabilityNetwork.isConnectedToNetwork() {
            activityAccounts = []
            tableView.reloadData()
            let emptyView = NoInternetConnectionView()
            emptyView.handleTapRetryButton = { [weak self] in
                guard let self = self else { return }
                self.handleRefresh()
            }
            tableView.backgroundView = emptyView
        } else {
            tableView.deleteEmptyView()
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refresh.endRefreshing()
        }
    }
    
    public func displaySuccessUpdateFollowAccount(with id: String) {
        guard let index = activityAccounts.firstIndex(where: { $0.id == id }) else { return }
        activityAccounts[index].isFollow = !activityAccounts[index].isFollow
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
}
