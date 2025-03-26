import KipasKipasLuckyDraw

extension GiftBox {
    struct Custom {
        let giftName: String
        let lotteryCrowdType: String
        let lotteryType: String
        let isJoined: Bool
        let isFans: Bool
        
        init(
            giftName: String = "iPhone SE 2024",
            lotteryCrowdType: String = "ALLUSER",
            lotteryType: String = "DRAWTIME",
            isJoined: Bool = false,
            isFans: Bool = false
        ) {
            self.giftName = giftName
            self.lotteryCrowdType = lotteryCrowdType
            self.lotteryType = lotteryType
            self.isJoined = isJoined
            self.isFans = isFans
        }
    }
    
    static func mock(_ customValue: Custom = Custom()) -> GiftBox {
        return GiftBox(
            id: Int.random(in: 1...1000),
            giftName: customValue.giftName,
            giftPrice: Double.random(in: 9_999...999_999),
            giftNum: Int.random(in: 1...10),
            giftURL: "https://picsum.photos/seed/picsum/200/200",
            lotteryType: customValue.lotteryType,
            createAt: "2024-07-18 02:35:52",
            lotteryDate: "2024-07-28 09:45:00",
            lotteryCrowdType: customValue.lotteryCrowdType,
            feedID: "",
            lotteryNum: Int.random(in: 1...10),
            ownerAccountID: Int.random(in: 10_000...99_999),
            isJoined: customValue.isJoined,
            isFans: customValue.isFans,
            status: "Start",
            wonAccounts: .mocks
        )
    }
}
