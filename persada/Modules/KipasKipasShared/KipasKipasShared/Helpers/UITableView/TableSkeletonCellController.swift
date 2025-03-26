import UIKit

public final class TableSkeletonCellController<Cell: UITableViewCell>: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    private var cell: Cell?
    
    private let height: CGFloat

    public init(height: CGFloat) {
        self.height = height
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.setAnimatedSkeletonView(true)
        cell?.setNeedsLayout()
        cell?.layoutIfNeeded()
        
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return height
    }
}

public enum TableSkeletonCell<Cell: UITableViewCell> {
    private static func create(height: CGFloat) -> TableCellController {
        let view = TableSkeletonCellController<Cell>(height: height)
        return TableCellController(view)
    }
    
    public static func sections(
        count: Int = 1,
        height: CGFloat
    ) -> [TableSectionController] {
        guard count >= 1 else { fatalError("Need at least 1 cell controller") }
        let controllers = (0...count).map { _ in
            return create(height: height)
        }
        let section = TableSectionController(cellControllers: controllers)
        return [section]
    }
}


