import UIKit
import KipasKipasShared
import KipasKipasNotification

public class NotificationSystemController: UIViewController {
    
    private lazy var collectionView: UICollectionView = UICollectionView()
    private(set) var refresh = UIRefreshControl()
    private(set) var redDotView = UIView()
    private let stackViewFilterContainer = UIStackView()
    private let socialStackView = UIStackView()
    private let liveStackView = UIStackView()
    private let accountStackView = UIStackView()
    private let imgViewAccount = UIImageView()
    private var emptyMessage: String?
    private var pagingController: NotificationSystemPagingController?
    private let showContentTypes: ((String) -> Void)
    private let showFeed: ((String) -> Void)
    private let viewSocial = UIView()
    private let viewLive = UIView()
    private let viewAccount = UIView()
    private lazy var dataSource: EmptyableDiffableDataSource<Int, CellController> = {
        return .init(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, controller in
                return controller.view(collectionView, forItemAt: indexPath)
            },
            emptyStateView: EmptyView(message: emptyMessage ?? "")
        )
    }()
    
    
    var onLoad: ((_ page: Int, _ size: Int,_ types: String) -> Void)?
    var unread: ((_ isRead: Bool, _ types: String) -> Void)?
    
    public init(
        pagingController: NotificationSystemPagingController,
        emptyMessage: String,
        showContentTypes: @escaping ((String) -> Void),
        showFeed: @escaping ((String) -> Void)
    ) {
        self.showContentTypes = showContentTypes
        self.showFeed = showFeed
        super.init(nibName: nil, bundle: nil)
        self.pagingController = pagingController
        self.emptyMessage = emptyMessage
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureRequest()
    }
    
    private func configureRefresh() {
        collectionView.refreshControl = refresh
        refresh.backgroundColor = .clear
        refresh.tintColor = .primary
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
    func configureRequest() {
        onLoad?(0, 10, "all")
        unread?(true, "account")
    }
    
    @objc private func handleRefresh() {
        configureRequest()
    }
    
    public func set(_ items: [CellController]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
        snapshot.deleteAllItems()
        snapshot.appendSections([0])
        snapshot.appendItems(items)
        dataSource.apply(snapshot)
    }
    
    public func append(_ newItems: [CellController]) {
        var snapshot = dataSource.snapshot()
        // TODO: Remove this
        if snapshot.numberOfSections == 0 {
            snapshot.appendSections([0])
        }
        snapshot.appendItems(newItems, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    
    func cell(at indexPath: IndexPath) -> CellController? {
        return dataSource.itemIdentifier(for: indexPath)
    }
}

// MARK: UI

private extension NotificationSystemController {
    func configureUI() {
        view.backgroundColor = .whiteSnow
        configureFilterType()
        configureCollectionView()
        configureNavigationBar()
    }
    
    func configureFilterType() {
        stackViewFilterContainer.translatesAutoresizingMaskIntoConstraints = false
        stackViewFilterContainer.layoutMargins = UIEdgeInsets(top: 12, left: 28, bottom: 12, right: 28)
        stackViewFilterContainer.isLayoutMarginsRelativeArrangement = true
        stackViewFilterContainer.spacing = 12
        stackViewFilterContainer.alignment = .top
        configureSocialStackView()
        configureLiveStackView()
        configureAccountUpdateStackView()
        
        let spacer = UIView()
        stackViewFilterContainer.addArrangedSubview(spacer)
        view.addSubview(stackViewFilterContainer)
        
        stackViewFilterContainer.anchors.top.equal(view.safeAreaLayoutGuide.anchors.top)
        stackViewFilterContainer.anchors.leading.equal(view.anchors.leading)
        stackViewFilterContainer.anchors.trailing.equal(view.anchors.trailing)
    }
    
    func configureSocialStackView() {
        
        viewSocial.translatesAutoresizingMaskIntoConstraints = false
        let imageSocial = UIImage.iconNewsPaperGray
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
            
            self.showContentTypes("hotroom")
        }
    }
    
    func configureLiveStackView() {
        viewLive.translatesAutoresizingMaskIntoConstraints = false
        let imageLive = UIImage.iconVideo
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
            
            self.showContentTypes("live")
        }
    }
    
    func configureAccountUpdateStackView() {
        
        viewAccount.translatesAutoresizingMaskIntoConstraints = false
        let imageAccount = UIImage.iconArrowUpGray
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
            
            self.showContentTypes("account")
        }
        
        configureRedDoView()
    }
    
    func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .whiteSnow
        collectionView.showsVerticalScrollIndicator = false
        collectionView.registerCell(NotificationSystemItemCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self.dataSource
        collectionView.allowsSelection = true
        configureRefresh()
        
        collectionView.anchors.top.equal(stackViewFilterContainer.anchors.bottom)
        collectionView.anchors.leading.equal(view.anchors.leading)
        collectionView.anchors.trailing.equal(view.anchors.trailing)
        collectionView.anchors.bottom.equal(view.anchors.bottom)
    }
    
    private func configureRedDoView() {
        viewAccount.addSubview(redDotView)
        redDotView.backgroundColor = .warning
        redDotView.anchors.top.equal(viewAccount.anchors.top, constant: 5)
        redDotView.anchors.trailing.equal(viewAccount.anchors.trailing, constant: -5)
        redDotView.anchors.height.equal(8)
        redDotView.anchors.width.equal(8)
        redDotView.isHidden = true
        redDotView.layer.cornerRadius = 4
    }
    
    func configureNavigationBar() {
        navigationItem.title = "Notifikasi Sistem"
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationController?.navigationBar.tintColor = .black
        
        let leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonPressed)
        )
        
        let rightBarButtonItem = UIBarButtonItem(
            image: .iconGearThin,
            style: .plain,
            target: self,
            action: #selector(settingButtonPressed)
        )
        
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    @objc func backButtonPressed() {
        popViewController()
    }
    
    @objc func settingButtonPressed() {
//        let controller = NotificationSystemSettingController(preferencesLoader: NotificationPreferencesLoader(, preferencesUpdater: <#T##NotificationPreferencesUpdater#>)
//        controller.modalPresentationStyle = .overFullScreen
//        push(controller)
    }
    
    func makeLayout() -> UICollectionViewCompositionalLayout {
        return .init(section: .notificationSystems)
    }
}

extension NotificationSystemController: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // TODO: Improve this
        if dataSource.snapshot().itemIdentifiers.count - 3 == indexPath.item {
            pagingController?.load()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cell(at: indexPath)?.select()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        cell(at: indexPath)?.deselect()
    }
}


extension NotificationSystemController: NotificationSystemLoadingView {
    public func display(_ viewModel: NotificationSystemLoadingViewModel) {
        if viewModel.isLoading {
            refresh.beginRefreshing()
        } else {
            refresh.endRefreshing()
        }
    }
}

extension NotificationSystemController: NotificationSystemUnreadView, NotificationSystemUnreadErrorLoadingView {
    
    public func display(_ viewModel: NotificationSystemUnreadViewModel) {
        
        if viewModel.status {
            self.redDotView.isHidden = false
        } else {
            self.redDotView.isHidden = true
        }
        view.layoutIfNeeded()
        refresh.endRefreshing()
    }
    
    public func display(_ viewModel: NotificationSystemUnreadErrorViewModel) {
        print("error \(viewModel.message)")
        refresh.endRefreshing()
    }
}

extension NotificationSystemController: UIGestureRecognizerDelegate {}
