//
//  CallProfileDonationBadge.swift
//  KipasKipasCall
//
//  Created by Rahmat Trinanda Pramudya Amar on 23/12/23.
//

import Foundation

public struct CallProfileDonationBadge: Hashable {
    
    public let id: String
    public let name: String
    public let url: String
    public let min: Double
    public let max: Double
    public let level: Int
    public let isFlagUpdate: Bool
    public let globalRank: Int
    public let isShowBadge: Bool
    
    public init(id: String, name: String, url: String, min: Double, max: Double, level: Int, isFlagUpdate: Bool, globalRank: Int, isShowBadge: Bool) {
        self.id = id
        self.name = name
        self.url = url
        self.min = min
        self.max = max
        self.level = level
        self.isFlagUpdate = isFlagUpdate
        self.globalRank = globalRank
        self.isShowBadge = isShowBadge
    }
}
