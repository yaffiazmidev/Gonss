//
//  Array+Extension.swift
//  KipasKipasShared
//
//  Created by Rahmat Trinanda Pramudya Amar on 03/06/24.
//

import Foundation

public extension NSMutableArray {
    // Safe subscript for NSMutableArray
    subscript(safe index: Int) -> Any? {
        get {
            guard index >= 0, index < self.count else {
                return nil // Index out of bounds
            }
            return self[index]
        }
        set {
            guard index >= 0, index < self.count, let value = newValue else {
                return // Invalid index or nil value
            }
            self[index] = value
        }
    }
}

public extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
