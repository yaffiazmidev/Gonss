//
//  RemoteCurrencyHistoryData.swift
//
//  Created by DENAZMI on 28/08/23
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct GrageRule: Codable {
    public let consumptionGrade: Int?
    public let consumptionPoints: Int?

   public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.consumptionGrade = try container.decodeIfPresent(Int.self, forKey: .consumptionGrade)
        self.consumptionPoints = try container.decodeIfPresent(Int.self, forKey: .consumptionPoints)
    }
}

public struct RemoteBalancePointsData: Codable {
    
    enum CodingKeys: String, CodingKey {
        case accountId
        case accountName
        case accountPhoto
        case consumptionPoints
        case consumptionGrade
        case lackPoints
        case consumptionGradeRuleList
    }
    
    public var accountId: Int?
    public var accountName: String?
    public var accountPhoto: String?
    public var consumptionPoints: Int?
    public var consumptionGrade: Int?
    public var lackPoints: Int?
    public var consumptionGradeRuleList: [GrageRule]?
    
     
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.accountId = try container.decodeIfPresent(Int.self, forKey: .accountId)
        self.accountName = try container.decodeIfPresent(String.self, forKey: .accountName)
        self.accountPhoto = try container.decodeIfPresent(String.self, forKey: .accountPhoto)
        self.consumptionPoints = try container.decodeIfPresent(Int.self, forKey: .consumptionPoints)
        self.consumptionGrade = try container.decodeIfPresent(Int.self, forKey: .consumptionGrade)
        self.lackPoints = try container.decodeIfPresent(Int.self, forKey: .lackPoints)
        self.consumptionGradeRuleList = try container.decodeIfPresent([GrageRule].self, forKey: .consumptionGradeRuleList)
    }
    
}
