import Foundation

public struct CollectionSectionController {
    public let id: AnyHashable
    public let cellControllers: [CollectionCellController]
    public let sectionType: String
    
    public init(
        id: AnyHashable = UUID(),
        cellControllers: [CollectionCellController],
        sectionType: String
    ) {
        self.id = id
        self.cellControllers = cellControllers
        self.sectionType = sectionType
    }
}

extension CollectionSectionController: Equatable {
    public static func == (lhs: CollectionSectionController, rhs: CollectionSectionController) -> Bool {
        lhs.id == rhs.id
    }
}

extension CollectionSectionController: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
