//
//  RemoteDetailTransactionOrderItem.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 27/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct RemoteDetailTransactionOrderRoot: Codable {
    let code, message: String
    let data: RemoteDetailTransactionOrderItem
}

// MARK: - RemoteDetailTransactionOrderItem
struct RemoteDetailTransactionOrderItem: Codable {
    let id, noInvoice: String?
    let orderDetail: RemoteDetailTransactionOrderDetailItem?
    let amount: Int?
    let payment: RemoteDetailTransactionOrderPaymentItem?
    let orderShipment: RemoteDetailTransactionOrderShipmentItem?
    let customer: RemoteDetailTransactionOrderCustomerItem?
    let status, type: String?
    let reasonRejected: String?
    let invoiceFileURL: String?
    let isOrderComplaint: Bool?
    let reviewStatus: String?
}

// MARK: - Customer
struct RemoteDetailTransactionOrderCustomerItem: Codable {
    let id, username, name, bio: String?
    let photo, birthDate: String?
    let gender: String?
    let isFollow, isSeleb: Bool?
    let mobile, email, accountType: String?
    let isVerified: Bool?
    let note: String?
    let isDisabled, isSeller: Bool?
}

// MARK: - OrderDetail
struct RemoteDetailTransactionOrderDetailItem: Codable {
    let quantity: Int?
    let variant: String?
    let measurement: RemoteDetailTransactionOrderMeasurementItem?
    let feedId: String?
    let productID, productName: String?
    let urlPaymentPage: String?
    let sellerAccountID, sellerName: String?
    let buyerName, buyerMobilePhone: String?
    let productPrice: Int?
    let urlProductPhoto: String?
    let createAt, expireTimePayment: Int?
    let noInvoice, shipmentName, shipmentService, shipmentDuration: String?
    let shipmentCost, shipmentActualCost, totalAmount, paymentName: String?
    let paymentNumber, paymentType: String?
    let productDescription, productCategoryID, productCategoryName: String?
    let initiatorId, initiatorName, postDonationId, urlInitiatorPhoto: String?
    let donationTitle, urlDonationPhoto: String?
    let productType: String?
    let commission, modal: Int?
    let resellerAccountID, productOriginalID: String?
    let urlSellerPhoto: String?
    let sellerUserName: String?
    let isSellerVerified: Bool?
}

// MARK: - Measurement
struct RemoteDetailTransactionOrderMeasurementItem: Codable {
    let weight, length, height, width: Double?
}

// MARK: - OrderShipment
struct RemoteDetailTransactionOrderShipmentItem: Codable {
    let status: String?
    let consignee: String?
    let notes, courier, duration, shipmentEstimation: String?
    let shippedAt: Int?
    let cost: Int?
    let service, awbNumber, bookingNumber: String?
    let isWeightAdjustment: Bool?
    let actualCost: Int?
    let shippingLabelFileURL: String?
    let differentCost: Int?
    let destinationID: String?
    let destinationAddressID, destinationLabel, destinationReceiverName, destinationSenderName: String?
    let destinationPhoneNumber, destinationProvince, destinationProvinceID, destinationCity: String?
    let destinationCityID, destinationPostalCode, destinationSubDistrict, destinationSubDistrictID: String?
    let destinationLatitude, destinationLongitude: String?
    let destinationIsDefault, destinationIsDelivery: Bool?
    let destinationDetail: String?
    let originID: String?
    let originAddressID, originLabel, originReceiverName, originSenderName: String?
    let originPhoneNumber, originProvince, originProvinceID, originCity: String?
    let originCityID, originPostalCode, originSubDistrict, originSubDistrictID: String?
    let originLatitude, originLongitude: String?
    let originIsDefault, originIsDelivery: Bool?
    let originDetail: String?
}

// MARK: - Payment
struct RemoteDetailTransactionOrderPaymentItem: Codable {
    let amount: Int?
    let status: String?
    let paymentAccount: RemoteDetailTransactionOrderPaymentAccountItem?
    let type, bank: String?
}

// MARK: - PaymentAccount
struct RemoteDetailTransactionOrderPaymentAccountItem: Codable {
    let name, number: String?
    let billCode: String?
}
