//
//  String.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 28/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import UIKit

extension String {

	func getSmallText(limit: Int, prefixText: String, suffixText: String) -> NSMutableAttributedString {
		let prefixText = "\(prefixText)"
		var newText = prefixText + String(self.prefix(limit)) + "..."
		newText += suffixText

		let mutableText = NSMutableAttributedString(string: newText, attributes: [NSAttributedString.Key.font: UIFont.Roboto(.regular, size: 14), NSAttributedString.Key.foregroundColor: UIColor.contentGrey.cgColor])

		mutableText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.placeholder, range: NSRange(location:newText.count - suffixText.count,length:suffixText.count))

		mutableText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.black ,NSAttributedString.Key.font: UIFont.Roboto(.bold, size: 14)], range: _NSRange(location: 0, length: prefixText.count))
		return mutableText


	}

	func getAllText(prefixText: String) -> NSMutableAttributedString {
		let newText = prefixText + " " + self

		let mutableText = NSMutableAttributedString(string: newText, attributes: [NSAttributedString.Key.font: UIFont.Roboto(.regular, size: 14), NSAttributedString.Key.foregroundColor: UIColor.contentGrey.cgColor])

		mutableText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.black ,NSAttributedString.Key.font: UIFont.Roboto(.bold, size: 14)], range: _NSRange(location: 0, length: prefixText.count))
		return mutableText
	}

	static func get(_ key: StringEnum) -> String {
		return key.rawValue.localized()
	}

	static func get(_ key: StringEnum, _ arguments: CVarArg...) -> String {
		return withVaList(arguments, { (params) -> String in
			return NSString(format: key.rawValue.localized(), arguments: params) as String
		})
	}

	func localized(withComment comment: String? = nil) -> String {
		return NSLocalizedString(self, comment: comment ?? "")
	}

	static func get(_ key: AssetEnum) -> String {
		return key.rawValue
	}

	func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
		let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
		let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
		
		return ceil(boundingBox.height)
	}
	
	func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
		let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
		let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
		
		return ceil(boundingBox.width)
	}

	func appendStringWithAtribute(string: String, attributes: [NSAttributedString.Key: Any]) -> NSMutableAttributedString {

		let str = self + string
		let range = (str as NSString).range(of: "\(string)")
		let attributedString = NSMutableAttributedString(string: str)
		attributedString.addAttributes(attributes, range: range)
		return attributedString
	}

	func setNonBreakAble()-> String {
		return self.replacingOccurrences(of: " ", with: "\u{A0}")
	}

	func setLineSpacing(spacing: CGFloat) -> NSMutableAttributedString {
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = spacing
		let attributedString = NSMutableAttributedString(string: self)
		attributedString.setLineSpacing(spacing: spacing)
		return attributedString
	}
	
	func isItUser() -> Bool {
		return self == getIdUser()
	}
    
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
    
    func toDate(withFormat format: String = "dd/MM/yyyy") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "id_ID")
        dateFormatter.dateFormat = format
        guard let date = dateFormatter.date(from: self) else {
          preconditionFailure("wrong format")
        }
        return date
    }
    
    func toDouble() -> Double {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        if let number = formatter.number(from: self) {
            let amount = number.doubleValue
            return amount
        }
        
        return 0
    }
    
    static func format(decimal:Float, _ maximumDigits:Int = 1, _ minimumDigits:Int = 1) ->String? {
        let number = NSNumber(value: decimal)
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = maximumDigits
        numberFormatter.minimumFractionDigits = minimumDigits
        return numberFormatter.string(from: number)
    }
    
    func range(of strings: [String], options: NSString.CompareOptions, range: NSRange? = nil) -> (range: NSRange, foundString: String) {
        let nsself = (self as NSString)
        var foundRange = NSRange(location: NSNotFound, length: 0)

        let string = strings.first {
            if let range = range {
                foundRange = nsself.range(of: $0, options: options, range: range)
            } else {
                foundRange = nsself.range(of: $0, options: options)
            }

            return foundRange.location != NSNotFound
        } ?? ""

        return (foundRange, string)
    }

    func isMentionEnabledAt(_ location: Int) -> (Bool, String) {
        guard location != 0 else { return (true, "") }

        let start = utf16.index(startIndex, offsetBy: location - 1)
        let end = utf16.index(start, offsetBy: 1)
        let textBeforeTrigger = String(utf16[start ..< end]) ?? ""

        return (textBeforeTrigger == " " || textBeforeTrigger == "\n", textBeforeTrigger)
    }

    var stringByRemovingWhitespaces: String {
        let components = components(separatedBy: .whitespacesAndNewlines)
        return components.joined(separator: "")
    }

    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

