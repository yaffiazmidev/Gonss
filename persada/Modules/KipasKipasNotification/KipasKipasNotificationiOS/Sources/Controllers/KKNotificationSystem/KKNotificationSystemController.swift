//
//  KKNotificationSystemController.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 25/04/24.
//

import UIKit
import KipasKipasShared
import KipasKipasNotification

class KKNotificationSystemController: UIViewController, NavigationAppearance {
    
    private lazy var tableView: UITableView = UITableView()
    private(set) var refresh = UIRefreshControl()
    private(set) var redDotView = UIView()
    private let stackViewFilterContainer = UIStackView()
    private let socialStackView = UIStackView()
    private let liveStackView = UIStackView()
    private let accountStackView = UIStackView()
    private let lotteryStackView = UIStackView()
    private let imgViewAccount = UIImageView()
    private let viewSocial = UIView()
    private let viewLive = UIView()
    private let viewAccount = UIView()
    private let viewLottery = UIView()
    
    var showContentTypes: ((String) -> Void)?
    var showFeed: ((String) -> Void)?
    var showLive: ((String) -> Void)?
    var showLottery: ((String) -> Void)?
    
    var viewModel: IKKNotificationSystemViewModel
    var router: IKKNotificationSystemRouter?
    var notifications: [NotificationSystemContent] = []
    
    private var isLottery = false
    
    init(viewModel: IKKNotificationSystemViewModel) {
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
        viewModel.readNotif()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureNavigationBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension KKNotificationSystemController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: KKNotificationSystemTableViewCell = tableView.dequeueReusableCell(at: indexPath)
        let item = notifications[indexPath.row]
        cell.configure(with: item)
        cell.titleMenuIconImageView.isHidden = true
        cell.didSelectMenu = { [weak self] in
            guard let self = self else { return }
            let vc = NotificationSystemMuteController()
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: false)
        }
        cell.didSelectHeader = { [weak self] in
            self?.router?.navigateToNotificationContents(by: item.types)
        }
        
        cell.didClickViewMore = { [weak self] in
            guard let self = self else { return }
            
            if item.types == "undian" {
                self.showLottery?(item.targetId)
            } else {
                
            }
        }
        return cell
    }
}

extension KKNotificationSystemController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = notifications[indexPath.row]
        notifications[indexPath.row].isRead = true
        tableView.reloadData()
        viewModel.readNotification(by: item.id, types: item.types)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == notifications.count - 1 {
            guard viewModel.currentPage <= viewModel.totalPage else { return }
            viewModel.currentPage += 1
            isLottery ? viewModel.fetchLottery() : viewModel.fetchAllNotification()
        }
    }
}

extension KKNotificationSystemController: UIGestureRecognizerDelegate {}

extension KKNotificationSystemController: KKNotificationSystemViewModelDelegate {
    func displayReadNotification(id: String, types: String) {
        
        if let index = notifications.firstIndex(where: { $0.id == id }) {
            let item = notifications[index]
            switch item.types {
            case "account":
                break
            case "live":
                showLive?(item.targetId)
            case "hotroom":
                showFeed?(item.targetId)
            default:
                break
            }
        }
    }
    
    func displayNotifications(with contents: [NotificationSystemContent]) {
        view.backgroundColor = .whiteSnow
        stackViewFilterContainer.isHidden = false
        
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
            stackViewFilterContainer.isHidden = true
            view.backgroundColor = .white
            notifications = []
            tableView.reloadData()
            let emptyView = NoInternetConnectionView()
            emptyView.handleTapRetryButton = { [weak self] in
                guard let self = self else { return }
                self.handleRefresh()
            }
            tableView.backgroundView = emptyView
        } else {
            view.backgroundColor = .whiteSnow
            stackViewFilterContainer.isHidden = false
            tableView.deleteEmptyView()
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refresh.endRefreshing()
        }
    }
}

extension KKNotificationSystemController {
    func configureUI() {
        overrideUserInterfaceStyle = .light
        view.backgroundColor = .whiteSnow
        configureFilterType()
        configureCollectionView()
        
    }
    
