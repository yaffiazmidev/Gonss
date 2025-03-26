//
//  FanBaseArray.swift
//  Persada
//
//  Created by Muhammad Noor on 09/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

// MARK: - Fanbase
struct FanbaseArray: Codable {
    let data: [Fanbase]
}

// MARK: - Fanbase
struct Fanbase: Codable {
    let id, name, username: String
    let photo: String
    let isVerified: Bool
    let member: Int
}
