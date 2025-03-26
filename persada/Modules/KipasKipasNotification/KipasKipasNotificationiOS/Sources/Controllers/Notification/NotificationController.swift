//
//  NotificationController.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 19/03/24.
//

import UIKit
import KipasKipasShared
import KipasKipasNotification
import SendbirdChatSDK
import KipasKipasDirectMessage
import KipasKipasStory
import KipasKipasStoryiOS

extension UINavigationController {
    func hideHairline() {
        if let hairline = findHairlineImageViewUnder(navigationBar) {
            hairline.isHidden = true
        }
    }
    func restoreHairline() {
        if let hairline = findHairlineImageViewUnder(navigationBar) {
            hairline.isHidden = false
        }
    }
    func findHairlineImageViewUnder(_ view: UIView) -> UIImageView? {
        if view is UIImageView && view.bounds.size.height <= 1.0 {
            return view as? UIImageView
        }
        for subview in view.subviews {
            if let imageView = self.findHairlineImageViewUnder(subview) {
                return imageView
            }
        }
        return nil
    }
}

struct NotificationMenuItem {
    let menu: NotificationMenuSection
    var value: String
    var date: String
    var unreadCount: Int
    var isRead: Bool
    
    init(
        menu: NotificationMenuSection,
        value: String = "-",
        date: String = "",
        unreadCount: Int = 0,
        isRead: Bool = true
    ) {
        self.menu = menu
        self.value = value
        self.date = date
        self.unreadCount = unreadCount
        self.isRead = isRead
    }
}

enum NotificationMenuSection {
    case newFollowers, activities, systemNotifications, transaksi
    
    var id: Int {
        switch self {
        case .newFollowers: return 0
        case .activities: return 1
        case .systemNotifications: return 2
        case .transaksi: return 3
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .newFollowers: return UIImage.iconFollower
        case .activities: return UIImage.iconActivities
        case .systemNotifications: return UIImage.iconSystem
        case .transaksi: return UIImage.iconTransaction
        }
    }
    
    var title: String {
        switch self {
        case .newFollowers: return "New followers"
        case .activities: return "Activities"
        case .systemNotifications: return "System notifications"
        case .transaksi: return "Transaksi"
        }
    }
}

public class NotificationController: UITableViewController, NavigationAppearance {
    
    enum NotificationSection: Int, CaseIterable {
        case story = 0
        case menu = 1
        case directMessage = 2
        case userRecom = 3
    }
    
    var menuItems: [NotificationMenuItem] = [
        NotificationMenuItem(menu: .newFollowers, value: "Lihat followers baru disini."),
        NotificationMenuItem(menu: .activities, value: "Lihat notifikasi disini."),
        NotificationMenuItem(menu: .systemNotifications),
        NotificationMenuItem(menu: .transaksi)
    ] {
        didSet {
            menuItems = menuItems.sorted(by: { $0.menu.id < $1.menu.id })
            tableView.reloadData()
            refresh.endRefreshing()
        }
    }
    
