//
//  CoinInAppPurchaseValidateMapper.swift
//  KipasKipasPaymentInAppPurchase
//
//  Created by Rahmat Trinanda Pramudya Amar on 18/10/23.
//

import Foundation

final class CoinInAppPurchaseValidateMapper {
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> CoinInAppPurchaseValidateData {
        if !response.isOK {
            if let error = try? JSONDecoder().decode(RemoteCoinInAppPurchaseValidateError.self, from: data) {
                if response.statusCode == 409 && error.code == "5009"{
                    throw CoinInAppPurchaseValidateError.alreadyValidated
                }
            }
            throw CoinInAppPurchaseValidateError.connectivity
        }
        
        guard response.isOK, let root = try? JSONDecoder().decode(RemoteCoinInAppPurchaseValidate.self, from: data), let data = root.data else {
            throw CoinInAppPurchaseValidateError.invalidData
        }
        
        return CoinInAppPurchaseValidateData(
            orderCoin: CoinInAppPurchaseValidateOrder(
                id: data.orderCoin?.id ?? "",
                createAt: data.orderCoin?.createAt ?? "",
                storeOrderId: data.orderCoin?.storeOrderId ?? "",
                amount: data.orderCoin?.amount ?? 0,
                status: data.orderCoin?.status,
                customer: CoinInAppPurchaseValidateCustomer(
                    id: data.orderCoin?.customer?.id ?? "",
                    username: data.orderCoin?.customer?.username ?? "",
                    bio: data.orderCoin?.customer?.bio,
                    photo: data.orderCoin?.customer?.photo,
                    birthDate: data.orderCoin?.customer?.birthDate ?? "",
                    gender: data.orderCoin?.customer?.gender ?? "",
                    isFollow: data.orderCoin?.customer?.isFollow,
                    isSeleb: data.orderCoin?.customer?.isSeleb,
                    mobile: data.orderCoin?.customer?.mobile ?? "",
                    email: data.orderCoin?.customer?.email ?? "",
                    accountType: data.orderCoin?.customer?.accountType,
                    isVerified: data.orderCoin?.customer?.isVerified,
                    note: data.orderCoin?.customer?.note,
                    isDisabled: data.orderCoin?.customer?.isDisabled,
                    isSeller: data.orderCoin?.customer?.isSeller,
                    totalDonation: data.orderCoin?.customer?.totalDonation,
                    levelBadge: data.orderCoin?.customer?.levelBadge,
                    donationBadgeId: data.orderCoin?.customer?.donationBadgeId,
                    urlBadge: data.orderCoin?.customer?.urlBadge,
                    donationBadge: data.orderCoin?.customer?.donationBadge,
                    isShowBadge: data.orderCoin?.customer?.isShowBadge,
                    referralCode: data.orderCoin?.customer?.referralCode
                ),
                detail: CoinInAppPurchaseValidateOrderDetail(
                    id: data.orderCoin?.orderDetailCoin?.id ?? "",
                    coinId: data.orderCoin?.orderDetailCoin?.coinId ?? "",
                    coinName: data.orderCoin?.orderDetailCoin?.coinName ?? "",
                    coinPrice: data.orderCoin?.orderDetailCoin?.coinPrice ?? 0,
                    coinAmount: data.orderCoin?.orderDetailCoin?.coinAmount ?? 0,
                    storeProductId: data.orderCoin?.orderDetailCoin?.storeProductId ?? "",
                    qty: data.orderCoin?.orderDetailCoin?.qty ?? 0,
                    storeEventTime: data.orderCoin?.orderDetailCoin?.storeEventTime ?? "",
                    totalAmount: data.orderCoin?.orderDetailCoin?.totalAmount ?? 0
                ),
                noInvoice: data.orderCoin?.noInvoice ?? "",
                invoiceFileUrl: data.orderCoin?.invoiceFileUrl,
                store: CoinInAppPurchaseValidateStore(
                    id: data.orderCoin?.store?.id ?? "",
                    storeName: data.orderCoin?.store?.storeName ?? ""
                ),
                payment: data.orderCoin?.payment
            ),
            notificationId: data.notificationId ?? ""
        )
    }
}

private extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }
    
    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
