//
//  HelperSingleton.swift
//  FeedCleeps
//
//  Created by PT.Koanba on 04/07/22.
//

import Foundation

public class HelperSingleton {
    var baseURL = ""
    public var token = ""
    public var userId = ""
    
    public static let shared = HelperSingleton()
    
    private init() {}
}