    lazy var refresh: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.backgroundColor = .clear
        refresh.tintColor = .primary
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refresh
    }()
    
    private lazy var notificationTitleStack: UIStackView = {
        let stack = UIStackView()
        stack.backgroundColor = .clear
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        
        let title = UILabel()
        title.textColor = .black
        title.font = .systemFont(ofSize: 18, weight: .semibold)
        title.text = "Notification"
        
        stack.addArrangedSubview(title)
        
        let icon = UIImageView()
        icon.image = .iconDropdownCollapsed?.withTintColor(UIColor(hexString: "#777777"), renderingMode: .alwaysOriginal)
        icon.contentMode = .scaleAspectFill
        
        stack.addArrangedSubview(icon)
        
        let onTapStackGesture = UITapGestureRecognizer(target: self, action: #selector(handleOnTapNavigationTitleView))
        stack.isUserInteractionEnabled = true
        stack.addGestureRecognizer(onTapStackGesture)
        
        return stack
    }()
    
    let viewModel: NotificationViewModel
    var router: NotificationRouter?
    var activities: [NotificationActivitiesItem] = []
    var suggestionAccounts: [NotificationSuggestionAccountItem] = []
    var messages: [GroupChannel] = []
    var isAllMessageLoaded: Bool = false
    var data: StoryData?
    
    private var otherStories: [StoryFeed] = []
    
    public var loggedUserId = ""
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        navigationItem.titleView = notificationTitleStack
        navigationItem.backButtonTitle = ""
        setupTableView()
        configureRequest()
        bindObserver()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar(title: "", backIndicator: .iconChevronLeft)
        viewModel.fetchNotifUnread()
        viewModel.fetchStories(reset: true)
        updateStory()
    }
    
    public init(viewModel: NotificationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

private extension NotificationController {
    private func bindObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateNotificationBadgeCounter),
            name: Notification.Name("com.kipaskipas.updateNotificationCounterBadge"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(storyUploadDidProgressNotification),
            name: Notification.Name("storyUploadDidProgressNotification"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(storyUploadDidFailureNotification),
            name: Notification.Name("storyUploadDidFailureNotification"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(storyUploadDidCompleteNotification),
            name: Notification.Name("storyUploadDidCompleteNotification"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(storyDidBackFromViewing),
            name: Notification.Name("storyDidBackFromViewing"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateIsFollowFromFolowingFolower),
            name: Notification.Name("updateIsFollowFromFolowingFolower"),
            object: nil
        )
    }
    
    private func configureRequest() {
        viewModel.fetchStories(reset: true)
        viewModel.fetchActivities()
        viewModel.fetchSuggestionAccount()
        viewModel.fetchSystemNotif()
        viewModel.fetchLastTransaction()
        viewModel.fetchMessages()
    }
    
    @objc func handleRefresh() {
        viewModel.suggestAccountCurrentPage = 0
        configureRequest()
        viewModel.fetchNotifUnread()
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.registerCustomCell(NotificationStoryTableViewCell.self)
        tableView.registerNib(NotificationMenuTableViewCell.self)
        tableView.registerNib(NotificationDirectMessageTableViewCell.self)
        tableView.registerNib(NotificationUserRecomTableViewCell.self)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.refreshControl = refresh
        tableView.contentInset = .init(top: -8, left: 0, bottom: 0, right: 0)
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0.0
        } else {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNonzeroMagnitude))
            tableView.tableHeaderView = headerView
        }
    }
    
    func storyCell() -> NotificationStoryTableViewCell? {
        return tableView.cellForRow(at: IndexPath(row: 0, section: NotificationSection.story.rawValue)) as? NotificationStoryTableViewCell
    }
    
    func updateStory() {
        if router?.storyOnError() == true { // nil or false
            storyCell()?.listView.setUploadError()
            return
        }
        
        if router?.storyOnUpload() != true { // nil or true
            return
        }
        
        if let p = router?.storyUploadProgress() {
            storyCell()?.listView.setUploadProgress(to: p)
        }
    }
    
    @objc func handleOnTapNavigationTitleView() {
        router?.presentPreferences()
    }
    
    @objc func updateNotificationBadgeCounter() {
        viewModel.fetchNotifUnread()
        viewModel.fetchActivities()
    }
    
    @objc func storyUploadDidProgressNotification(_ notification: NSNotification) {
        if let p = notification.userInfo?["progress"] as? Double {
            DispatchQueue.main.async {
                guard let cell = self.storyCell() else { return }
                cell.listView.setUploadProgress(to: p)
            }
        }
    }
    
    @objc func storyUploadDidFailureNotification() {
        guard let cell = storyCell() else { return }
        
        cell.listView.setUploadError()
    }
    
    @objc func storyUploadDidCompleteNotification() {
        viewModel.fetchStories(reset: true)
        
        guard let cell = storyCell() else { return }
        
        cell.listView.setUploadDone()
    }
    
    @objc func storyDidBackFromViewing() {
        viewModel.fetchStories(reset: true)
    }
    
    @objc func updateIsFollowFromFolowingFolower() {
        viewModel.fetchStories(reset: true)
    }
}

extension NotificationController {
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = NotificationSection(rawValue: indexPath.section) else { return }
        
        switch section {
        case .story:
            break
        case .menu:
            switch menuItems[indexPath.row].menu {
            case .newFollowers:
                router?.navigateToNewFollowers()
            case .activities:
                router?.navigateToActivities()
            case .systemNotifications:
                router?.navigateToNotifSystem()
            case .transaksi:
                router?.navigateToTransactions()
            }
        case .directMessage:
            let patnerId = messages[indexPath.row].members.patner()?.userId ?? ""
            router?.navigateToConversation(id: patnerId)
        case .userRecom:
            break
        }
    }
}

extension NotificationController {
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return NotificationSection.allCases.count
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = NotificationSection(rawValue: section) else { return 0 }
        
        switch section {
        case .story:
            return 1
        case .menu:
            return menuItems.count
        case .directMessage:
            return messages.count
        case .userRecom:
            return suggestionAccounts.count
        }
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = NotificationSection(rawValue: indexPath.section) else { return UITableViewCell() }
        
