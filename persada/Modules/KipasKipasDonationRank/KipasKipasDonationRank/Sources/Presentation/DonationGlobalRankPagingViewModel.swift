import Foundation

public struct DonationGlobalRankPagingViewModel: Equatable {
    public let isLast: Bool
    public let isLoading: Bool
    public let totalItems: Int
    
    public var size: Int {
        return 10
    }
    
    public var currentPage: Int {
        let page = round(Double(totalItems) / Double(size))
        return Int(page) - 1
    }
    
    public var nextPage: Int? {
        return isLast ? nil : currentPage + 1
    }
    
    public init(isLoading: Bool, isLast: Bool, totalItems: Int) {
        self.isLoading = isLoading
        self.isLast = isLast
        self.totalItems = totalItems
    }
}

