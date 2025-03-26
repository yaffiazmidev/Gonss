//
//  SharedBundle.swift
//  KipasKipasVerificationIdentityiOS
//
//  Created by DENAZMI on 02/06/24.
//

import Foundation

class SharedBundle {
    var bundle: Bundle!
    static let shared = SharedBundle()

    private init() {
        bundle = Bundle(for: Self.self)
    }
}
