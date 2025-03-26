import Foundation

public struct WinnerViewModel {
    public let id: Int
    public let name: String
    public let username: String
    public let photo: String
    public let giftName: String
    
    public init(
        id: Int,
        name: String,
        username: String,
        photo: String,
        giftName: String
    ) {
        self.id = id
        self.name = name
        self.username = username
        self.photo = photo
        self.giftName = giftName
    }
}

public extension WinnerViewModel {
    var censoredName: String {
        return name.censored()
    }
}

private extension String {
    func censored() -> String {
        return split(separator: " ").map { word in
            let first = word.first!
            let censored = String(repeating: "*", count: 3)
            return "\(first)\(censored)"
        }.joined(separator: " ")
    }
}
