import UIKit
import KipasKipasShared
import KipasKipasDonationHistory

public final class DonationHistoryViewController: UICollectionViewController {
    
    private lazy var dataSource: EmptyableDiffableDataSource<Int, CellController> = {
        return .init(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, controller in
                return controller.view(collectionView, forItemAt: indexPath)
            },
            emptyStateView: EmptyView(message: emptyMessage ?? "")
        )
    }()
    
    private lazy var refreshView: UIRefreshControl = {
        let refreshView = UIRefreshControl()
        refreshView.tintColor = .ashGrey
        refreshView.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshView
    }()
    
    var onLoad: (() -> Void)?
    
    private var emptyMessage: String?
    private var pagingController: DonationHistoryPagingController?
    
    convenience init(
        pagingController: DonationHistoryPagingController,
        emptyMessage: String
    ) {
        self.init(collectionViewLayout: UICollectionViewLayout())
        self.pagingController = pagingController
        self.emptyMessage = emptyMessage
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
        refresh()
    }
    
    @objc private func refresh() {
        onLoad?()
    }
    
    func set(_ items: [CellController]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
        snapshot.deleteAllItems()
        snapshot.appendSections([0])
        snapshot.appendItems(items)
        dataSource.apply(snapshot)
    }
    
    func append(_ newItems: [CellController]) {
        var snapshot = dataSource.snapshot()
        // TODO: Remove this
        if snapshot.numberOfSections == 0 {
            snapshot.appendSections([0])
        }
        snapshot.appendItems(newItems, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    public override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // TODO: Improve this
        if dataSource.snapshot().itemIdentifiers.count - 3 == indexPath.item {
            pagingController?.load()
        }
    }
}

extension DonationHistoryViewController: DonationHistoryLoadingView {
    public func display(_ viewModel: DonationHistoryLoadingViewModel) {
        if viewModel.isLoading {
            refreshView.beginRefreshing()
        } else {
            refreshView.endRefreshing()
        }
    }
}

// MARK: UI
private extension DonationHistoryViewController {
    func configureUI() {
        configureCollectionView()
    }
    
    func configureCollectionView() {
        collectionView.refreshControl = refreshView
        collectionView.collectionViewLayout = makeLayout()
        collectionView.backgroundColor = .white
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        collectionView.registerCell(DonationHistoryCell.self)
    }
}

private extension DonationHistoryViewController {
    func makeLayout() -> UICollectionViewCompositionalLayout {
        return .init(section: .donationHistory)
    }
}
