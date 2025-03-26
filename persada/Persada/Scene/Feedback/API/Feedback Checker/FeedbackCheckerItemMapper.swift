//
//  FeedbackCheckerItemMapper.swift
//  KipasKipas
//
//  Created by PT.Koanba on 08/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

class FeedbackCheckerItemMapper {
    
    private struct Root: Decodable {
        private let code, message: String
        private let data: Checked
        
        private struct Checked: Decodable {
            let hasFeedback: Bool
        }
        
        var item: FeedbackCheckerItem {
            FeedbackCheckerItem(hasFeedback: data.hasFeedback)
        }
    }

    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> FeedbackCheckerItem {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        return root.item
    }
}
