//
//  TransactionProductResult.swift
//  KipasKipas
//
//  Created by movan on 13/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

struct TransactionProductResult: Codable {
	let code : String?
	let data : TransactionProduct?
	let message : String?
	
	enum CodingKeys: String, CodingKey {
		case code = "code"
		case data = "data"
		case message = "message"
	}
}

struct TransactionDonationResult: Codable {
	let code : String?
	let data : TransactionDonation?
	let message : String?
	
	enum CodingKeys: String, CodingKey {
		case code = "code"
		case data = "data"
		case message = "message"
	}
}

struct TransactionProduct: Codable {
	
	let amount : Int?
	let customer : Profile?
	let id : String?
	let noInvoice : String?
	let orderDetail : OrderDetailProduct?
	let orderShipment : OrderShipmentProduct?
	let payment : TransactionPayment?
	let status : String?
	let type : String?
	let reasonRejected : String?
	let invoiceFileUrl : String?
    let isOrderComplaint: Bool?
    let reviewStatus: String?
	
	enum CodingKeys: String, CodingKey {
		case amount = "amount"
		case customer = "customer"
		case id = "id"
		case noInvoice = "noInvoice"
		case orderDetail = "orderDetail"
		case orderShipment = "orderShipment"
		case payment = "payment"
		case status = "status"
		case type = "type"
		case reasonRejected = "reasonRejected"
		case invoiceFileUrl
        case isOrderComplaint = "isOrderComplaint"
        case reviewStatus = "reviewStatus"
	}
	
}

struct TransactionDonation: Codable {
	
	let amount : Int?
	let customer : Profile?
	let id : String?
	let no : String?
	let orderDetail : OrderDetailProduct?
	let payment : TransactionPayment?
	let status : String?
	let type : String?
	
	enum CodingKeys: String, CodingKey {
		case amount = "amount"
		case customer = "customer"
		case id = "id"
		case no = "no"
		case orderDetail = "orderDetail"
		case payment = "payment"
		case status = "status"
		case type = "type"
	}
	
}

struct TransactionPayment : Codable {
	
	let amount : Int?
	let bank : String?
	let paymentAccount : PaymentAccount?
	let status : String?
	let type : String?
	
	enum CodingKeys: String, CodingKey {
		case amount = "amount"
		case bank = "bank"
		case paymentAccount = "paymentAccount"
		case status = "status"
		case type = "type"
	}
	
}

struct PaymentAccount : Codable {
	
	let name : String?
	let number : String?
	
	enum CodingKeys: String, CodingKey {
		case name = "name"
		case number = "number"
	}
	
}

struct OrderShipmentProduct : Codable {
	
	let actualCost : Double?
	let awbNumber : String?
	let bookingNumber : String?
	let consignee : String?
	let cost : Int?
	let courier : String?
	let destinationCity : String?
	let destinationCityId : String?
	let destinationDetail : String?
	let destinationId : String?
	let destinationIsDefault : Bool?
	let destinationIsDelivery : Bool?
	let destinationLabel : String?
	let destinationLatitude : String?
	let destinationLongitude : String?
	let destinationPhoneNumber : String?
	let destinationPostalCode : String?
	let destinationProvince : String?
	let destinationProvinceId : String?
	let destinationReceiverName : String?
	let destinationSenderName : String?
	let destinationSubDistrict : String?
	let destinationSubDistrictId : String?
	let differentCost : Int?
	let duration : String?
	let isWeightAdjustment : Bool?
	let notes : String?
	let originCity : String?
	let originCityId : String?
	let originDetail : String?
	let originId : String?
	let originIsDefault : Bool?
	let originIsDelivery : Bool?
	let originLabel : String?
	let originLatitude : String?
	let originLongitude : String?
	let originPhoneNumber : String?
	let originPostalCode : String?
	let originProvince : String?
	let originProvinceId : String?
	let originReceiverName : String?
	let originSenderName : String?
	let originSubDistrict : String?
	let originSubDistrictId : String?
	let service : String?
	let shipmentEstimation : String?
	let shippedAt : Double?
	let shippingLabelFileUrl : String?
	let status : String?
	