        switch section {
        case .story:
            let cell: NotificationStoryTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.listView.delegate = self
            cell.listView.myPhoto = KKCache.credentials.readString(key: .userPhotoProfile)
            cell.listView.myStory = data?.myFeedStory
            cell.listView.stories = otherStories
            cell.selectionStyle = .none
            return cell
        case .menu:
            let cell: NotificationMenuTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            let item = menuItems[indexPath.row]
            cell.setupView(item: item)
            return cell
        case .directMessage:
            let cell: NotificationDirectMessageTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            let message = messages[indexPath.row]
            cell.configure(message)
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
        guard let section = NotificationSection(rawValue: section) else { return nil }
        let headerView = NotificationUserRecomHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 52))
        
        if messages.isEmpty {
            headerView.viewAllStackView.isHidden = true
        } else {
            headerView.viewAllStackView.isHidden = isAllMessageLoaded
        }
        
        headerView.frame = CGRect(
            x: 0,
            y: 0,
            width: tableView.bounds.width,
            height: headerView.viewAllStackView.isHidden ? 32 : 52
        )
        headerView.recomContainerStackView.isHidden = suggestionAccounts.isEmpty
        headerView.handleOnTapViewAll = { [weak self] in
            guard let self = self else { return }
            self.viewModel.loadMoreMessages()
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
        guard let section = NotificationSection(rawValue: section) else { return 0.0 }
        return section == .userRecom ? isAllMessageLoaded ? 32 : 52 : 0
    }
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == suggestionAccounts.count - 1 {
            guard viewModel.suggestAccountCurrentPage <= viewModel.suggestAccountTotalPage else { return }
            viewModel.suggestAccountCurrentPage += 1
            viewModel.fetchSuggestionAccount()
        }
    }
}

extension NotificationController: NotificationUserRecomTableViewCellDelegate {
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

extension NotificationController {
    func filterDuplicatesSuggestAccount(users: [NotificationSuggestionAccountItem]) -> [NotificationSuggestionAccountItem] {
        return users.reduce(into: [NotificationSuggestionAccountItem]()) { result, user in
            if !result.contains(where: { $0.id == user.id }) {
                result.append(user)
            }
        }
    }
}

extension NotificationController: NotificationViewModelDelegate {
    
    public func displayNotifUnread(item: NotificationUnreadItem) {
        
        menuItems[NotificationMenuSection.newFollowers.id].unreadCount = item.newFollower
        menuItems[NotificationMenuSection.newFollowers.id].isRead = item.activity <= 0
        menuItems[NotificationMenuSection.activities.id].unreadCount = item.activity
        menuItems[NotificationMenuSection.activities.id].isRead = item.activity <= 0
        
        if let index = menuItems.firstIndex(where: { $0.menu == .systemNotifications }) {
            menuItems[index].isRead = item.systemNotif == false
        }
        
        if let index = menuItems.firstIndex(where: { $0.menu == .transaksi }) {
            menuItems[index].isRead = item.transaction == false
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refresh.endRefreshing()
        }
    }
    
    public func displaySuggestionAccount(with items: [NotificationSuggestionAccountItem]) {
        
        if viewModel.suggestAccountCurrentPage <= 0 {
            suggestionAccounts = items
        } else {
            suggestionAccounts.append(contentsOf: items)
        }
        suggestionAccounts = filterDuplicatesSuggestAccount(users: suggestionAccounts)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refresh.endRefreshing()
        }
    }
    
