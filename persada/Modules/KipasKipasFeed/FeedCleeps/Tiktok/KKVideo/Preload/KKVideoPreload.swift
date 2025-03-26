//
//  KKVideoPreload.swift
//  FeedCleeps
//
//  Created by Rahmat Trinanda Pramudya Amar on 17/08/23.
//

import Foundation


public protocol KKVideoPreload {
    // MARK: Section of Variable
    
    /**
     Get Instance of KKVideoPreload
     - returns: KKVideoPreload
     
     # Example #
     ```
     // KKVideoPreload.instance
     ```
     */
    static var instance: KKVideoPreload { get }
}
