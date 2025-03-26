//
//  Ext-Array.swift
//  KipasKipas
//
//  Created by Administer on 2024/5/28.
//  Copyright © 2024 Koanba. All rights reserved.
//

import Foundation
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
