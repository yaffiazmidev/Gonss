//
//  NotificationActivityController.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 20/03/24.
//

import UIKit
import KipasKipasNotification
import KipasKipasShared

public class NotificationActivityController: UITableViewController, NavigationAppearance {
    
    private lazy var refresh: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.backgroundColor = .clear
        refresh.tintColor = .primary
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refresh
    }()
    
    enum NotificationActivitySection: Int, CaseIterable {
        case activities = 0
        case userRecom = 1
    }
    
    let viewModel: NotificationActivityViewModel
    var router: INotificationActivityRouter?
    var activities: [NotificationActivitiesItem] = []
    var suggestionAccounts: [NotificationSuggestionAccountItem] = []
    private var isNoInternetConnection: Bool = false
    private var isHiddenViewAllActivities = false
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        setupTableView()
        configureRequest()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar(title: "All activity", backIndicator: .iconChevronLeft)
    }
    
    init(viewModel: NotificationActivityViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.registerNib(NotificationActivityTableViewCell.self)
        tableView.registerNib(NotificationActivityEmptyTableViewCell.self)
        tableView.registerNib(NotificationUserRecomTableViewCell.self)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.refreshControl = refresh
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0.0
        } else {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
            tableView.tableHeaderView = headerView
        }
    }
    
    private func configureRequest() {
        viewModel.activities = []
        viewModel.activitiesCurrentPage = 0
        viewModel.suggestionAccountCurrentPage = 0
        viewModel.fetchActivities()
        viewModel.fetchSuggestionAccount()
    }
    
    @objc func backButtonPressed() {
        popViewController()
    }
    
    @objc func handleRefresh() {
        configureRequest()
    }
}

extension NotificationActivityController {
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return NotificationActivitySection.allCases.count
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = NotificationActivitySection(rawValue: section) else { return 0 }
        
        switch section {
        case .activities:
            guard !isNoInternetConnection else { return 0 }
            return activities.isEmpty ? 1 : activities.count
        case .userRecom:
            return suggestionAccounts.count
        }
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = NotificationActivitySection(rawValue: indexPath.section) else { return UITableViewCell() }
        
        switch section {
        case .activities:
            
            guard !activities.isEmpty else {
                let emptyCell: NotificationActivityEmptyTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                return emptyCell
            }
            
            let cell: NotificationActivityTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure(with: activities[indexPath.row])
            cell.handleNavigateToUserProfile = { [weak self] userId in
                guard let self = self else { return }
                self.router?.navigateToUserProfile(by: userId)
            }
            cell.handleNavigateToFeed = { [weak self] feedId in
                guard let self = self else { return }
                self.router?.presentSingleFeed(by: feedId)
            }
            return cell
        case .userRecom:
            let cell: NotificationUserRecomTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.delegate = self
            cell.configure(suggestionAccounts[indexPath.row])
            cell.handleTapCloseButton = { [weak self] in
                guard let self = self else { return }
                self.suggestionAccounts.remove(at: indexPath.row)
                self.tableView.reloadData()
            }
            return cell
        }
    }
    
    public override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard ReachabilityNetwork.isConnectedToNetwork() else { return nil }
        guard let section = NotificationActivitySection(rawValue: section) else { return nil }
        
        let headerView = NotificationUserRecomHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 52))
        headerView.viewAllStackView.isHidden = isHiddenViewAllActivities
        headerView.recomContainerStackView.isHidden = suggestionAccounts.isEmpty
        
        headerView.handleOnTapViewAll = { [weak self] in
            guard let self = self else { return }
            
            if self.activities.count <= 2 {
                self.activities = self.viewModel.activities
                self.isHiddenViewAllActivities = self.activities.count < 10
                self.tableView.reloadData()
                self.viewModel.activities = []
            } else {
                headerView.viewAllStackView.isHidden = true
                self.viewModel.activitiesCurrentPage += 1
                self.viewModel.fetchActivities()
            }
            
        }
        
        headerView.handleOnTapInfo = { [weak self] in
            guard let self = self else { return }
            let vc = NotificationSuggestionInfoController()
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: false)
        }
        
        return section == .userRecom ? headerView : nil
    }
    
    public override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard ReachabilityNetwork.isConnectedToNetwork() else { return 0.0 }
        guard let section = NotificationActivitySection(rawValue: section) else { return 0.0 }
        return section == .userRecom ? 52 : 0
    }
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == suggestionAccounts.count - 1 {
            guard viewModel.suggestionAccountCurrentPage <= viewModel.suggestionAccountTotalPage else { return }
            viewModel.suggestionAccountCurrentPage += 1
            viewModel.fetchSuggestionAccount()
        }
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = NotificationActivitySection(rawValue: indexPath.section) else { return }
        
        switch section {
        case .activities:
            guard !activities.isEmpty else { return }
            let item = activities[indexPath.row]
            activities[indexPath.row].isRead = true
            tableView.reloadData()
            
            if item.actionType == "like" {
                router?.navigateToDetailActivity(with: activities[indexPath.row])
            } else {
                router?.presentSingleFeed(by: item.feedId)
            }
            
        case .userRecom:
            break
        }
    }
}

