import Foundation

public enum GiftBoxType: String {
    case drawWinner = "DRAWWINNER"
    case drawNumber = "DRAWNUMBER"
    case drawTime = "DRAWTIME"
}

public enum GiftBoxCrowdType: String {
    case all = "ALLUSER"
    case fans = "FANS"
}

public struct GiftBoxViewModel {
    public let id: Int
    public let giftName: String
    public let giftPrice: Double
    public let giftNum: Int
    public let giftURL: String
    public let lotteryType: GiftBoxType?
    public let createAt: String
    public let lotteryDate: String
    public let lotteryCrowdType: GiftBoxCrowdType?
    public let lotteryNum: Int
    public let accountId: Int
    public let status: String
    public let isJoined: Bool
    public let isFans: Bool
    public let winners: [WinnerViewModel]
    
    public init(
        id: Int,
        giftName: String,
        giftPrice: Double,
        giftNum: Int,
        giftURL: String,
        lotteryType: GiftBoxType?,
        createAt: String,
        lotteryDate: String,
        lotteryCrowdType: GiftBoxCrowdType?,
        lotteryNum: Int,
        accountId: Int,
        status: String,
        isJoined: Bool,
        isFans: Bool,
        winners: [WinnerViewModel]
    ) {
        self.id = id
        self.giftName = giftName
        self.giftPrice = giftPrice
        self.giftNum = giftNum
        self.giftURL = giftURL
        self.lotteryType = lotteryType
        self.createAt = createAt
        self.lotteryDate = lotteryDate
        self.lotteryCrowdType = lotteryCrowdType
        self.lotteryNum = lotteryNum
        self.accountId = accountId
        self.status = status
        self.isJoined = isJoined
        self.isFans = isFans
        self.winners = winners
    }
    
    private var convertedDate: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return dateFormatter.date(from: lotteryDate) ?? Date()
    }
    
    private var countdown: (interval: TimeInterval, daysRemaining: Int) {
        let currentDate = Date()
        let timeInterval = convertedDate.timeIntervalSince(currentDate)
        
        guard timeInterval > 0 else { return (0,0) }
        
        let days = Int(timeInterval) / (24 * 60 * 60)
        return (timeInterval, days)
    }
    
    private var scheduleDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "dd MMMM yyyy"
        dateFormatter.locale = Locale(identifier: "id-ID")
        
        return dateFormatter.string(from: convertedDate)
    }
    
    private var scheduleTimeString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale(identifier: "id-ID")
        
        return dateFormatter.string(from: convertedDate)
    }
}

public extension GiftBoxViewModel {
    var schedule: GiftBoxLotteryScheduleViewModel {
        return .init(
            interval: countdown.interval,
            daysRemaining: countdown.daysRemaining
        )
    }
    
    var photoURL: URL? {
        return URL(string: giftURL)
    }
    
    var scheduleTitle: String? {
        switch lotteryType {
        case .drawTime:
            return "Waktu Mulai Undian"
        case .drawNumber:
            return "Menurut Jumlah Peserta"
        case .drawWinner:
            return "Pilih, Langsung Menang"
        default:
            return nil
        }
    }
    
    var scheduleTimeDesc: String? {
        switch lotteryType {
        case .drawTime:
            return "\(scheduleDateString), pukul \(scheduleTimeString) pengundian otomatis"
        case .drawNumber:
            return "Pengundian otomatis akan dilakukan saat mencapai xxx peserta. Acara akan berakhir pada \(scheduleDateString), pukul \(scheduleTimeString)"
        case .drawWinner:
            return "Acara akan berakhir pada \(scheduleDateString), pukul \(scheduleTimeString)"
        default:
            return nil
        }
    }
    
    var priceDesc: String {
        return giftPrice.inRupiah()
    }
}

private extension Double {
    func inRupiah() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: NSNumber(value: self)) ?? "Rp0"
    }
}

public var giftBoxViewModelMocks: [GiftBoxViewModel] {
    [
        .init(
            id: 1,
            giftName: "iPhone 15 Pro",
            giftPrice: 9999.0,
            giftNum: 10,
            giftURL: "https://picsum.photos/seed/picsum/200/200",
            lotteryType: .drawNumber,
            createAt: "2024-07-18 02:35:52",
            lotteryDate: "2024-07-28 09:45:00",
            lotteryCrowdType: .fans,
            lotteryNum: 10,
            accountId: Int.random(in: 1...100),
            status: "Start",
            isJoined: true,
            isFans: false,
            winners: (0...10).map { _ in
                return winnerViewModel
            }
        ),
        .init(
            id: 2,
            giftName: "iPhone 15 Pro",
            giftPrice: 9999.0,
            giftNum: 10,
            giftURL: "https://picsum.photos/seed/picsum/200/200",
            lotteryType: .drawNumber,
            createAt: "2024-07-18 02:35:52",
            lotteryDate: "2024-07-28 09:45:00",
            lotteryCrowdType: .fans,
            lotteryNum: 10,
            accountId: Int.random(in: 1...100),
            status: "Start",
            isJoined: false,
            isFans: false,
            winners: (0...10).map { _ in
                return winnerViewModel
            }
        ),
        .init(
            id: 3,
            giftName: "iPhone 16 Pro",
            giftPrice: 9999.0,
            giftNum: 10,
            giftURL: "https://picsum.photos/seed/picsum/200/200",
            lotteryType: .drawWinner,
            createAt: "2024-07-18 02:35:52",
            lotteryDate: "2024-07-26 10:12:00",
            lotteryCrowdType: .all,
            lotteryNum: 10,
            accountId: Int.random(in: 1...100),
            status: "Start",
            isJoined: false,
            isFans: true,
            winners: (0...10).map { _ in
                return winnerViewModel
            }
        ),
        .init(
            id: 4,
            giftName: "iPhone 16 Pro",
            giftPrice: 88888.0,
            giftNum: 10,
            giftURL: "https://picsum.photos/seed/picsum/200/200",
            lotteryType: .drawTime,
            createAt: "2024-07-18 02:35:52",
            lotteryDate: "2024-07-26 10:12:00",
            lotteryCrowdType: .all,
            lotteryNum: 10,
            accountId: Int.random(in: 1...100),
            status: "Start",
            isJoined: true,
            isFans: true,
            winners: (0...10).map { _ in
                return winnerViewModel
            }
        )
    ]
}

public var winnerViewModel: WinnerViewModel {
    return WinnerViewModel(
        id: Int.random(in: 1...999),
        name: "User \(Int.random(in: 0...1000))",
        username: "user_\(Int.random(in: 0...1000))",
        photo: "https://picsum.photos/seed/picsum/200/200",
        giftName: "iPhone 15 Pro"
    )
}
