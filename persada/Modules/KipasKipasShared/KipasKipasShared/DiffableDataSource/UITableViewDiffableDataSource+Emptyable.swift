import UIKit

public class EmptyableTableViewDiffableDataSource<S, T>: UITableViewDiffableDataSource<S, T> where S: Hashable, T: Hashable {
    
    private var tableView: UITableView
    private var emptyStateView: UIView?
    
    public init(
        tableView: UITableView,
        cellProvider: @escaping UITableViewDiffableDataSource<S, T>.CellProvider,
        emptyStateView: UIView? = nil
    ) {
        self.tableView = tableView
        self.emptyStateView = emptyStateView
        super.init(tableView: tableView, cellProvider: cellProvider)
    }
    
    public override func apply(_ snapshot: NSDiffableDataSourceSnapshot<S, T>, animatingDifferences: Bool = true, completion: (() -> Void)? = nil) {
        super.apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
        setErrorViewIfNeeded(snapshot)
    }
    
    @available(iOS 15.0, *)
    public nonisolated override func applySnapshotUsingReloadData(_ snapshot: NSDiffableDataSourceSnapshot<S, T>, completion: (() -> Void)? = nil) {
        super.applySnapshotUsingReloadData(snapshot, completion: completion)
        Task {
            await setErrorViewIfNeeded(snapshot)
        }
    }
    
    private func setErrorViewIfNeeded(_ snapshot: NSDiffableDataSourceSnapshot<S, T>) {
        guard let emptyView = emptyStateView else {
            return
        }
        
        if snapshot.itemIdentifiers.isEmpty {
            tableView.isUserInteractionEnabled = false
            tableView.addSubview(emptyView)
            emptyView.anchors.edges.pin(to: tableView.layoutMarginsGuide)
        } else {
            tableView.isUserInteractionEnabled = true
            emptyStateView?.removeFromSuperview()
        }
    }
    
    public var isEmpty: Bool {
        return snapshot().itemIdentifiers.isEmpty
    }
    
    public var emptyView: UIView? {
        return emptyStateView
    }
}

