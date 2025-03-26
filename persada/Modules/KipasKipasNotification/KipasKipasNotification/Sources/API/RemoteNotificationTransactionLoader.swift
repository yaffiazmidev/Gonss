import Foundation
import KipasKipasNetworking

public class RemoteNotificationTransactionLoader: NotificationTransactionLoader {
    
    private let url: URL
    private let client: HTTPClient
    public typealias Result = NotificationTransactionLoader.ResultTransaction
    
    public init(
        url: URL,
        client: HTTPClient)
    {
        self.url = url
        self.client = client
    }

    public func load(request: NotificationTransactionRequest, completion: @escaping (Result) -> Void) {
        
        let urlRequest = NotificationEndpoint.transaction(request: request).url(baseURL: url)
        
        Task {
            do {
                let (data, response) = try await client.request(from: urlRequest)
                completion(RemoteNotificationTransactionLoader.map(data, from: response))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> NotificationTransactionLoader.ResultTransaction {
        do {
            let items = try NotificationTransactionItemMapper.map(data, from: response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
}

public class NotificationTransactionItemMapper {
    
    private struct Root: Codable {
        private let data: DataClass?
        
        private struct DataClass: Codable {
            var content: [Content]?
            var totalPages: Int?
        }
        
        private struct Content: Codable {
            let id, orderType, status, paymentStatus, notifType: String?
            let shipmentStatus: String?
            let accountShopType: String?
            let accountDonationType: String?
            let account: NotifProfile?
            let orderId: String?
            let createAt: Int?
            let message: String?
            let urlProductPhoto: String?
            var isRead, isNotifWeightAdj, isProductBanned: Bool?
            let productId: String?
            let withdrawType: String?
            let withdrawl: Withdrawl?
            let currency: NotificationTransactionCurrency?
            let groupOrderId: String?
        }
        
        private struct NotificationTransactionCurrency: Codable {
            let orderId: String?
            let withdrawCurrencyId: String?
            let currencyType: String?
            let qty: Int?
            let price: Double?
            let totalWithdraw: Double?
            let bankAccount: String?
            let storeName: String?
            let bankAccountName: String?
            let bankName: String?
            let bankFee: Double?
            let modifyAt: String?
            let status: String?
            let noInvoice: String?
        }

        private struct Withdrawl: Codable {
            let id, status: String?
            let nominal, bankFee, total: Double?
            let bankAccount, referenceNo, bankAccountName, bankName: String?
        }
        
        private struct NotifProfile: Codable {
            let accountType : String?
            let bio : String?
            let email : String?
            var id : String?
            var isFollow : Bool?
            let birthDate: String?
            let note: String?
            let isDisabled: Bool?
            let isSeleb: Bool?
            let isVerified : Bool?
            let mobile : String?
            let name : String?
            var photo : String?
            var username : String?
            let isSeller: Bool?
            let referralCode: String?
            let urlBadge: String?
            let isShowBadge: Bool?
            let chatPrice: Int?
        }
        
        var items: NotificationTransactionContent {
             let content = data?.content?.compactMap({
                let account = NotificationSuggestionAccountItem(
                    id: $0.account?.id ?? "",
                    username: $0.account?.username ?? "",
                    name: $0.account?.name ?? "",
                    photo: $0.account?.photo ?? "",
                    isFollow: $0.account?.isFollow ?? false,
                    isFollowed: false,
                    isVerified: $0.account?.isVerified ?? false,
                    suggestId: "",
                    suggestType: "",
                    firstId: "",
                    firstName: "",
                    firstPhoto: "",
                    secondId: "",
                    secondName: "",
                    secondPhoto: "",
                    othersLike:  0,
                    followedAt: 0
                
                )
                let withdrawal = NotificationWithdrawl(id: $0.withdrawl?.id ?? "", status: $0.withdrawl?.status ?? "", nominal: $0.withdrawl?.nominal ?? 0, bankFee: $0.withdrawl?.bankFee ?? 0 , total: $0.withdrawl?.total ?? 0, bankAccount: $0.withdrawl?.bankAccount ?? "", referenceNo: $0.withdrawl?.referenceNo ?? "", bankAccountName: $0.withdrawl?.bankAccountName ?? "", bankName: $0.withdrawl?.bankName ?? "")
                let currency = NotificationTransactionItemCurrency(orderId: $0.currency?.orderId ?? "", withdrawCurrencyId: $0.currency?.withdrawCurrencyId ?? "", currencyType: $0.currency?.currencyType ?? "", qty: $0.currency?.qty ?? 0, price: $0.currency?.price ?? 0 , totalWithdraw: $0.currency?.totalWithdraw ?? 0, bankAccount: $0.currency?.bankAccount ?? "", storeName: $0.currency?.storeName ?? "", bankAccountName: $0.currency?.bankAccountName ?? "", bankName: $0.currency?.bankName ?? "", bankFee: $0.currency?.bankFee ?? 0, modifyAt: $0.currency?.modifyAt ?? "", status: $0.currency?.status ?? "", noInvoice: $0.currency?.noInvoice ?? "")
                 
                 return NotificationTransactionItem(
                    id: $0.id ?? "",
                    orderType: $0.orderType ?? "",
                    status: $0.status ?? "",
                    paymentStatus: $0.paymentStatus ?? "",
                    notifType: $0.notifType ?? "",
                    shipmentStatus: $0.shipmentStatus ?? "",
                    accountShopType: $0.accountShopType ?? "",
                    accountDonationType: $0.accountDonationType ?? "",
                    account: account,
                    orderID: $0.orderId ?? "",
                    createAt: $0.createAt ?? 0,
                    message: $0.message ?? "-",
                    urlProductPhoto: $0.urlProductPhoto ?? "",
                    isRead: $0.isRead ?? false,
                    isNotifWeightAdj: $0.isNotifWeightAdj ?? false,
                    isProductBanned: $0.isProductBanned ?? false,
                    productID: $0.productId ?? "",
                    withdrawType: $0.withdrawType ?? "",
                    withdrawl: withdrawal,
                    currency: currency,
                    groupOrderId: $0.groupOrderId)
            })
            
            return NotificationTransactionContent(content: content ?? [], totalPages: data?.totalPages)
        }
    }
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> NotificationTransactionContent {
        guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return root.items
    }
}
