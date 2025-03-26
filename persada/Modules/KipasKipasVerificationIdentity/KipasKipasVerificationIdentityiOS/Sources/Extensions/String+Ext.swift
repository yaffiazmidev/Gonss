//
//  String+Ext.swift
//  KipasKipasVerificationIdentityiOS
//
//  Created by DENAZMI on 11/06/24.
//

import Foundation

extension String {
    func maskName() -> String {
        return self.split(separator: " ")
            .map { word in
                guard word.count >= 3 else { return self }
                return word.prefix(3) + String(repeating: "*", count: word.count - 3)
            }
            .joined(separator: " ")
    }
}
