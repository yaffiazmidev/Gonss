//
//  DonationCartOrderDetail.swift
//  KipasKipasDonationCart
//
//  Created by Rahmat Trinanda Pramudya Amar on 29/02/24.
//

import Foundation

public struct DonationCartOrderDetail: Codable {
    let id: String
    let orderDetail: DonationCartOrderDataDetail
    
    init(id: String, orderDetail: DonationCartOrderDataDetail) {
        self.id = id
        self.orderDetail = orderDetail
    }
}

public struct DonationCartOrderDataDetail: Codable {
    let urlPaymentPage: String
    
    init(urlPaymentPage: String) {
        self.urlPaymentPage = urlPaymentPage
    }
}
