//
//  SharedBundle.swift
//  KipasKipasDirectMessage
//
//  Created by DENAZMI on 03/08/23.
//

import Foundation

public class SharedBundle {
    
    public static let shared = SharedBundle()
    
    public var bundle: Bundle!
    
    private init() {
        bundle = Bundle(for: Self.self)
    }
}
