//
//  ResellerDefaultMapper.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 25/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

final class ResellerDefaultMapper {
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws {
        guard response.isOK else {
            guard let error = try? JSONDecoder().decode(KKErrorNetworkRemoteResponse.self, from: data) else {
                throw KKNetworkError.invalidData
            }
            throw KKNetworkError.responseFailure(KKErrorNetworkResponse.fromRemote(error))
        }
        
        guard let _ = try? JSONDecoder().decode(RemoteResellerDefaultResponse.self, from: data) else {
            throw KKNetworkError.invalidData
        }
         
        return
    }
}
