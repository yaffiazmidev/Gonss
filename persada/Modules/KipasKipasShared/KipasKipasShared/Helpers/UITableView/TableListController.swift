import UIKit

/**
 🚨 This class should not be modified
 */
open class TableListController: UITableViewController, UITableViewDataSourcePrefetching, NavigationAppearance {
    
    public var emptyMessage: String?
    
    private lazy var dataSource: EmptyableTableViewDiffableDataSource<TableSectionController, TableCellController> = {
        return .init(
            tableView: tableView,
            cellProvider: { (tableView, index, controller) in
                controller.dataSource.tableView(tableView, cellForRowAt: index)
            },
            emptyStateView: EmptyView(message: emptyMessage ?? "")
        )
    }()
    
    public var onRefresh: (() -> Void)?
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        return nil
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        configureTableView()
        refresh()
    }
    
    private func configureTableView() {
        dataSource.defaultRowAnimation = .fade
        tableView.backgroundColor = .white
        tableView.dataSource = dataSource
        tableView.prefetchDataSource = self
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.sizeTableHeaderToFit()
    }
    
    public override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        if previous?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            tableView.reloadData()
        }
    }
    
    private func refresh() {
        onRefresh?()
    }
    
    deinit {
        display(sections: [])
    }
    
    public func display(sections: [TableSectionController]) {
        var snapshot = NSDiffableDataSourceSnapshot<TableSectionController, TableCellController>()
        sections.forEach { section in
            snapshot.appendSections([section])
            snapshot.appendItems(section.cellControllers, toSection: section)
        }
     
        if #available(iOS 15.0, *) {
            dataSource.applySnapshotUsingReloadData(snapshot, completion: nil)
        } else {
            dataSource.apply(snapshot)
        }
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dl = cellController(at: indexPath)?.delegate
        dl?.tableView?(tableView, didSelectRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let dl = cellController(at: indexPath)?.delegate
        dl?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let dl = cellController(at: indexPath)?.delegate
        dl?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let dl = cellController(at: indexPath)?.delegate
        return dl?.tableView?(tableView, heightForRowAt: indexPath) ?? UITableView.automaticDimension
    }
    
    public override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let dl = cellController(at: indexPath)?.delegate
        return dl?.tableView?(tableView, estimatedHeightForRowAt: indexPath) ?? UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsp = cellController(at: indexPath)?.dataSourcePrefetching
            dsp?.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsp = cellController(at: indexPath)?.dataSourcePrefetching
            dsp?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }
    
    private func cellController(at indexPath: IndexPath) -> TableCellController? {
        dataSource.itemIdentifier(for: indexPath)
    }
}

extension UITableView {
    func sizeTableHeaderToFit() {
        guard let header = tableHeaderView else { return }
        
        let size = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        let needsFrameUpdate = header.frame.height != size.height
        if needsFrameUpdate {
            header.frame.size.height = size.height
            tableHeaderView = header
        }
    }
}
