import Foundation

public struct DonationHistoryPagingViewModel: Equatable {
    public let isLoading: Bool
    public let totalItems: Int
    
    public var size: Int {
        return 25
    }
    
    public var currentPage: Int {
        let page = round(Double(totalItems) / Double(size))
        let currentPage = Int(page) - 1
        return currentPage
    }
    
    public var isLast: Bool {
        return totalItems < size
    }
    
    public var nextPage: Int? {
        return isLast ? nil : currentPage + 1
    }
    
    public init(isLoading: Bool, totalItems: Int) {
        self.isLoading = isLoading
        self.totalItems = totalItems
    }
}
