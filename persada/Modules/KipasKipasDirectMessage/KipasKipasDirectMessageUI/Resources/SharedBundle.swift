//
//  SharedBundle.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 15/07/23.
//

import Foundation

class SharedBundle {
    var bundle: Bundle!
    static let shared = SharedBundle()

    private init() {    
        bundle = Bundle(for: Self.self)
    }
    
}
