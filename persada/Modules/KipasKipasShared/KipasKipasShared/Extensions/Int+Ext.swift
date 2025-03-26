import Foundation

public extension Int {
    func toCurrency() -> String {
        let double = Double(self)

        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale(identifier: "ID_id")
        var money = currencyFormatter.string(from: NSNumber(value: double)) ?? "Rp 0"
        money.insert(" ", at: money.index(money.startIndex, offsetBy: 2))
        return money
    }
    
    func epochConverter(format: String) -> String {
        var timeResult = Double()

        timeResult = Double(self) / 1000
        
        let date = Date(timeIntervalSince1970: timeResult)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "id_ID_POSIX")
        dateFormatter.dateFormat = format
        let localDate = dateFormatter.string(from: date)

        return localDate
    }
    
    func timeAgoDisplay() -> String {
        return Date(timeIntervalSince1970: TimeInterval(self) / 1000).timeAgoDisplay()
    }
    
    func toDateStringBy(format: String = "dd/MM/yyyy") -> String {
        return Date(timeIntervalSince1970: TimeInterval(self) / 1000).toString(format: format)
    }
}
