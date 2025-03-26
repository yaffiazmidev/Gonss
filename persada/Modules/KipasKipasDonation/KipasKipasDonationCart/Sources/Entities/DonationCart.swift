//
//  DonationCart.swift
//  KipasKipasShared
//
//  Created by Rahmat Trinanda Pramudya Amar on 31/01/24.
//

import Foundation

public struct DonationCart: Codable {
    public let id: String
    public let title: String
    public let accountId: String
    public let accountName: String
    public var amount: Double
    public var checked: Bool
    
    public init(id: String, title: String, accountId: String, accountName: String, amount: Double, checked: Bool = true) {
        self.id = id
        self.title = title
        self.accountId = accountId
        self.accountName = accountName
        self.amount = amount
        self.checked = checked
    }
}
