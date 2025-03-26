//
//  Ext+Date.swift
//  KipasKipas
//
//  Created by DENAZMI on 01/01/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import Foundation

extension Date {
    var remainingSecondsBeforeNoon: Int? {
        let calendar = Calendar.current
        let noonToday = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: self)

        guard let noonToday = noonToday else {
            return nil  // Couldn't create noon date
        }

        let remainingSeconds = calendar.dateComponents([.second], from: self, to: noonToday).second
        return remainingSeconds
    }
}
