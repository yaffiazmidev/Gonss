//
//  SharedBundle.swift
//  FeedCleeps
//
//  Created by PT.Koanba on 07/07/22.
//

import Foundation

class SharedBundle {
    var bundle: Bundle!
    static let shared = SharedBundle()

    private init() {
        bundle = Bundle(for: Self.self)
    }
    
}
