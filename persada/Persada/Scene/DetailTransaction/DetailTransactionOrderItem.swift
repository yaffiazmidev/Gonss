//
//  DetailTransactionOrderItem.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 27/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

// MARK: - DetailTransactionOrderItem
struct DetailTransactionOrderItem: Hashable {
    
    let id, noInvoice: String
    let orderDetail: DetailTransactionOrderDetailItem
    let amount: Int
    let payment: DetailTransactionOrderPaymentItem
    let orderShipment: DetailTransactionOrderShipmentItem
    let customer: DetailTransactionOrderCustomerItem
    let status, type: String
    let reasonRejected: String?
    let invoiceFileURL: String
    let isOrderComplaint: Bool
    let reviewStatus: String
    
    init(id: String, noInvoice: String, orderDetail: DetailTransactionOrderDetailItem, amount: Int, payment: DetailTransactionOrderPaymentItem, orderShipment: DetailTransactionOrderShipmentItem, customer: DetailTransactionOrderCustomerItem, status: String, type: String, reasonRejected: String?, invoiceFileURL: String, isOrderComplaint: Bool, reviewStatus: String) {
        self.id = id
        self.noInvoice = noInvoice
        self.orderDetail = orderDetail
        self.amount = amount
        self.payment = payment
        self.orderShipment = orderShipment
        self.customer = customer
        self.status = status
        self.type = type
        self.reasonRejected = reasonRejected
        self.invoiceFileURL = invoiceFileURL
        self.isOrderComplaint = isOrderComplaint
        self.reviewStatus = reviewStatus
    }
}

// MARK: - Customer
struct DetailTransactionOrderCustomerItem: Hashable {
    
    let id, username, name, bio: String
    let photo, birthDate: String?
    let gender: String
    let isFollow, isSeleb: Bool
    let mobile, email, accountType: String
    let isVerified: Bool
    let note: String?
    let isDisabled, isSeller: Bool
    
    init(id: String, username: String, name: String, bio: String, photo: String?, birthDate: String?, gender: String, isFollow: Bool, isSeleb: Bool, mobile: String, email: String, accountType: String, isVerified: Bool, note: String?, isDisabled: Bool, isSeller: Bool) {
        self.id = id
        self.username = username
        self.name = name
        self.bio = bio
        self.photo = photo
        self.birthDate = birthDate
        self.gender = gender
        self.isFollow = isFollow
        self.isSeleb = isSeleb
        self.mobile = mobile
        self.email = email
        self.accountType = accountType
        self.isVerified = isVerified
        self.note = note
        self.isDisabled = isDisabled
        self.isSeller = isSeller
    }
}

// MARK: - OrderDetail
struct DetailTransactionOrderDetailItem: Hashable {
    
    let quantity: Int
    let variant: String?
    let measurement: DetailTransactionOrderMeasurementItem
    let feedId: String?
    let productID, productName: String
    let urlPaymentPage: String
    let sellerAccountID, sellerName: String
    let buyerName, buyerMobilePhone: String?
    let productPrice: Int
    let urlProductPhoto: String
    let createAt, expireTimePayment: Int
    let noInvoice, shipmentName, shipmentService, shipmentDuration: String?
    let shipmentCost, shipmentActualCost, totalAmount, paymentName: String?
    let paymentNumber, paymentType: String?
    let productDescription, productCategoryID, productCategoryName: String
    let initiatorId, initiatorName, postDonationId, urlInitiatorPhoto: String?
    let donationTitle, urlDonationPhoto: String?
    let productType: String
    let commission, modal: Int
    let resellerAccountID, productOriginalID: String
    let urlSellerPhoto: String
    let sellerUserName: String
    let isSellerVerified: Bool
    
