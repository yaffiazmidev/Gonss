//
//  OrderCellViewModel.swift
//  KipasKipas
//
//  Created by NOOR on 25/01/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

struct OrderCellViewModel: Equatable, Hashable {
	
	static func == (lhs: OrderCellViewModel, rhs: OrderCellViewModel) -> Bool {
		return lhs.identifier == rhs.identifier
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(identifier)
	}
	
	let identifier: UUID = UUID()
	let amount : Int
	let cost : Int
	let courier : String
	let createAt : Int
	let expireTimePayment : Int
	let id : String
	let noInvoice : String
	let orderStatus : String
	let paymentStatus : String
	let productId : String
	let productName : String
	let productPrice : Int
	let quantity : Int
	let sellerAccountId : String
	let sellerName : String
	let shipmentStatus : String?
	let urlPaymentPage : String
	let urlProductPhoto : String
	let virtualAccount : VirtualAccount?
    let isOrderComplaint: Bool
	var orderPages: String?
    let modifyAt: Int
    let reviewStatus: String?
    var productType: String?
    var productOriginalId: String?
    var resellerAccountId: String?
    var urlDonationPhoto: String?
    var productCategoryId: String?
    var productCategoryName: String?
    var commission, modal: Double?
    var donationTitle: String?
    var urlInitiatorPhoto: String?
    var receiverName: String?
    var sellerUserName: String?
	
	init?(value: StatusOrder?) {
		
		guard let amount = value?.amount,
					let cost = value?.cost,
					let courier = value?.courier,
					let createAt = value?.createAt,
					let expireTimePayment = value?.expireTimePayment,
					let id = value?.id,
					let noInvoice = value?.noInvoice,
					let orderStatus = value?.orderStatus,
					let paymentStatus = value?.paymentStatus,
					let productId = value?.productId,
					let productName = value?.productName,
					let productPrice = value?.productPrice,
					let quantity = value?.quantity,
					let sellerAccountId = value?.sellerAccountId,
					let sellerName = value?.sellerName,
					let urlPaymentPage = value?.urlPaymentPage,
					let urlProductPhoto = value?.urlProductPhoto,
                    let isOrderComplaint = value?.isOrderComplaint,
                    let modifyAt = value?.modifyAt else {
			return nil
		}
		
		if value?.virtualAccount == nil {
			self.virtualAccount = VirtualAccount(bank: "", vaNumber: "")
		} else {
			self.virtualAccount = value?.virtualAccount
		}
		
		if value?.shipmentStatus == nil {
			self.shipmentStatus = ""
		} else {
			self.shipmentStatus = value?.shipmentStatus
		}
		
        self.orderPages = value?.orderPages == nil ? "" : value?.orderPages
		self.reviewStatus = value?.reviewStatus == nil ? "" : value?.reviewStatus
        
        if value?.productType == nil {
            productType = ""
        } else {
            productType = value?.productType
        }
        
        if value?.productOriginalId == nil {
            productOriginalId = ""
        } else {
            productOriginalId = value?.productOriginalId
        }
        
        if value?.resellerAccountId == nil {
            resellerAccountId = ""
        } else {
            resellerAccountId = value?.resellerAccountId
        }
        
        if value?.urlDonationPhoto == nil {
            urlDonationPhoto = ""
        } else {
            urlDonationPhoto = value?.urlDonationPhoto
        }
        
        if value?.productCategoryId == nil {
            productCategoryId = ""
        } else {
            productCategoryId = value?.productCategoryId
        }
        
        if value?.productCategoryName == nil {
            productCategoryName = ""
        } else {
            productCategoryName = value?.productCategoryName
        }
        
        modal = value?.modal ?? 0
        commission = value?.commission ?? 0
        
        if value?.donationTitle == nil {
            donationTitle = ""
        } else {
            donationTitle = value?.donationTitle
        }
        
        if value?.urlInitiatorPhoto == nil {
            urlInitiatorPhoto = ""
        } else {
            urlInitiatorPhoto = value?.urlInitiatorPhoto
        }
        
        if value?.receiverName == nil {
            receiverName = ""
        } else {
            receiverName = value?.receiverName
        }
        
        if value?.sellerUserName == nil {
            sellerUserName = ""
        } else {
            sellerUserName = value?.sellerUserName
        }

		self.amount = amount
		self.cost = cost
		self.courier = courier
		self.createAt = createAt
		self.expireTimePayment = expireTimePayment
		self.id = id
		self.noInvoice = noInvoice
		self.orderStatus = orderStatus
		self.paymentStatus = paymentStatus
		self.productId = productId
		self.productName = productName
		self.productPrice = productPrice
		self.quantity = quantity
		self.sellerAccountId = sellerAccountId
		self.sellerName = sellerName
		self.urlPaymentPage = urlPaymentPage
		self.urlProductPhoto = urlProductPhoto
        self.isOrderComplaint = isOrderComplaint
        self.modifyAt = modifyAt
	}
}
