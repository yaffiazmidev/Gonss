import KipasKipasShared
import KipasKipasDonateStuff

public typealias DonationItemPaymentLoader = AnyResourceLoader<String, DonationItemPaymentData>

typealias DonationItemPaymentPresentationAdapter<View: ResourceView> = LoadResourcePresentationAdapter<DonationItemPaymentLoader, View> where View.ResourceViewModel == DonationItemPaymentViewModel

struct DonationItemPaymentMapper {
    static func map(
        _ response: DonationItemPaymentData
    ) -> DonationItemPaymentViewModel {
        
        let data = response.data
        let orderDetail = data.orderDetail
        let payment = data.payment
        
        return DonationItemPaymentViewModel(
            paymentURL: orderDetail?.urlPaymentPage ?? "",
            status: .init(
                paymentStatus: .init(rawValue: payment?.status ?? ""),
                expiredPaymentTime: orderDetail?.expireTimePayment ?? 0
            ),
            initiator: .init(
                initiatorId: orderDetail?.initiatorId ?? "",
                initiatorName: orderDetail?.initiatorName ?? "",
                initiatorPhoto: orderDetail?.urlInitiatorPhoto ?? "",
                donationPhoto: orderDetail?.urlDonationPhoto ?? "",
                donationTitle: orderDetail?.donationTitle ?? ""
            ),
            product: .init(
                productId: orderDetail?.productId ?? "",
                productName: orderDetail?.productName ?? "",
                productPhoto: orderDetail?.urlProductPhoto ?? "",
                productPrice: orderDetail?.productPrice ?? 0,
                productQty: orderDetail?.quantity ?? 0
            ),
            transaction: .init(
                subtotal: data.amount ?? 0,
                shippingFee: 0,
                adminFee: 0
            ),
            method: .init(
                transactionNumber: payment?.paymentAccount?.number,
                transactionDate: orderDetail?.createAt ?? 0,
                bankName: payment?.bank,
                paymentType: .init(rawValue: payment?.type ?? ""),
                hasNoPaymentMethod: payment?.paymentAccount?.number == nil
            )
        )
    }
}