extension String {
    func trim(in set: CharacterSet = .whitespacesAndNewlines) -> String {
        self.trimmingCharacters(in: set)
    }
    
    func applyPredicateOnRegex(regexStr: String) -> Bool{
        let trimmedString = self.trimmingCharacters(in: .whitespaces)
        let validateOtherString = NSPredicate(format: "SELF MATCHES %@", regexStr)
        let isValidateOtherString = validateOtherString.evaluate(with: trimmedString)
        return isValidateOtherString
    }
    
    func isValidateUsername(mini: Int = 4) -> Bool {
//        return applyPredicateOnRegex(regexStr: "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{\(mini),}$")
        return applyPredicateOnRegex(regexStr: "^[0-9]*$")
    }
    
    func isValidUsername() -> Bool {
        return applyPredicateOnRegex(regexStr: "^(?=[a-zA-Z0-9._]{4,20}$)(?!^[._]|.*[._]$)[a-zA-Z0-9._]*[a-zA-Z][a-zA-Z0-9._]*$")
    }

    func isOnlyNumber() -> Bool {
        return applyPredicateOnRegex(regexStr: "^[0-9]*$")
    }
    
    func isOnlyLowercase() -> Bool {
        return applyPredicateOnRegex(regexStr: "^[a-z]*$")
    }

    func isUsernameContainsAllowedCharacters() -> Bool {
        let allowedCharacterSet = CharacterSet(charactersIn: "._abcdefghijklmnopqrstuvwxyz")
        return self.rangeOfCharacter(from: allowedCharacterSet) != nil
    }

    func isContainsSpecialChar() -> Bool {
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_")
        if self.rangeOfCharacter(from: characterset.inverted) != nil {
            return true
        }
        return false
    }
    
    func isUsernameContainsSpecialChar() -> Bool {
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_")
        if self.rangeOfCharacter(from: characterset.inverted) != nil {
            return true
        }
        return false
    }
    
    func isValidatePassword() -> Bool {
        return applyPredicateOnRegex(regexStr: "^(?=.*[A-Za-z])(?=.*[A-Z])(?=.*\\d)[A-Za-z\\d]{6,}$")
    }
    
    func isValidEmail(_ email: String = "") -> Bool {
        return applyPredicateOnRegex(regexStr: "[A-Z0-9a-z._%+-]{1,64}@[A-Za-z0-9.-]{2,64}\\.[A-Za-z]{2,64}")
    }

    func lettersCount() -> Int {
        var letterCount = 0
        for character in self {
            if character.isLetter {
                letterCount += 1
            } else if character == "_" || character == "." {
                letterCount += 1
            }
        }
        return letterCount
    }

    func numbersCount() -> Int {
        return self.filter({ $0.isNumber }).count
    }

    func isValid(with regex: String) -> Bool {
        let pattern = regex
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex?.firstMatch(in: self, options: [], range: range) != nil
    }

