//
//  HTTPURLResponse+Extension.swift
//  KipasKipasNetworking
//
//  Created by PT.Koanba on 01/04/22.
//

import Foundation

public extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }
    
    public var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
