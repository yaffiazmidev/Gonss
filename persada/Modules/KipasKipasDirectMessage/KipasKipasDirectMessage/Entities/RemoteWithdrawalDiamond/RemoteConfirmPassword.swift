//
//  RemoteConfirmPassword.swift
//  KipasKipasDirectMessage
//
//  Created by Muhammad Noor on 18/09/23.
//

import Foundation

public struct RemoteConfirmPassword: Codable {
    public let code, message: String?
    public let data: Bool?
}