    init(quantity: Int, variant: String?, measurement: DetailTransactionOrderMeasurementItem, feedId: String?, productID: String, productName: String, urlPaymentPage: String, sellerAccountID: String, sellerName: String, buyerName: String?, buyerMobilePhone: String?, productPrice: Int, urlProductPhoto: String, createAt: Int, expireTimePayment: Int, noInvoice: String?, shipmentName: String?, shipmentService: String?, shipmentDuration: String?, shipmentCost: String?, shipmentActualCost: String?, totalAmount: String?, paymentName: String?, paymentNumber: String?, paymentType: String?, productDescription: String, productCategoryID: String, productCategoryName: String, initiatorId: String?, initiatorName: String?, postDonationId: String?, urlInitiatorPhoto: String?, donationTitle: String?, urlDonationPhoto: String?, productType: String, commission: Int, modal: Int, resellerAccountID: String, productOriginalID: String, urlSellerPhoto: String, sellerUserName: String, isSellerVerified: Bool) {
        self.quantity = quantity
        self.variant = variant
        self.measurement = measurement
        self.feedId = feedId
        self.productID = productID
        self.productName = productName
        self.urlPaymentPage = urlPaymentPage
        self.sellerAccountID = sellerAccountID
        self.sellerName = sellerName
        self.buyerName = buyerName
        self.buyerMobilePhone = buyerMobilePhone
        self.productPrice = productPrice
        self.urlProductPhoto = urlProductPhoto
        self.createAt = createAt
        self.expireTimePayment = expireTimePayment
        self.noInvoice = noInvoice
        self.shipmentName = shipmentName
        self.shipmentService = shipmentService
        self.shipmentDuration = shipmentDuration
        self.shipmentCost = shipmentCost
        self.shipmentActualCost = shipmentActualCost
        self.totalAmount = totalAmount
        self.paymentName = paymentName
        self.paymentNumber = paymentNumber
        self.paymentType = paymentType
        self.productDescription = productDescription
        self.productCategoryID = productCategoryID
        self.productCategoryName = productCategoryName
        self.initiatorId = initiatorId
        self.initiatorName = initiatorName
        self.postDonationId = postDonationId
        self.urlInitiatorPhoto = urlInitiatorPhoto
        self.donationTitle = donationTitle
        self.urlDonationPhoto = urlDonationPhoto
        self.productType = productType
        self.commission = commission
        self.modal = modal
        self.resellerAccountID = resellerAccountID
        self.productOriginalID = productOriginalID
        self.urlSellerPhoto = urlSellerPhoto
        self.sellerUserName = sellerUserName
        self.isSellerVerified = isSellerVerified
    }
}

// MARK: - Measurement
struct DetailTransactionOrderMeasurementItem: Hashable {
    
    let weight, length, height, width: Double
    
    init(weight: Double, length: Double, height: Double, width: Double) {
        self.weight = weight
        self.length = length
        self.height = height
        self.width = width
    }
}

// MARK: - OrderShipment
struct DetailTransactionOrderShipmentItem: Hashable {
    let status: String
    let consignee: String?
    let notes, courier, duration, shipmentEstimation: String
    let shippedAt: Int?
    let cost: Int
    let service, awbNumber, bookingNumber: String
    let isWeightAdjustment: Bool?
    let actualCost: Int?
    let shippingLabelFileURL: String
    let differentCost: Int?
    let destinationID: String?
    let destinationAddressID, destinationLabel, destinationReceiverName, destinationSenderName: String
    let destinationPhoneNumber, destinationProvince, destinationProvinceID, destinationCity: String
    let destinationCityID, destinationPostalCode, destinationSubDistrict, destinationSubDistrictID: String
    let destinationLatitude, destinationLongitude: String
    let destinationIsDefault, destinationIsDelivery: Bool
    let destinationDetail: String
    let originID: String?
    let originAddressID, originLabel, originReceiverName, originSenderName: String
    let originPhoneNumber, originProvince, originProvinceID, originCity: String
    let originCityID, originPostalCode, originSubDistrict, originSubDistrictID: String
    let originLatitude, originLongitude: String
    let originIsDefault, originIsDelivery: Bool
    let originDetail: String
    
