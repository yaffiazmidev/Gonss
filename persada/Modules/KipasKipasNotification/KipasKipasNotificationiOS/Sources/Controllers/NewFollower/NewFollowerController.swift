//
//  NewFollowerController.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 21/03/24.
//

import UIKit
import KipasKipasNotification
import KipasKipasShared

class NewFollowerController: UITableViewController, NavigationAppearance {

    enum NotificationNewFollowerSection: Int, CaseIterable {
        case newFollower = 0
        case userRecom = 1
    }
    
    private let viewModel: NewFollowerViewModelViewModel
    private var newFollowers: [NotificationFollowersContent] = []
    private var suggestionAccounts: [NotificationSuggestionAccountItem] = []
    private var userRecomCount = 0
    private var isNoInternetConnection: Bool = false
    public var handleShowConversation: ((String) -> Void)?
    public var handleShowUserProfile: ((String) -> Void)?
    private var isHiddenViewAllNewFollowers = true
    
    private lazy var refresh: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.backgroundColor = .clear
        refresh.tintColor = .primary
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refresh
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        setupTableView()
        configureRequest()
    }
    
    init(viewModel: NewFollowerViewModelViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isNoInternetConnection = !ReachabilityNetwork.isConnectedToNetwork()
        setupNavigationBar(title: "New Followers", backIndicator: .iconChevronLeft)
        viewModel.readNotif()
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.registerNib(NewFollowerTableViewCell.self)
        tableView.registerNib(NewFollowerEmptyTableViewCell.self)
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
        viewModel.newFollowersCurrentPage = 0
        viewModel.newFollowersTotalPage = 0
        viewModel.suggestionAccountCurrentPage = 0
        viewModel.fetchNewFollowers()
        viewModel.fetchSuggestionAccount()
    }
    
    @objc func backButtonPressed() {
        popViewController()
    }
    
    @objc func handleRefresh() {
        configureRequest()
    }

}

extension NewFollowerController {
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return NotificationNewFollowerSection.allCases.count
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = NotificationNewFollowerSection(rawValue: section) else { return 0 }
        
        switch section {
        case .newFollower:
            guard !isNoInternetConnection else { return 0 }
            return newFollowers.isEmpty ? 1 : newFollowers.count
        case .userRecom:
            return suggestionAccounts.count
        }
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = NotificationNewFollowerSection(rawValue: indexPath.section) else { return UITableViewCell() }
        
        switch section {
        case .newFollower:
            guard !newFollowers.isEmpty else {
                let emptyCell: NewFollowerEmptyTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                return emptyCell
            }
            
            let cell: NewFollowerTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure(with: newFollowers[indexPath.row])
            cell.delegate = self
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
        guard let section = NotificationNewFollowerSection(rawValue: section) else { return nil }
        
        let headerView = NotificationUserRecomHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 52))
        headerView.viewAllStackView.isHidden = isHiddenViewAllNewFollowers
        headerView.recomContainerStackView.isHidden = suggestionAccounts.isEmpty
        
        headerView.handleOnTapViewAll = { [weak self] in
            guard let self = self else { return }
            if self.newFollowers.count <= 4 {
                self.newFollowers = self.viewModel.newFollowers
                self.isHiddenViewAllNewFollowers = self.newFollowers.count < 10
                self.tableView.reloadData()
            } else {
                self.viewModel.newFollowersCurrentPage += 1
                self.viewModel.fetchNewFollowers()
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
        guard ReachabilityNetwork.isConnectedToNetwork() else { return 0 }
        guard let section = NotificationNewFollowerSection(rawValue: section) else { return 0.0 }
        return section == .userRecom ? 52 : 0
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == suggestionAccounts.count - 1 {
            guard viewModel.suggestionAccountCurrentPage <= viewModel.suggestionAccountTotalPage else { return }
            viewModel.suggestionAccountCurrentPage += 1
            viewModel.fetchSuggestionAccount()
        }
    }
}

extension NewFollowerController: NewFollowerTableViewCellDelegate, NotificationUserRecomTableViewCellDelegate {
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

extension NewFollowerController {
    func filterDuplicatesSuggestAccount(users: [NotificationSuggestionAccountItem]) -> [NotificationSuggestionAccountItem] {
        return users.reduce(into: [NotificationSuggestionAccountItem]()) { result, user in
            if !result.contains(where: { $0.id == user.id }) {
                result.append(user)
            }
        }
    }
}

extension NewFollowerController: NewFollowerViewModelViewModelDelegate {
    func displaySuggestionAccount(with items: [NotificationSuggestionAccountItem]) {
        isNoInternetConnection = !ReachabilityNetwork.isConnectedToNetwork()
        
        if viewModel.suggestionAccountCurrentPage > 0 {
            suggestionAccounts.append(contentsOf: items)
        } else {
            suggestionAccounts = items
        }
        suggestionAccounts = filterDuplicatesSuggestAccount(users: suggestionAccounts)
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refresh.endRefreshing()
            self.tableView.deleteEmptyView()
        }
    }
    
    func displayNewFollowers(with items: [NotificationFollowersContent]) {
        isNoInternetConnection = !ReachabilityNetwork.isConnectedToNetwork()
        
        if viewModel.newFollowersCurrentPage > 0 {
            newFollowers.append(contentsOf: items)
            isHiddenViewAllNewFollowers = items.isEmpty
        } else {
            newFollowers = Array(items.prefix(4))
            
            if items.count > 4 {
                isHiddenViewAllNewFollowers = false
            } else {
                isHiddenViewAllNewFollowers = true
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refresh.endRefreshing()
            self.tableView.deleteEmptyView()
        }
    }
    
    func displayError(with message: String) {
        isNoInternetConnection = !ReachabilityNetwork.isConnectedToNetwork()
        refresh.endRefreshing()
        if isNoInternetConnection {
            newFollowers = []
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
    }
    
    func displaySuccessUpdateFollowAccount(with id: String) {
        if let index = newFollowers.firstIndex(where: { $0.id == id }) {
            newFollowers[index].isFollow = !newFollowers[index].isFollow
            viewModel.newFollowers[index].isFollow = newFollowers[index].isFollow
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
        
        if let index = suggestionAccounts.firstIndex(where: { $0.id == id }) {
            suggestionAccounts[index].isFollow = !suggestionAccounts[index].isFollow
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
    }
}
