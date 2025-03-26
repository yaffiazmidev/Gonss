import Foundation

extension Array {
    func hasElement(at index: Int) -> Bool {
        return index >= 0 && index < count
    }
}
