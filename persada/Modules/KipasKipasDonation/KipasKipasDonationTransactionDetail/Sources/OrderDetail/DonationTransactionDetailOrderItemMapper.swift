import Foundation
import KipasKipasNetworking

final class DonationTransactionDetailOrderItemMapper {
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> DonationTransactionDetailOrderItem {
        guard response.isOK else {
            guard let error = try? JSONDecoder().decode(KKErrorNetworkRemoteResponse.self, from: data) else {
                throw KKNetworkError.invalidData
            }
            throw KKNetworkError.responseFailure(KKErrorNetworkResponse.fromRemote(error))
        }
        
        guard let root = try? JSONDecoder().decode(RemoteDonationTransactionOrderRoot.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return DonationTransactionDetailOrderItem(
            id: root.data.id ?? "",
            noInvoice: root.data.noInvoice ?? "",
            orderDetail: DonationTransactionDetailOrderDetailItem(
                quantity: root.data.orderDetail?.quantity ?? 1,
                variant: root.data.orderDetail?.variant,
                measurement: DonationTransactionDetailOrderMeasurementItem(
                    weight: root.data.orderDetail?.measurement?.weight ?? 0,
                    length: root.data.orderDetail?.measurement?.length ?? 0,
                    height: root.data.orderDetail?.measurement?.height ?? 0,
                    width: root.data.orderDetail?.measurement?.width ?? 0
                ),
                feedId: root.data.orderDetail?.feedId,
                productID: root.data.orderDetail?.productID ?? "",
                productName: root.data.orderDetail?.productName ?? "",
                urlPaymentPage: root.data.orderDetail?.urlPaymentPage ?? "",
                sellerAccountID: root.data.orderDetail?.sellerAccountID ?? "",
                sellerName: root.data.orderDetail?.sellerName ?? "",
                buyerName: root.data.orderDetail?.buyerName,
                buyerMobilePhone: root.data.orderDetail?.buyerMobilePhone,
                productPrice: root.data.orderDetail?.productPrice ?? 0,
                urlProductPhoto: root.data.orderDetail?.urlProductPhoto ?? "",
                createAt: root.data.orderDetail?.createAt ?? 0,
                expireTimePayment: root.data.orderDetail?.expireTimePayment ?? 0,
                noInvoice: root.data.orderDetail?.noInvoice,
                shipmentName: root.data.orderDetail?.shipmentName,
                shipmentService: root.data.orderDetail?.shipmentService,
                shipmentDuration: root.data.orderDetail?.shipmentDuration,
                shipmentCost: root.data.orderDetail?.shipmentCost,
                shipmentActualCost: root.data.orderDetail?.shipmentActualCost,
                totalAmount: root.data.orderDetail?.totalAmount,
                paymentName: root.data.orderDetail?.paymentName,
                paymentNumber: root.data.orderDetail?.paymentNumber,
                paymentType: root.data.orderDetail?.paymentType,
                productDescription: root.data.orderDetail?.productDescription ?? "",
                productCategoryID: root.data.orderDetail?.productCategoryID ?? "",
                productCategoryName: root.data.orderDetail?.productCategoryName ?? "",
                initiatorId: root.data.orderDetail?.initiatorId,
                initiatorName: root.data.orderDetail?.initiatorName,
                postDonationId: root.data.orderDetail?.postDonationId,
                urlInitiatorPhoto: root.data.orderDetail?.urlInitiatorPhoto,
                donationTitle: root.data.orderDetail?.donationTitle,
                urlDonationPhoto: root.data.orderDetail?.urlDonationPhoto,
                productType: root.data.orderDetail?.productType ?? "",
                commission: root.data.orderDetail?.commission ?? 0,
                modal: root.data.orderDetail?.modal ?? 0,
                resellerAccountID: root.data.orderDetail?.resellerAccountID ?? "",
                productOriginalID: root.data.orderDetail?.productOriginalID ?? "",
                urlSellerPhoto: root.data.orderDetail?.urlSellerPhoto ?? "",
                sellerUserName: root.data.orderDetail?.sellerUserName ?? "",
                isSellerVerified: root.data.orderDetail?.isSellerVerified ?? false
            ),
            amount: root.data.amount ?? 0,
            payment: DonationTransactionDetailOrderPaymentItem(
                amount: root.data.payment?.amount ?? 0,
                status: root.data.payment?.status ?? "",
                paymentAccount: DonationTransactionDetailOrderPaymentAccountItem(
                    name: root.data.payment?.paymentAccount?.name ?? "",
                    number: root.data.payment?.paymentAccount?.number ?? "",
                    billCode: root.data.payment?.paymentAccount?.billCode
                ),
                type: root.data.payment?.type ?? "",
                bank: DonationTransactionDetailBankItem(rawValue: root.data.payment?.bank ?? "") ?? .undifined
            ),
            orderShipment: DonationTransactionDetailOrderShipmentItem(
                status: root.data.orderShipment?.status ?? "",
                consignee: root.data.orderShipment?.consignee,
                notes: root.data.orderShipment?.notes ?? "",
                courier: root.data.orderShipment?.courier ?? "",
                duration: root.data.orderShipment?.duration ?? "",
                shipmentEstimation: root.data.orderShipment?.shipmentEstimation ?? "",
                shippedAt: root.data.orderShipment?.shippedAt,
                cost: root.data.orderShipment?.cost ?? 0,
                service: root.data.orderShipment?.service  ?? "",
                awbNumber: root.data.orderShipment?.awbNumber ?? "",
                bookingNumber: root.data.orderShipment?.bookingNumber ?? "",
                isWeightAdjustment: root.data.orderShipment?.isWeightAdjustment,
                actualCost: root.data.orderShipment?.actualCost,
                shippingLabelFileURL: root.data.orderShipment?.shippingLabelFileURL ?? "",
                differentCost: root.data.orderShipment?.differentCost,
                destinationID: root.data.orderShipment?.destinationID ?? "",
                destinationAddressID: root.data.orderShipment?.destinationAddressID ?? "",
                destinationLabel: root.data.orderShipment?.destinationLabel ?? "",
                destinationReceiverName: root.data.orderShipment?.destinationReceiverName ?? "",
                destinationSenderName: root.data.orderShipment?.destinationSenderName ?? "",
                destinationPhoneNumber: root.data.orderShipment?.destinationPhoneNumber ?? "",
                destinationProvince: root.data.orderShipment?.destinationProvince ?? "",
                destinationProvinceID: root.data.orderShipment?.destinationProvinceID ?? "",
                destinationCity: root.data.orderShipment?.destinationCity ?? "",
                destinationCityID: root.data.orderShipment?.destinationCityID ?? "",
                destinationPostalCode: root.data.orderShipment?.destinationPostalCode ?? "",
                destinationSubDistrict: root.data.orderShipment?.destinationSubDistrict ?? "",
                destinationSubDistrictID: root.data.orderShipment?.destinationSubDistrictID ?? "",
                destinationLatitude: root.data.orderShipment?.destinationLatitude ?? "",
                destinationLongitude: root.data.orderShipment?.destinationLongitude ?? "",
                destinationIsDefault: root.data.orderShipment?.destinationIsDefault ?? false,
                destinationIsDelivery: root.data.orderShipment?.destinationIsDelivery ?? false,
                destinationDetail: root.data.orderShipment?.destinationDetail ?? "",
                originID: root.data.orderShipment?.originID,
                originAddressID: root.data.orderShipment?.originAddressID ?? "",
                originLabel: root.data.orderShipment?.originLabel ?? "",
                originReceiverName: root.data.orderShipment?.originReceiverName ?? "",
                originSenderName: root.data.orderShipment?.originSenderName ?? "",
                originPhoneNumber: root.data.orderShipment?.originPhoneNumber ?? "",
                originProvince: root.data.orderShipment?.originProvince ?? "",
                originProvinceID: root.data.orderShipment?.originProvinceID ?? "",
                originCity: root.data.orderShipment?.originCity ?? "",
                originCityID: root.data.orderShipment?.originCityID ?? "",
                originPostalCode: root.data.orderShipment?.originPostalCode ?? "",
                originSubDistrict: root.data.orderShipment?.originSubDistrict ?? "",
                originSubDistrictID: root.data.orderShipment?.originSubDistrictID ?? "",
                originLatitude: root.data.orderShipment?.originLatitude ?? "",
                originLongitude: root.data.orderShipment?.originLongitude ?? "",
                originIsDefault: root.data.orderShipment?.originIsDefault ?? false,
                originIsDelivery: root.data.orderShipment?.originIsDelivery ?? false,
                originDetail: root.data.orderShipment?.originDetail ?? ""
            ),
            customer: DonationTransactionDetailOrderCustomerItem(
                id: root.data.customer?.id ?? "",
                username: root.data.customer?.username ?? "",
                name: root.data.customer?.name ?? "",
                bio: root.data.customer?.bio ?? "",
                photo: root.data.customer?.photo,
                birthDate: root.data.customer?.birthDate,
                gender: root.data.customer?.gender ?? "",
                isFollow: root.data.customer?.isFollow ?? false,
                isSeleb: root.data.customer?.isSeleb ?? false,
                mobile: root.data.customer?.mobile ?? "",
                email: root.data.customer?.email ?? "",
                accountType: root.data.customer?.accountType ?? "",
                isVerified: root.data.customer?.isVerified ?? false,
                note: root.data.customer?.note,
                isDisabled: root.data.customer?.isDisabled ?? false,
                isSeller: root.data.customer?.isSeller ?? false
            ),
            status: root.data.status ?? "",
            type: root.data.type ?? "",
            reasonRejected: root.data.reasonRejected ?? "",
            invoiceFileURL: root.data.invoiceFileURL ?? "",
            isOrderComplaint: root.data.isOrderComplaint ?? false,
            reviewStatus: root.data.reviewStatus ?? ""
        )
    }
}