    public func displayDirectMessage(with channels: [GroupChannel]) {
        
        if messages.isEmpty {
            isAllMessageLoaded = channels.count < 10
        } else {
            isAllMessageLoaded = messages.count == channels.count
        }
        
        messages = channels
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refresh.endRefreshing()
        }
    }
    
    public func displayErrorFetchDirectMessage(with error: SBError) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refresh.endRefreshing()
        }
    }
    
    public func displayLastActivity(with item: NotificationActivitiesItem?) {
        guard let activity = item else { return }
        
        menuItems[NotificationMenuSection.activities.id].value = activity.lastActivitySubtitle
    }
    
    public func displayLastSystemNotif(with item: NotificationSystemContent?) {
        guard let systemNotif = item else {
            menuItems.removeAll(where: { $0.menu == .systemNotifications })
            return
        }
        
        let menu = NotificationMenuItem(
            menu: .systemNotifications,
            value: systemNotif.lastSystemSubtitle,
            date: Date(timeIntervalSince1970: TimeInterval((systemNotif.createdAt) / 1000 )).timeAgoDisplay()
        )
        
        guard menuItems.contains(where: { $0.menu == .systemNotifications }) else {
            menuItems.append(menu)
            return
        }
        
        menuItems[NotificationMenuSection.systemNotifications.id].value = menu.value
        menuItems[NotificationMenuSection.systemNotifications.id].date = menu.date
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refresh.endRefreshing()
        }
    }
    
    public func displayLastTransaction(with item: NotificationTransactionItem?) {
        guard let transaction = item else {
            menuItems.removeAll(where: { $0.menu == .transaksi })
            return
        }
        
        let menu = NotificationMenuItem(
            menu: .transaksi,
            value: "\(transaction.orderType.uppercased()) update: \(transaction.status.uppercased())",
            date: transaction.createAt.toDateStringBy()
        )
        
        guard menuItems.contains(where: { $0.menu == .transaksi }) else {
            menuItems.append(menu)
            return
        }
        
        menuItems[NotificationMenuSection.transaksi.id].value = menu.value
        menuItems[NotificationMenuSection.transaksi.id].date = menu.date
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refresh.endRefreshing()
        }
    }
    
    public func displaySuccessUpdateFollowAccount(with id: String) {
        if let index = suggestionAccounts.firstIndex(where: { $0.id == id }) {
            suggestionAccounts[index].isFollow = !suggestionAccounts[index].isFollow
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
    }
    
    public func displayError(with message: String) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    public func displayNoInternetConnection() {
        
        DispatchQueue.main.async {
            self.refresh.endRefreshing()
            Toast.share.show(message: "No Internet Connection.")
        }
    }
    
    public func displayStories(with data: StoryData) {
        self.data = data
        
        if viewModel.storyPage == 0 {
            let stories = data.feedStoryAnotherAccounts?.content ?? []
            otherStories = stories
        } else {
            let stories = data.feedStoryAnotherAccounts?.content ?? []
            otherStories = unify(otherStories + stories)
        }
        
        tableView.reloadData()
    }
}

extension NotificationController: StoryListViewDelegate {
    public func didSelectedMyStory(by item: KipasKipasStory.StoryFeed) {
        guard let data = data else { return }
        router?.presentMyStory(item: item, data: data, otherStories: otherStories)
    }
    
    public func didSelectedLive() {
        router?.presentStoryLive()
    }
    
    public func didSelectedOtherStory(by item: KipasKipasStory.StoryFeed) {
        guard let data = data else { return }
        router?.presentOtherStory(item: item, data: data, otherStories: otherStories)
    }
    
    public func didAddStory() {
        router?.storyDidAdd()
    }
    
    public func didRetryUpload() {
        router?.storyDidRetry()
    }
    
    public func didReachLast() {
        // viewModel.fetchStories(reset: false)
    }
}

private extension NotificationSystemContent {
    var lastSystemSubtitle: String {
        let type = "\(types.uppercased()):"
        
        if types == "hotroom" {
            if title == "" {
                return "\(type) \(subTitle)"
            } else {
                return "\(type) \(subTitle)"
            }
        } else if types == "live" {
            if title == "" {
                return "\(type) \(subTitle)"
            } else {
                return "\(type) \(subTitle)"
            }
            
        } else if types == "account" {
            if title == "" {
                return "\(type) \(subTitle)"
            } else {
                return "\(type) \(subTitle)"
            }
        }
        
        return "Lihat notifikasi disini."
    }
}

private extension NotificationActivitiesItem {
    
    var lastActivitySubtitle: String {
        var targetTypeTitle: String {
            if targetType == "comment" || targetType == "commentSub" {
                return "komentar"
            } else if targetType == "feed" {
                return "post"
            }
            return ""
        }
        
        if actionType == "like" {
            if (other > 0) {
                return "\(firstName), \(secondName) and other \(other) menyukai \(targetTypeTitle) kamu"
            } else if (secondName != "") {
                return "\(firstName) dan \(secondName) menyukai \(targetTypeTitle) kamu"
            } else {
                return "\(firstName) menyukai \(targetTypeTitle) kamu"
            }
        } else if actionType == "comment" || actionType == "commentSub" {
            return "\(actionAccountName) Berkomentar: \(value)"
        } else if actionType == "mention" {
            if targetType == "feed" {
                return "\(actionAccountName) menyebut kamu dalam postingan"
            } else {
                return "\(actionAccountName) menyebut kamu dalam komentar: \(value)"
            }
        }
        
        return "Lihat notifikasi disini."
    }
}

func unify<T: Hashable>(_ array: [T]) -> [T] {
    var seen: Set<T> = []
    return array.filter { seen.insert($0).inserted }
}