    func configureFilterType() {
        stackViewFilterContainer.translatesAutoresizingMaskIntoConstraints = false
        stackViewFilterContainer.layoutMargins = UIEdgeInsets(top: 12, left: 28, bottom: 12, right: 28)
        stackViewFilterContainer.isLayoutMarginsRelativeArrangement = true
        stackViewFilterContainer.spacing = 12
        stackViewFilterContainer.alignment = .top
        stackViewFilterContainer.backgroundColor = .whiteSnow
        configureSocialStackView()
        configureLiveStackView()
        configureAccountUpdateStackView()
        configureLotteryStackView()
        
        let spacer = UIView()
        stackViewFilterContainer.addArrangedSubview(spacer)
        view.addSubview(stackViewFilterContainer)
        
        stackViewFilterContainer.anchors.top.equal(view.safeAreaLayoutGuide.anchors.top)
        stackViewFilterContainer.anchors.leading.equal(view.anchors.leading)
        stackViewFilterContainer.anchors.trailing.equal(view.anchors.trailing)
    }
    
    func configureSocialStackView() {
        
        viewSocial.translatesAutoresizingMaskIntoConstraints = false
        let imageSocial = UIImage.iconSosialSolidBlack
        let imgViewSocial = UIImageView(image: imageSocial)
        imgViewSocial.translatesAutoresizingMaskIntoConstraints = false
        imgViewSocial.contentMode = .scaleAspectFit
        
        viewSocial.backgroundColor = .whiteSmoke
        viewSocial.layer.cornerRadius = 46 / 2
        viewSocial.anchors.width.equal(46)
        viewSocial.anchors.height.equal(46)
        
        viewSocial.addSubview(imgViewSocial)
        imgViewSocial.anchors.width.equal(20)
        imgViewSocial.anchors.height.equal(22)
        imgViewSocial.anchors.centerX.equal(viewSocial.anchors.centerX)
        imgViewSocial.anchors.centerY.equal(viewSocial.anchors.centerY)
        
        let socialLabel = UILabel()
        socialLabel.text = "Sosial"
        socialLabel.font = .systemFont(ofSize: 12)
        socialLabel.textColor = .grey
        socialLabel.textAlignment = .center
        socialLabel.translatesAutoresizingMaskIntoConstraints = false
        socialStackView.addArrangedSubview(viewSocial)
        socialStackView.addArrangedSubview(socialLabel)
        socialStackView.axis = .vertical
        socialStackView.distribution = .fill
        socialStackView.alignment = .center
        socialStackView.spacing = 2
        stackViewFilterContainer.addArrangedSubview(socialStackView)
        
        socialStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.router?.navigateToNotificationContents(by: "hotroom")
        }
    }
    
    func configureLiveStackView() {
        viewLive.translatesAutoresizingMaskIntoConstraints = false
        let imageLive = UIImage.iconLiveSolidBlack
        let imgViewLive = UIImageView(image: imageLive)
        imgViewLive.contentMode = .scaleAspectFit
        
        viewLive.backgroundColor = .whiteSmoke
        viewLive.layer.cornerRadius = 46 / 2
        viewLive.anchors.width.equal(46)
        viewLive.anchors.height.equal(46)
        
        viewLive.addSubview(imgViewLive)
        imgViewLive.anchors.width.equal(20)
        imgViewLive.anchors.height.equal(22)
        imgViewLive.anchors.centerX.equal(viewLive.anchors.centerX)
        imgViewLive.anchors.centerY.equal(viewLive.anchors.centerY)
        
        
        let liveLabel = UILabel()
        liveLabel.text = "Live"
        liveLabel.textColor = .grey
        liveLabel.font = .systemFont(ofSize: 12)
        liveLabel.translatesAutoresizingMaskIntoConstraints = false
        liveStackView.addArrangedSubview(viewLive)
        liveStackView.addArrangedSubview(liveLabel)
        liveStackView.axis = .vertical
        liveStackView.distribution = .fill
        liveStackView.alignment = .center
        liveStackView.spacing = 2
        stackViewFilterContainer.addArrangedSubview(liveStackView)
        
        liveStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.router?.navigateToNotificationContents(by: "live")
        }
    }
    
    func configureAccountUpdateStackView() {
        
        viewAccount.translatesAutoresizingMaskIntoConstraints = false
        let imageAccount = UIImage.iconUpdateSolidBlack
        imgViewAccount.image = imageAccount
        imgViewAccount.contentMode = .scaleAspectFit
        
        viewAccount.backgroundColor = .whiteSmoke
        viewAccount.layer.cornerRadius = 46 / 2
        viewAccount.anchors.width.equal(46)
        viewAccount.anchors.height.equal(46)
        
        viewAccount.addSubview(imgViewAccount)
        imgViewAccount.anchors.width.equal(20)
        imgViewAccount.anchors.height.equal(22)
        imgViewAccount.anchors.centerX.equal(viewAccount.anchors.centerX)
        imgViewAccount.anchors.centerY.equal(viewAccount.anchors.centerY)
        
        let accountLabel = UILabel()
        accountLabel.text = "Akun \nUpdate"
        accountLabel.textColor = .grey
        accountLabel.numberOfLines = 2
        accountLabel.textAlignment = .center
        accountLabel.font = .systemFont(ofSize: 12)
        accountLabel.translatesAutoresizingMaskIntoConstraints = false
        accountStackView.addArrangedSubview(viewAccount)
        accountStackView.addArrangedSubview(accountLabel)
        accountStackView.axis = .vertical
        accountStackView.distribution = .fill
        accountStackView.alignment = .center
        accountStackView.spacing = 2
        stackViewFilterContainer.addArrangedSubview(accountStackView)
        
        accountStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.router?.navigateToNotificationContents(by: "account")
        }
        
        configureRedDoView()
    }
    
    func configureLotteryStackView() {
        viewLottery.translatesAutoresizingMaskIntoConstraints = false
        let imageLotteryConfiguration = UIImage.SymbolConfiguration(weight: .bold)
        let imageLottery = UIImage(systemName: "gift", withConfiguration: imageLotteryConfiguration)?.withTintColor(.black, renderingMode: .alwaysOriginal)
        let imgViewLottery = UIImageView(image: imageLottery)
        imgViewLottery.contentMode = .scaleAspectFit
        
        viewLottery.backgroundColor = .whiteSmoke
        viewLottery.layer.cornerRadius = 46 / 2
        viewLottery.anchors.width.equal(46)
        viewLottery.anchors.height.equal(46)
        
        viewLottery.addSubview(imgViewLottery)
        imgViewLottery.anchors.width.equal(20)
        imgViewLottery.anchors.height.equal(22)
        imgViewLottery.anchors.centerX.equal(viewLottery.anchors.centerX)
        imgViewLottery.anchors.centerY.equal(viewLottery.anchors.centerY)
        
        
        let lotteryLabel = UILabel()
        lotteryLabel.text = "Undian"
        lotteryLabel.textColor = .grey
        lotteryLabel.font = .systemFont(ofSize: 12)
        lotteryLabel.translatesAutoresizingMaskIntoConstraints = false
        lotteryStackView.addArrangedSubview(viewLottery)
        lotteryStackView.addArrangedSubview(lotteryLabel)
        lotteryStackView.axis = .vertical
        lotteryStackView.distribution = .fill
        lotteryStackView.alignment = .center
        lotteryStackView.spacing = 2
        stackViewFilterContainer.addArrangedSubview(lotteryStackView)
        
        lotteryStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.viewModel.currentPage = 0
            self.viewModel.totalPage = 0
            self.viewModel.fetchLottery()
        }
    }
    
    func configureCollectionView() {
        tableView = UITableView(frame: .zero)
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .whiteSnow
        tableView.showsVerticalScrollIndicator = false
        tableView.registerNib(KKNotificationSystemTableViewCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        configureRefresh()
        
        tableView.anchors.top.equal(stackViewFilterContainer.anchors.bottom)
        tableView.anchors.leading.equal(view.anchors.leading)
        tableView.anchors.trailing.equal(view.anchors.trailing)
        tableView.anchors.bottom.equal(view.anchors.bottom)
    }
    
    private func configureRedDoView() {
        viewAccount.addSubview(redDotView)
        redDotView.backgroundColor = .warning
        redDotView.anchors.top.equal(viewAccount.anchors.top, constant: 2)
        redDotView.anchors.trailing.equal(viewAccount.anchors.trailing, constant: -4)
        redDotView.anchors.height.equal(8)
        redDotView.anchors.width.equal(8)
        redDotView.isHidden = true
        redDotView.layer.cornerRadius = 4
    }
    
    func configureNavigationBar() {
        navigationController?.isNavigationBarHidden = false
        setupNavigationBar(title: "System Notification", backIndicator: .iconChevronLeft)
        
        let rightBarButtonItem = UIBarButtonItem(
            image: .iconGearThin,
            style: .plain,
            target: self,
            action: #selector(settingButtonPressed)
        )
        
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    @objc func backButtonPressed() {
        popViewController()
    }
    
    @objc func settingButtonPressed() {
        router?.navigateToSystemSetting()
    }
    
    private func configureRefresh() {
        tableView.refreshControl = refresh
        refresh.backgroundColor = .clear
        refresh.tintColor = .primary
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
    func configureRequest() {
        isLottery = false
        viewModel.currentPage = 0
        viewModel.totalPage = 0
        viewModel.fetchAllNotification()
    }
    
    @objc private func handleRefresh() {
        configureRequest()
    }
}
