//
//  NotificationDirectMessageTableViewCell.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 20/03/24.
//

import UIKit
import KipasKipasShared
import SendbirdChatSDK
import Kingfisher

class NotificationDirectMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var verifiedIconImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var lastMessageDateLabel: UILabel!
    @IBOutlet weak var unreadMessageCountLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        verifiedIconImageView.image = UIImage.iconVerified
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        usernameLabel.text = nil
        lastMessageLabel.text = nil
        unreadMessageCountLabel.text = nil
        profileImageView.cancelLoad()
    }
    
    func configure(_ channel: GroupChannel) {
        let currentUserId = SendbirdChat.getCurrentUser()?.userId ?? ""
        let targetUser = channel.members.filter({ $0.userId != currentUserId }).first
        let isVerified = Bool(targetUser?.metaData["is_verified"] ?? "") ?? false
        
        verifiedIconImageView.isHidden = !isVerified
        usernameLabel.text = targetUser?.nickname
        profileImageView.loadProfileImage(from: targetUser?.profileURL ?? "")
        lastMessageLabel.text = channel.lastMessage?.message ?? ""
        lastMessageDateLabel.text = "\(channel.lastMessage?.createdAt.timeAgoDisplay() ?? "")"
        
        let unreadMessageCount = Int(channel.unreadMessageCount)
        updateUnReadCount(unreadMessageCount)
//        
//        setupLastMessage(with: channel.lastMessage)
//        
//        lastMessageDateLabel.textColor = unreadMessageCount <= 0 ? UIColor(hexString: "#8A8A8A") : .systemBlue
//        
//        let keys = [
//            "is_paid_chat"
//        ]
//        
//        channel.getMetaData(keys: keys) { metaData, error in
//            let isPaidChat = metaData?["is_paid_chat"] ?? "false" == "true"
//            
//            self.coinIconImageView.isHidden = !isPaidChat
//            self.userProfileImageView.borderColor = isPaidChat ? UIColor(hexString: "#FF8A00") : .clear
//        }
//            
//        contentView.backgroundColor = UIColor(hexString: "#FFFFFF")// UIColor(hexString: isPaidChat && unreadMessageCount > 0 ? "#FFF9E3" : "#FFFFFF")
    }
    
    private func updateUnReadCount(_ count: Int) {
        lastMessageDateLabel.textColor = UIColor(hexString: count <= 0 ? "#8A8A8D" : "#1890FF")
        unreadMessageCountLabel.isHidden = count <= 0
        unreadMessageCountLabel.text = count >= 99 ? "99" : "\(count)"
    }
    
}

extension Int64 {
    public func timeAgoDisplay() -> String {
        return Date.sbu_from(self).timeAgoDisplay()
    }
}


extension Date {
    
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
    
    public func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        let removeAgo = formatter.localizedString(for: self, relativeTo: Date()).replacingOccurrences(of: " ago", with: "")
        
        guard !removeAgo.contains("min") else {
            return self.sbu_toString(format: .HHmm)
        }
        
        guard !removeAgo.contains(" hr") else {
            return removeAgo.replacingOccurrences(of: " hr", with: "h")
        }
        
        guard !removeAgo.contains(" days ago") else {
            return removeAgo.replacingOccurrences(of: " days ago", with: "d")
        }
        
        guard !removeAgo.contains(" wk") else {
            return removeAgo.replacingOccurrences(of: " wk", with: "w")
        }
        
        guard !removeAgo.contains(" mo") else {
            return toString()
        }
        
        return removeAgo
    }
    
    var millisecondsSince1970: Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    
    func toString(format: String = "dd/MM/yyyy") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.timeZone = TimeZone(identifier: "GMT")
        formatter.dateStyle = .short
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        let cal = Calendar.current
        var components = DateComponents()
        components.day = 1
        return cal.date(byAdding: components, to: self.startOfDay)!.addingTimeInterval(-1)
    }
    
    func removeMonths(numberOfMonths: Int) -> Date {
        let endDate = Calendar.current.date(byAdding: .month, value: -numberOfMonths, to: self)
        return endDate ?? Date()
    }
}

extension Double {
    func reduceScale(to places: Int) -> Double {
        let multiplier = pow(10, Double(places))
        let newDecimal = multiplier * self // move the decimal right
        let truncated = Double(Int(newDecimal)) // drop the fraction
        let originalDecimal = truncated / multiplier // move the decimal back
        return originalDecimal
    }
    
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
}

extension Int {
    func formatViews() -> String {
        let num = abs(Double(self))
        let sign = (self < 0) ? "-" : ""
        
        switch num {
        case 1_000_000_000...:
            var formatted = num / 1_000_000_000
            formatted = formatted.reduceScale(to: 1)
            return "\(sign)\(formatted)B"
            
        case 1_000_000...:
            var formatted = num / 1_000_000
            formatted = formatted.reduceScale(to: 1)
            return "\(sign)\(formatted)M"
            
        case 1_000...:
            var formatted = num / 1_000
            formatted = formatted.reduceScale(to: 1)
            return "\(sign)\(formatted)K"
            
        case 0...:
            return "\(self)"
            
        default:
            return "\(sign)\(self)"
        }
    }
}
