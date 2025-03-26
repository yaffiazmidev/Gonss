//
//  Model.swift
//  FeedCleeps
//
//  Created by PT.Koanba on 30/06/22.
//

import Foundation

// MARK: - DefaultResponse
public struct DefaultResponse: Codable {
    let code, data, message: String?
}

struct DeleteResponse: Codable {
    let code, message: String?
    let data: Bool?
}
