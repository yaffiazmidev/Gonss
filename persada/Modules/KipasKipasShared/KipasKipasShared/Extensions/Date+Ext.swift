import Foundation

public extension Date {
    func timeAgoDisplay() -> String {
//        let formatter = RelativeDateTimeFormatter()
//        formatter.unitsStyle = .full
//        return formatter.localizedString(for: self, relativeTo: Date())
//        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        let removeAgo = formatter.localizedString(for: self, relativeTo: Date()).replacingOccurrences(of: " ago", with: "")
        
        guard !removeAgo.contains("min") else {
            return self.toString(format: "HH:mm")
        }
        
        guard !removeAgo.contains(" hr") else {
            return removeAgo.replacingOccurrences(of: " hr", with: "h")
        }
        
        guard !removeAgo.contains(" days") else {
            return removeAgo.replacingOccurrences(of: " days", with: "d")
        }
        
        guard !removeAgo.contains(" days ago") else {
            return removeAgo.replacingOccurrences(of: " days ago", with: "d")
        }
        
        guard !removeAgo.contains(" day") else {
            return removeAgo.replacingOccurrences(of: " day", with: "d")
        }
        
        guard !removeAgo.contains(" wk") else {
            return removeAgo.replacingOccurrences(of: " wk", with: "w")
        }
        
        guard !removeAgo.contains(" mo") else {
            return self.toString(format: "dd/MM")
        }
        
        return removeAgo
    }
    
    func toString(format: String = "dd/MM/yyyy") -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "id_ID")
        formatter.dateStyle = .short
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
