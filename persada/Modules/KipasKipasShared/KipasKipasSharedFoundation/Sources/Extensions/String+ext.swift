import Foundation

public extension String {
    func getUsernameFromEmail() -> String? {
        guard let atIndex = firstIndex(of: "@") else {
            return nil
        }
        return String(self[..<atIndex])
    }
    
    func containsEmailExtension() -> Bool {
        let pattern = "@[a-zA-Z0-9-]+(\\.[a-zA-Z0-9-]+)*\\.[a-zA-Z]{2,}"
        let regex = try? NSRegularExpression(pattern: pattern)
        
        let range = NSRange(location: 0, length: utf16.count)
        let matches = regex?.matches(in: self, options: [], range: range) ?? []
        
        return matches.isEmpty == false
    }
    
    func addZeroPrefixOnPhoneNumber() -> String {
        return hasPrefix("8") ? "08" + String(dropFirst()) : self
    }
}
