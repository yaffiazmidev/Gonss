//
//  Ext-Double.swift
//  KipasKipas
//
//  Created by DENAZMI on 08/08/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

extension Double {
    func reduceScale(to places: Int) -> Double {
        let multiplier = pow(10, Double(places))
        let newDecimal = multiplier * self // move the decimal right
        let truncated = Double(Int(newDecimal)) // drop the fraction
        let originalDecimal = truncated / multiplier // move the decimal back
        return originalDecimal
    }
}
