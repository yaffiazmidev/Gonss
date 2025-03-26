//
//  UpdateCourierResponse.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 18/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

import Foundation

// MARK: - UpdateCourierResult
struct UpdateCourierResult: Codable {
		let code, message: String?
		let data: CourierData?
}

// MARK: - DataClass
struct CourierData: Codable {
		let id: String?
		let logisticProvider: LogisticProvider?
		let account: Profile?
		let isActive: Bool?
}

// MARK: - LogisticProvider
struct LogisticProvider: Codable {
		let id, createBy, createAt, modifyBy: String?
		let modifyAt: String?
		let isDeleted: Bool?
		let logisticName: String?
		let logisticService: String?
		let isCashless, isAutoAWB, isActive, isInstantCourier: Bool?
}
