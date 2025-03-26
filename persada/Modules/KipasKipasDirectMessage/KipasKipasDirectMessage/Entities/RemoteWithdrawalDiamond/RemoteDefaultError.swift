//
//  RemoteDefaultError.swift
//  KipasKipasDirectMessage
//
//  Created by Muhammad Noor on 18/09/23.
//

import Foundation

public struct RemoteDefaultError: Codable {
    public let code, message: String?
    public let data: String?
}
