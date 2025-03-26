//
//  String+HTML.swift
//  Persada
//
//  Created by Muhammad Noor on 15/05/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import UIKit

extension String {
    var htmlToAttributedString: NSAttributedString? {
        //Let's get the video id
        let range = NSRange(location: 0, length: self.utf16.count)
        let regex = try! NSRegularExpression(pattern: "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)")
        
        if let match = regex.firstMatch(in: self, options: [], range: range) {
            
            let videoId: String = String(self[Range(match.range, in: self)!])
            
            //Let's replace the the opening iframe tag
            let regex2 = try! NSRegularExpression(pattern:
                                                    "<[\\s]*iframe[\\s]+.*src=")
            
            let str2 = regex2.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "<a href=")
            
            //And then replace the closing tag
            let regex3 = try! NSRegularExpression(pattern:
                                                    "><\\/iframe>")
            let range2 = NSRange(location: 0, length: str2.utf16.count)
            let str3 = regex3.stringByReplacingMatches(in: str2, options: [], range: range2, withTemplate: "><img src=\"https://img.youtube.com/vi/" + videoId + "/0.jpg\" alt=\"\" width=\"\(UIScreen.main.bounds.width - 40.0)\" /></a>")         // You could adjust the width and height to your liking
            let modifiedFont = String(format:"<span style=\"font-family: '-apple-system', 'HelveticaNeue'; font-size: \(16)\">%@</span>", str3)
            
            guard let data = modifiedFont.data(using: .unicode, allowLossyConversion: false) else { return NSAttributedString() }
            do {
                return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
            } catch {
                return NSAttributedString()
            }
        }
        let modifiedFont = String(format:"<span style=\"font-family: '-apple-system', 'HelveticaNeue'; font-size: \(16)\">%@</span>", self)
        
        guard let data = modifiedFont.data(using: .unicode, allowLossyConversion: false) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
    var hashtag: String? {
        var tempString = ""
        if let index = self.index(of: "#") {
            let substring = self[index...]
            let string = String(substring)
            tempString.append(string)
        }
        
        return tempString
    }
    
    func toMoney(withCurrency: Bool = true) -> String {
        guard let double = Double(self) else { return withCurrency ? "Rp 0" : "0" }
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale(identifier: "ID_id")
        var money = currencyFormatter.string(from: NSNumber(value: double)) ?? "Rp 0"
        money.insert(" ", at: money.index(money.startIndex, offsetBy: 2))
        return withCurrency ? money : money.replacingOccurrences(of: "Rp ", with: "")
    }
    
    func toMoneyWithoutRp() -> String {
        return self.digits().toMoney().replacingOccurrences(of: "Rp ", with: "")
    }
    
    func isUrl() -> Bool {
        if let url = NSURL(string: self) {
            return UIApplication.shared.canOpenURL(url as URL)
        }
        return false
    }
    
    func digits() -> String {
        return self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
    
}

extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        if self == nil {
            return true
        }
        else{
            return self?.isEmpty ?? false
        }
    }
    
    var emptyOrNilReturnZero: String {
        if self.isNilOrEmpty {
            return "0"
        } else if let string = self {
            return string
        } else {
            return "0"
        }
    }
    
}
