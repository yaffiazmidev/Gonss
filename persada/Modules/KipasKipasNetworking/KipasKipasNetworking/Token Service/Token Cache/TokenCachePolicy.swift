//
//  TokenCachePolicy.swift
//  KipasKipasNetworking
//
//  Created by PT.Koanba on 06/04/22.
//

import Foundation

public final class TokenCachePolicy {
    private init() {}
    
    public static func validate(_ currentDate: Date = Date(), expiredDate: Date) -> Bool {
        return currentDate < expiredDate
    }
}
