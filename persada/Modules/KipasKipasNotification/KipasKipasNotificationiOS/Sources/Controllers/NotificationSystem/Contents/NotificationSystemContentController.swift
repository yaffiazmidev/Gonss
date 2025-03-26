import UIKit
import KipasKipasShared
import KipasKipasNotification

public class NotificationSystemContentController: UIViewController {
    
    private lazy var collectionView: UICollectionView = UICollectionView()
    private(set) var refresh = UIRefreshControl()
    private var emptyMessage: String?
    private var types: String
    private var pagingController: NotificationSystemPagingController?
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
        types: String,
        pagingController: NotificationSystemPagingController,
        emptyMessage: String
    ) {
        self.types = types
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
        onLoad?(0, 10, types)
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

private extension NotificationSystemContentController {
    func configureUI() {
        view.backgroundColor = .whiteSnow
        configureCollectionView()
        configureNavigationBar()
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
        
        collectionView.anchors.top.equal(view.safeAreaLayoutGuide.anchors.top)
        collectionView.anchors.leading.equal(view.anchors.leading)
        collectionView.anchors.trailing.equal(view.anchors.trailing)
        collectionView.anchors.bottom.equal(view.anchors.bottom)
    }
    
    func configureNavigationBar() {
        if types == "hotroom" {
            navigationItem.title = "Sosial"
        } else if types == "live" {
            navigationItem.title = "LIVE"
        } else if types == "account" {
            navigationItem.title = "Account"
        }
        
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationController?.navigationBar.tintColor = .black
        
        let leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonPressed)
        )
        
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    @objc func backButtonPressed() {
        popViewController()
    }
    
    func makeLayout() -> UICollectionViewCompositionalLayout {
        return .init(section: .notificationSystems)
    }
}

extension NotificationSystemContentController: UICollectionViewDelegate {
    
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


extension NotificationSystemContentController: NotificationSystemLoadingView {
    public func display(_ viewModel: NotificationSystemLoadingViewModel) {
        if viewModel.isLoading {
            refresh.beginRefreshing()
        } else {
            refresh.endRefreshing()
        }
    }
}

extension NotificationSystemContentController: NotificationSystemUnreadView, NotificationSystemUnreadErrorLoadingView {
    
    public func display(_ viewModel: NotificationSystemUnreadViewModel) {
        
        view.layoutIfNeeded()
        refresh.endRefreshing()
    }
    
    public func display(_ viewModel: NotificationSystemUnreadErrorViewModel) {
        print("error \(viewModel.message)")
        refresh.endRefreshing()
    }
}

extension NotificationSystemContentController: UIGestureRecognizerDelegate {}