    func isUniqPassword() -> Bool {
        let pattern = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?!.*\\s).{6,20}$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex?.firstMatch(in: self, options: [], range: range) != nil
    }

    func isValidPhoneNumber() -> Bool {
        return isValid(with: "^(628[0-9]{7,15}|08[0-9]{7,14})$")
    }

    var containsOnlyDigits: Bool {
        let notDigits = NSCharacterSet.decimalDigits.inverted
        return rangeOfCharacter(from: notDigits, options: String.CompareOptions.literal, range: nil) == nil
    }
    var containsOnlyLetters: Bool {
        let notLetters = NSCharacterSet.letters.inverted
        return rangeOfCharacter(from: notLetters, options: String.CompareOptions.literal, range: nil) == nil
    }
    var containsIllegalCharacters: Bool {
        rangeOfCharacter(from: NSCharacterSet.illegalCharacters, options: String.CompareOptions.literal, range: nil) != nil
    }
    var containsOnlyPasswordAllowed: Bool {
        var allowedCharacters = CharacterSet()
        allowedCharacters.insert(charactersIn: "!"..."~")
        let forbiddenCharacters = allowedCharacters.inverted
        return rangeOfCharacter(from: forbiddenCharacters, options: String.CompareOptions.literal, range: nil) == nil
    }
    var isAlphanumeric: Bool {
        let notAlphanumeric = NSCharacterSet.decimalDigits.union(NSCharacterSet.letters).inverted
        return rangeOfCharacter(from: notAlphanumeric, options: String.CompareOptions.literal, range: nil) == nil
    }
    var containsLetters: Bool {
        rangeOfCharacter(from: NSCharacterSet.letters, options: String.CompareOptions.literal, range: nil) != nil
    }
    var containsDigits: Bool {
        rangeOfCharacter(from: NSCharacterSet.decimalDigits, options: String.CompareOptions.literal, range: nil) != nil
    }
    var containsUppercaseLetters: Bool {
        rangeOfCharacter(from: NSCharacterSet.uppercaseLetters, options: String.CompareOptions.literal, range: nil) != nil
    }

    var containsLowercaseLetters: Bool {
        rangeOfCharacter(from: NSCharacterSet.lowercaseLetters, options: String.CompareOptions.literal, range: nil) != nil
    }

    var containsNonAlphanumericCharacters: Bool {
        let notAlphanumeric = NSCharacterSet.decimalDigits.union(NSCharacterSet.letters).inverted
        return rangeOfCharacter(from: notAlphanumeric, options: String.CompareOptions.literal, range: nil) != nil
    }

    var isValidPassword: Bool {
        if count < 6 || count > 20 {
            return false
        }
        
        if containsIllegalCharacters ||
            !containsOnlyPasswordAllowed {
            return false
        }
        
        if !containsLetters {
            return false
        }
        
        var strength = 0
        if containsUppercaseLetters {
            strength += 1
        }
        if containsLowercaseLetters {
            strength += 1
        }
        if containsDigits {
            strength += 1
        }
        if containsNonAlphanumericCharacters {
            strength += 1
        }
        return strength >= 3
    }

    var isSingleEmoji: Bool { count == 1 && containsEmoji }
    var containsEmoji: Bool { contains { $0.isEmoji } }
    var containsOnlyEmoji: Bool { !isEmpty && !contains { !$0.isEmoji } }
    var emojiString: String { emojis.map { String($0) }.reduce("", +) }
    var emojis: [Character] { filter { $0.isEmoji } }
    var emojiScalars: [UnicodeScalar] { filter { $0.isEmoji }.flatMap { $0.unicodeScalars } }
}

extension Character {
    var isSimpleEmoji: Bool {
        guard let firstScalar = unicodeScalars.first else {
            return false }
        return firstScalar.properties.isEmoji && firstScalar.value > 0x238C
    }

    var isCombinedIntoEmoji: Bool { unicodeScalars.count > 1 &&
        unicodeScalars.first?.properties.isEmoji ?? false }
    var isEmoji: Bool { isSimpleEmoji || isCombinedIntoEmoji }
}

extension NSMutableAttributedString {
	func setLineSpacing(spacing: CGFloat){
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.lineSpacing = spacing
		self.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, self.length))
	}
}

public var ossPerformance = "?x-oss-process=image/format,jpg/interlace,1/resize,w_"
