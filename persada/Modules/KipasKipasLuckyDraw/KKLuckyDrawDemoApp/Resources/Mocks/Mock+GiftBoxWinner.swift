import KipasKipasLuckyDraw

extension GiftBoxWinner {
    struct Custom {
        let id: Int
        
        init(id: Int = 1) {
            self.id = id
        }
        
        var randomNumber: Int {
            return Int.random(in: 1...100)
        }
    }
    
    static func mock(_ customValue: Custom = Custom()) -> GiftBoxWinner {
        return GiftBoxWinner(
            id: customValue.id,
            name: "User \(customValue.randomNumber)",
            username: "user_\(customValue.randomNumber)",
            photo: "https://api.dicebear.com/9.x/initials/jpeg?seed=KK"
        )
    }
}

extension [GiftBoxWinner] {
    static var mocks: [Element] {
        return (1...10).map { id in
            return .mock(.init(id: id))
        }
    }
}
