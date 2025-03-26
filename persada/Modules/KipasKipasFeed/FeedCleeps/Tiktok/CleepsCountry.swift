//
//  TiktokCountry.swift
//  KipasKipas
//
//  Created by PT.Koanba on 20/06/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

public enum CleepsCountry: String {
    case indo = "tiktok"
    case china = "chinatiktok"
    case korea = "koreacleeps"
    case thailand = "thailandcleeps"
    
    var code: String {
        switch self {
        case .indo: return "id"
        case .china: return "cn"
        case .korea: return "kr"
        case .thailand: return "th"
        }
    }
    
    var tag: String {
        switch self {
        case .indo: return "INDO"
        case .china: return "CHINA"
        case .korea: return "KOREA"
        case .thailand: return "THAI"
        }
    }
}