    init(status: String, consignee: String?, notes: String, courier: String, duration: String, shipmentEstimation: String, shippedAt: Int?, cost: Int, service: String, awbNumber: String, bookingNumber: String, isWeightAdjustment: Bool?, actualCost: Int?, shippingLabelFileURL: String, differentCost: Int?, destinationID: String?, destinationAddressID: String, destinationLabel: String, destinationReceiverName: String, destinationSenderName: String, destinationPhoneNumber: String, destinationProvince: String, destinationProvinceID: String, destinationCity: String, destinationCityID: String, destinationPostalCode: String, destinationSubDistrict: String, destinationSubDistrictID: String, destinationLatitude: String, destinationLongitude: String, destinationIsDefault: Bool, destinationIsDelivery: Bool, destinationDetail: String, originID: String?, originAddressID: String, originLabel: String, originReceiverName: String, originSenderName: String, originPhoneNumber: String, originProvince: String, originProvinceID: String, originCity: String, originCityID: String, originPostalCode: String, originSubDistrict: String, originSubDistrictID: String, originLatitude: String, originLongitude: String, originIsDefault: Bool, originIsDelivery: Bool, originDetail: String) {
        self.status = status
        self.consignee = consignee
        self.notes = notes
        self.courier = courier
        self.duration = duration
        self.shipmentEstimation = shipmentEstimation
        self.shippedAt = shippedAt
        self.cost = cost
        self.service = service
        self.awbNumber = awbNumber
        self.bookingNumber = bookingNumber
        self.isWeightAdjustment = isWeightAdjustment
        self.actualCost = actualCost
        self.shippingLabelFileURL = shippingLabelFileURL
        self.differentCost = differentCost
        self.destinationID = destinationID
        self.destinationAddressID = destinationAddressID
        self.destinationLabel = destinationLabel
        self.destinationReceiverName = destinationReceiverName
        self.destinationSenderName = destinationSenderName
        self.destinationPhoneNumber = destinationPhoneNumber
        self.destinationProvince = destinationProvince
        self.destinationProvinceID = destinationProvinceID
        self.destinationCity = destinationCity
        self.destinationCityID = destinationCityID
        self.destinationPostalCode = destinationPostalCode
        self.destinationSubDistrict = destinationSubDistrict
        self.destinationSubDistrictID = destinationSubDistrictID
        self.destinationLatitude = destinationLatitude
        self.destinationLongitude = destinationLongitude
        self.destinationIsDefault = destinationIsDefault
        self.destinationIsDelivery = destinationIsDelivery
        self.destinationDetail = destinationDetail
        self.originID = originID
        self.originAddressID = originAddressID
        self.originLabel = originLabel
        self.originReceiverName = originReceiverName
        self.originSenderName = originSenderName
        self.originPhoneNumber = originPhoneNumber
        self.originProvince = originProvince
        self.originProvinceID = originProvinceID
        self.originCity = originCity
        self.originCityID = originCityID
        self.originPostalCode = originPostalCode
        self.originSubDistrict = originSubDistrict
        self.originSubDistrictID = originSubDistrictID
        self.originLatitude = originLatitude
        self.originLongitude = originLongitude
        self.originIsDefault = originIsDefault
        self.originIsDelivery = originIsDelivery
        self.originDetail = originDetail
    }
}

// MARK: - Payment
struct DetailTransactionOrderPaymentItem: Hashable {
    let amount: Int
    let status: String
    let paymentAccount: DetailTransactionOrderPaymentAccountItem
    let type: String
    let bank: DetailTransactionBankItem
    
    init(amount: Int, status: String, paymentAccount: DetailTransactionOrderPaymentAccountItem, type: String, bank: DetailTransactionBankItem) {
        self.amount = amount
        self.status = status
        self.paymentAccount = paymentAccount
        self.type = type
        self.bank = bank
    }
}

// MARK: - PaymentAccount
struct DetailTransactionOrderPaymentAccountItem: Hashable {
    let name, number: String
    let billCode: String?
    
    init(name: String, number: String, billCode: String?) {
        self.name = name
        self.number = number
        self.billCode = billCode
    }
}