	enum CodingKeys: String, CodingKey {
		case actualCost = "actualCost"
		case awbNumber = "awbNumber"
		case bookingNumber = "bookingNumber"
		case consignee = "consignee"
		case cost = "cost"
		case courier = "courier"
		case destinationCity = "destinationCity"
		case destinationCityId = "destinationCityId"
		case destinationDetail = "destinationDetail"
		case destinationId = "destinationId"
		case destinationIsDefault = "destinationIsDefault"
		case destinationIsDelivery = "destinationIsDelivery"
		case destinationLabel = "destinationLabel"
		case destinationLatitude = "destinationLatitude"
		case destinationLongitude = "destinationLongitude"
		case destinationPhoneNumber = "destinationPhoneNumber"
		case destinationPostalCode = "destinationPostalCode"
		case destinationProvince = "destinationProvince"
		case destinationProvinceId = "destinationProvinceId"
		case destinationReceiverName = "destinationReceiverName"
		case destinationSenderName = "destinationSenderName"
		case destinationSubDistrict = "destinationSubDistrict"
		case destinationSubDistrictId = "destinationSubDistrictId"
		case differentCost = "differentCost"
		case duration = "duration"
		case isWeightAdjustment = "isWeightAdjustment"
		case notes = "notes"
		case originCity = "originCity"
		case originCityId = "originCityId"
		case originDetail = "originDetail"
		case originId = "originId"
		case originIsDefault = "originIsDefault"
		case originIsDelivery = "originIsDelivery"
		case originLabel = "originLabel"
		case originLatitude = "originLatitude"
		case originLongitude = "originLongitude"
		case originPhoneNumber = "originPhoneNumber"
		case originPostalCode = "originPostalCode"
		case originProvince = "originProvince"
		case originProvinceId = "originProvinceId"
		case originReceiverName = "originReceiverName"
		case originSenderName = "originSenderName"
		case originSubDistrict = "originSubDistrict"
		case originSubDistrictId = "originSubDistrictId"
		case service = "service"
		case shipmentEstimation = "shipmentEstimation"
		case shippedAt = "shippedAt"
		case shippingLabelFileUrl = "shippingLabelFileUrl"
		case status = "status"
	}
	
}

struct OrderDetailProduct : Codable {
	
	let buyerMobilePhone : String?
	let buyerName : String?
	let createAt : Int?
	let expireTimePayment : Int?
	let feedId : String?
	let measurement : ProductMeasurement?
	let noInvoice : String?
	let paymentName : String?
	let paymentNumber : String?
	let paymentType : String?
	let productId : String?
	let productName : String?
	let productPrice : Double?
	let quantity : Int?
	let sellerAccountId : String?
	let sellerName : String?
	let shipmentActualCost : Double?
	let shipmentCost : Double?
	let shipmentDuration : String?
	let shipmentName : String?
	let shipmentService : String?
	let totalAmount : Int?
	let urlPaymentPage : String?
	let urlProductPhoto : String?
	let variant : String?
    let productDescription, productCategoryId, productCategoryName: String?
    let postDonationId: String?
    let productOriginalId: String?
    let productType: String?
    let commission, modal: Double?
    let urlSellerPhoto: String?
    let sellerUsername: String?
    let isSellerVerified: Bool?
    let initiatorId: String?
    let initiatorName: String?
    let urlInitiatorPhoto: String?
    let donationTitle: String?
    let urlDonationPhoto: String?
    let resellerAccountId: String?
	
	enum CodingKeys: String, CodingKey {
		case buyerMobilePhone = "buyerMobilePhone"
		case buyerName = "buyerName"
		case createAt = "createAt"
		case expireTimePayment = "expireTimePayment"
		case feedId = "feedId"
		case measurement = "measurement"
		case noInvoice = "noInvoice"
		case paymentName = "paymentName"
		case paymentNumber = "paymentNumber"
		case paymentType = "paymentType"
		case productId = "productId"
		case productName = "productName"
		case productPrice = "productPrice"
		case quantity = "quantity"
		case sellerAccountId = "sellerAccountId"
		case sellerName = "sellerName"
		case shipmentActualCost = "shipmentActualCost"
		case shipmentCost = "shipmentCost"
		case shipmentDuration = "shipmentDuration"
		case shipmentName = "shipmentName"
		case shipmentService = "shipmentService"
		case totalAmount = "totalAmount"
		case urlPaymentPage = "urlPaymentPage"
		case urlProductPhoto = "urlProductPhoto"
		case variant = "variant"
        case productDescription = "productDescription"
        case productCategoryId
        case productCategoryName
        case postDonationId
        case productOriginalId = "productOriginalId"
        case productType = "productType"
        case commission = "commission"
        case modal = "modal"
        case urlSellerPhoto = "urlSellerPhoto"
        case sellerUsername = "sellerUsername"
        case isSellerVerified = "isSellerVerified"
        case initiatorId = "initiatorId"
        case initiatorName = "initiatorName"
        case urlInitiatorPhoto = "urlInitiatorPhoto"
        case donationTitle
        case urlDonationPhoto
        case resellerAccountId
	}
}
