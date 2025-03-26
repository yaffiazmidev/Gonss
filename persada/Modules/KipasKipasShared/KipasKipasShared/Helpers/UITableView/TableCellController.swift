import UIKit

public struct TableCellController {
    let id: AnyHashable
    let dataSource: UITableViewDataSource
    let delegate: UITableViewDelegate?
    let dataSourcePrefetching: UITableViewDataSourcePrefetching?
    
    public init(
        id: AnyHashable = UUID(),
        _ dataSource: UITableViewDataSource
    ) {
        self.id = id
        self.dataSource = dataSource
        self.delegate = dataSource as? UITableViewDelegate
        self.dataSourcePrefetching = dataSource as? UITableViewDataSourcePrefetching
    }
}

extension TableCellController: Equatable {
    public static func == (lhs: TableCellController, rhs: TableCellController) -> Bool {
        lhs.id == rhs.id
    }
}

extension TableCellController: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
