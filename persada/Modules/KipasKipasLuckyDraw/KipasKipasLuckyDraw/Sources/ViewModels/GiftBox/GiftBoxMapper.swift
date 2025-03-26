import Foundation

public enum GiftBoxMapper {
    public static func map(_ response: GiftBox) -> GiftBoxViewModel {
        return GiftBoxViewModel(
            id: response.id,
            giftName: response.giftName ?? "",
            giftPrice: response.giftPrice ?? 0,
            giftNum: response.giftNum ?? 0,
            giftURL: response.giftURL ?? "",
            lotteryType: .init(rawValue: response.lotteryType ?? ""),
            createAt: response.createAt ?? "",
            lotteryDate: response.lotteryDate ?? "",
            lotteryCrowdType: .init(rawValue: response.lotteryCrowdType ?? ""),
            lotteryNum: response.lotteryNum ?? 0,
            accountId: response.ownerAccountID ?? 0,
            status: response.status ?? "",
            isJoined: response.isJoined == true,
            isFans: response.isFans == true,
            winners: response.wonAccounts?.compactMap { winner in
                return WinnerViewModel(
                    id: winner.id,
                    name: winner.name ?? "",
                    username: winner.username ?? "",
                    photo: winner.photo ?? "",
                    giftName: response.giftName ?? ""
                )
            } ?? []
        )
    }
}