extension NotificationActivityController: NotificationUserRecomTableViewCellDelegate {
    func didClickFollow(by id: String) {
        viewModel.followAccount(by: id)
    }
    
    func didClickFollowing(by id: String) {
        viewModel.unfollowAccount(by: id)
    }
    
    func didClickMessage(by id: String) {
        router?.navigateToConversation(id: id)
    }
    
    func navigateToUserProfile(by id: String) {
        router?.navigateToUserProfile(by: id)
    }
}

extension NotificationActivityController {
    func filterDuplicatesSuggestAccount(users: [NotificationSuggestionAccountItem]) -> [NotificationSuggestionAccountItem] {
        return users.reduce(into: [NotificationSuggestionAccountItem]()) { result, user in
            if !result.contains(where: { $0.id == user.id }) {
                result.append(user)
            }
        }
    }
}

extension NotificationActivityController: NotificationActivityViewModelDelegate {
    public func displayActivities(with items: [NotificationActivitiesItem]) {
        isNoInternetConnection = !ReachabilityNetwork.isConnectedToNetwork()
        
        if viewModel.activitiesCurrentPage <= 0 {
            activities = Array(items.prefix(2))
            if items.isEmpty {
                isHiddenViewAllActivities = true
            } else if items.count <= 2 {
                isHiddenViewAllActivities = true
            } else {
                isHiddenViewAllActivities = false
            }
            
        } else {
            activities.append(contentsOf: items)
            isHiddenViewAllActivities = items.isEmpty ? true : items.count < 10
//            if items.count < {
//                isHiddenViewAllActivities = false
//            } else {
//                isHiddenViewAllActivities = true
//            }
        }
        
        DispatchQueue.main.async {
            self.tableView.deleteEmptyView()
            self.tableView.reloadData()
            self.refresh.endRefreshing()
        }
        viewModel.readNotif()
    }
    
    public func displaySuggestionAccount(with items: [NotificationSuggestionAccountItem]) {
        if viewModel.suggestionAccountCurrentPage > 0 {
            suggestionAccounts.append(contentsOf: items)
        } else {
            suggestionAccounts = items
        }
        suggestionAccounts = filterDuplicatesSuggestAccount(users: suggestionAccounts)
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refresh.endRefreshing()
        }
    }
    
    public func displayError(with message: String) {
        isNoInternetConnection = !ReachabilityNetwork.isConnectedToNetwork()
        refresh.endRefreshing()
        if isNoInternetConnection {
            activities = []
            suggestionAccounts = []
            tableView.reloadData()
            let emptyView = NoInternetConnectionView()
            emptyView.handleTapRetryButton = { [weak self] in
                guard let self = self else { return }
                self.configureRequest()
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
        guard let index = suggestionAccounts.firstIndex(where: { $0.id == id }) else { return }
        suggestionAccounts[index].isFollow = !suggestionAccounts[index].isFollow
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
}
