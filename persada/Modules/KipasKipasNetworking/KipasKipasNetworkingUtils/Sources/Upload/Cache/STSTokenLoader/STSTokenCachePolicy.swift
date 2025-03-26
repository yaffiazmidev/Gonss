//
//  STSTokenCachePolicy.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 16/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

class STSTokenCachePolicy {
    static func validate(_ currentDate: Date = Date(), expiredDate: Date) -> Bool { 
        let interval = expiredDate.timeIntervalSince(Date())
        return   interval > (5*60)
//        let minutes = getMinutesDifferenceFromTwoDates(start: currentDate, end: expiredDate)
//        return minutes > 30
    }
    
    private static func getMinutesDifferenceFromTwoDates(start: Date, end: Date) -> Int {
        let diff = Int(end.timeIntervalSince1970 - start.timeIntervalSince1970)
        
        let hours = diff / 3600
        let minutes = (diff - hours * 3600) / 60
        return minutes
    }
    
}
