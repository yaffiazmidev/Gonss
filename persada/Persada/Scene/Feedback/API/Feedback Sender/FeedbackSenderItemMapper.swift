//
//  FeedbackSenderItemMapper.swift
//  KipasKipas
//
//  Created by PT.Koanba on 06/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class FeedbackSenderItemMapper {
    
    private struct Root: Decodable {
        private let code, message: String
        
        var item: FeedbackSenderItem {
            FeedbackSenderItem(code: code, message: message)
        }
    }

    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> FeedbackSenderItem {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return root.item
    }
}
