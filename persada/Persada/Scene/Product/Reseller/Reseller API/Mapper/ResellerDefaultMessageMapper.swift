//
//  ResellerDefaultMessageMapper.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 28/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

final class ResellerDefaultMessageMapper {
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> ResellerProductDefaultItem {
        guard response.isOK else {
            guard let error = try? JSONDecoder().decode(KKErrorNetworkRemoteResponse.self, from: data) else {
                throw KKNetworkError.invalidData
            }
            throw KKNetworkError.responseFailure(KKErrorNetworkResponse.fromRemote(error))
        }
        
        guard let item = try? JSONDecoder().decode(RemoteResellerDefaultResponse.self, from: data) else {
            throw KKNetworkError.invalidData
        }

        return ResellerProductDefaultItem(message: item.message)
    }
}

struct ResellerProductDefaultItem {
    let message: String
}
