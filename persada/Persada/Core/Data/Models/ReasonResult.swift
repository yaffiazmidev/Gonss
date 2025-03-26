//
//  ReasonResult.swift
//  Persada
//
//  Created by Muhammad Noor on 19/05/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

// MARK: - Reason
struct ReasonResult: Codable {
    var code, message: String?
    var data: [Reason]?
}

// MARK: - Reason
struct Reason: Codable {
    var id, value, type: String?
}

