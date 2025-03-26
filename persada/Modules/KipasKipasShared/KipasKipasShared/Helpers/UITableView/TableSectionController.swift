import UIKit

public struct TableSectionController {
    public let id: AnyHashable
    public let cellControllers: [TableCellController]
    
    public init(
        id: AnyHashable = UUID(),
        cellControllers: [TableCellController]
    ) {
        self.id = id
        self.cellControllers = cellControllers
    }
}

extension TableSectionController: Equatable {
    public static func == (lhs: TableSectionController, rhs: TableSectionController) -> Bool {
        lhs.id == rhs.id
    }
}

extension TableSectionController: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
