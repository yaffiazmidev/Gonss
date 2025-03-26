import Foundation

extension IndexPath {
    var previousItem: Int {
        return item - 1
    }
    
    var nextItem: Int {
        return item + 1
    }
}

