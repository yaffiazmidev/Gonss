import UIKit
import KipasKipasDonationRank
import KipasKipasShared

public final class DonationGlobalRankViewController: UICollectionViewController {
    
    private lazy var dataSource = makeDataSource()
    
    private lazy var refreshView: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    
    private var loadingController: DonationGlobalRankLoadingController?
    
    private var headerViewModel: DonationGlobalRankHeaderViewModel? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var onRefreshHeader: (() -> Void)?
    
    convenience init(loadingController: DonationGlobalRankLoadingController) {
        self.init(collectionViewLayout: UICollectionViewLayout())
        self.loadingController = loadingController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .deepPurple
        configureUI()
        onRefreshHeader?()
        loadingController?.load()
    }
    
    func set(_ items: [CellController]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
        snapshot.deleteAllItems()
        snapshot.appendSections([0])
        snapshot.appendItems(items)
        dataSource.apply(snapshot)
    }
}

extension DonationGlobalRankViewController: DonationGlobalRankLoadingView {
    public func display(_ viewModel: DonationGlobalRankLoadingViewModel) {
        if viewModel.isLoading {
            refreshView.beginRefreshing()
            loadingController?.view.show(in: view)
        } else {
            refreshView.endRefreshing()
            loadingController?.view.dismiss()
        }
    }
}

extension DonationGlobalRankViewController: DonationGlobalRankHeaderView {
    public func display(_ viewModel: DonationGlobalRankHeaderViewModel) {
        headerViewModel = viewModel
    }
}

// MARK: UI
private extension DonationGlobalRankViewController {
    func configureUI() {
        configureCollectionView()
    }
    
    func configureCollectionView() {
        collectionView.refreshControl = refreshView
        collectionView.refreshControl?.tintColor = .white
        collectionView.backgroundColor = .deepPurple
        collectionView.collectionViewLayout = makeLayout()
        collectionView.prefetchDataSource = self
        collectionView.dataSource = dataSource
        collectionView.registerCell(DonationRankCell.self)
        collectionView.registerHeader(DonationSelfRankHeaderView.self)
    }
    
    @objc func refresh() {
        loadingController?.load()
    }
}

// MARK: DataSource
private extension DonationGlobalRankViewController {
    func makeDataSource() -> EmptyableDiffableDataSource<Int, CellController> {
        let dataSource: EmptyableDiffableDataSource<Int, CellController>  = .init(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, controller in
                controller.view(collectionView, forItemAt: indexPath)
            },
            emptyStateView: EmptyView(message: "Ranking belum tersedia")
        )
        dataSource.supplementaryViewProvider = collectionView(_:viewForSupplementaryElementOfKind:at:)
        return dataSource
    }
    
    func cellController(forItemAt indexPath: IndexPath) -> DonationGlobalRankCellController? {
        let controller = dataSource.itemIdentifier(for: indexPath) as? DonationGlobalRankCellController
        return controller
    }
    
    func removeCellController(forItemAt indexPath: IndexPath) {
        cellController(forItemAt: indexPath)?.cancel()
    }
    
    func prefetchCellController(forItemAt indexPath: IndexPath) {
        cellController(forItemAt: indexPath)?.prefetch()
    }
}

extension DonationGlobalRankViewController: UICollectionViewDataSourcePrefetching {
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(prefetchCellController)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(removeCellController)
    }
    
    public override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.collectionView(collectionView, prefetchItemsAt: [indexPath])
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.collectionView(collectionView, cancelPrefetchingForItemsAt: [indexPath])
    }
    
    public override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header: DonationSelfRankHeaderView = collectionView.dequeueReusableHeader(at: indexPath)
        
        if let viewModel = headerViewModel {
            header.setProfileImage(URL(string: viewModel.item.profileImageURL + "?x-oss-process=image/format,jpg/interlace,1/resize,w_100"))
            header.setBadgeImage(URL(string: viewModel.item.badgeURL + "?x-oss-process=image/format,png/resize,w_200"))
            header.setRank(viewModel.item.rank)
            header.setRankStatus(viewModel.item.statusRank)
        }
        
        return header
    }
}

// MARK: Layout
private extension DonationGlobalRankViewController {
    func makeLayout() -> UICollectionViewCompositionalLayout {
        let section = NSCollectionLayoutSection.donationRankSection
        configureHeader(in: section)
        return .init(section: section)
    }
    
    func configureHeader(in section: NSCollectionLayoutSection) {
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(150)
            ),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        header.pinToVisibleBounds = true
        section.boundarySupplementaryItems = [header]
    }
}
