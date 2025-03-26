//
//  KKNotificationContentSystemController.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 25/04/24.
//

import UIKit
import KipasKipasShared
import KipasKipasNotification

class KKNotificationContentSystemController: UITableViewController, NavigationAppearance {
    
    private lazy var refresh: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.backgroundColor = .clear
        refresh.tintColor = .primary
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refresh
    }()
    
    let viewModel: KKNotificationContentSystemViewModel
    var notifications: [NotificationSystemContent] = []
    var showFeed: ((String) -> Void)?
    var showLive: ((String) -> Void)?
    
    init(viewModel: KKNotificationContentSystemViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureRequest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        configureNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureNavigationBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension KKNotificationContentSystemController {
    
    func configureUI() {
        overrideUserInterfaceStyle = .light
        view.backgroundColor = .whiteSnow
        configureTableView()
    }
    
    func configureTableView() {
        tableView = UITableView(frame: .zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = .init(top: 8, left: 0, bottom: 0, right: 0)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .whiteSnow
        tableView.showsVerticalScrollIndicator = false
        tableView.registerNib(KKNotificationSystemTableViewCell.self)
        tableView.refreshControl = refresh
    }
    func configureNavigationBar() {
        navigationController?.isNavigationBarHidden = false
        let title = viewModel.types == "hotroom" ? "Sosial" : viewModel.types == "live" ? "LIVE" : "Akun Update"
        setupNavigationBar(title: title, backIndicator: .iconChevronLeft)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    @objc func backButtonPressed() {
        popViewController()
    }
    
    @objc func handleRefresh() {
        configureRequest()
    }
    
    func configureRequest() {
        viewModel.currentPage = 0
        viewModel.totalPage = 0
        viewModel.fetchNotification()
    }
}

extension KKNotificationContentSystemController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: KKNotificationSystemTableViewCell = tableView.dequeueReusableCell(at: indexPath)
        cell.configure(with: notifications[indexPath.row])
        cell.headerContainerStackView.isHidden = true
        cell.titleMenuIconImageView.isHidden = false
        cell.redDotView.isHidden = true
        cell.didSelectMenu = { [weak self] in
            guard let self = self else { return }
            let vc = NotificationSystemMuteController()
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: false)
        }
        return cell
    }
}

extension KKNotificationContentSystemController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = notifications[indexPath.row]
        
        switch item.types {
        case "account":
            break
        case "live":
            showLive?(notifications[indexPath.row].targetId)
        case "hotroom":
            showFeed?(notifications[indexPath.row].targetId)
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == notifications.count - 1 {
            guard viewModel.currentPage <= viewModel.totalPage else { return }
            viewModel.currentPage += 1
            viewModel.fetchNotification()
        }
    }
}

extension KKNotificationContentSystemController: UIGestureRecognizerDelegate {}

extension KKNotificationContentSystemController: KKNotificationContentSystemViewModelDelegate {
    func displayNotifications(with contents: [NotificationSystemContent]) {
        view.backgroundColor = .whiteSnow
        if viewModel.currentPage > 0 {
            notifications.append(contentsOf: contents)
        } else {
            notifications = contents
        }
        
        if notifications.isEmpty {
            let emptyView = NoInternetConnectionView()
            emptyView.titleLabel.text = "Notifikasi Sistem."
            emptyView.subtitleLabel.text = "Notifikasi terkait sistem  akan ditampilkan disini."
            emptyView.retryImageView.image = .iconBoxOutlineGrey
            emptyView.retryButton.isHidden = true
            tableView.backgroundView = emptyView
        } else {
            tableView.deleteEmptyView()
        }
        
        tableView.reloadData()
        refresh.endRefreshing()
    }
    
    func displayError(with message: String) {
        if !ReachabilityNetwork.isConnectedToNetwork() {
            notifications = []
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
}
