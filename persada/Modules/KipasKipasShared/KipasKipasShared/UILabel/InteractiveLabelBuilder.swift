//
//  Created by Pol Quintana on 04/09/16.
//  Copyright © 2016 Optonaut. All rights reserved.
//

import Foundation

typealias ActiveFilterPredicate = ((String) -> Bool)

struct InteractiveLabelBuilder {
    
    static func createElements(
        type: InteractiveLabelType,
        from text: String,
        range: NSRange,
        filterPredicate: ActiveFilterPredicate?
    ) -> [ElementTuple] {
        switch type {
        case .mention, .hashtag:
            return createElementsIgnoringFirstCharacter(
                from: text,
                for: type,
                range: range,
                filterPredicate: filterPredicate
            )
        case .url:
            return createElements(
                from: text,
                for: type,
                range: range,
                filterPredicate: filterPredicate
            )
        case .custom:
            return createElements(
                from: text,
                for: type,
                range: range,
                minLength: 1,
                filterPredicate: filterPredicate
            )
        case .email:
            return createElements(
                from: text,
                for: type,
                range: range,
                filterPredicate: filterPredicate
            )
        }
    }
    
    static func createURLElements(
        from text: String,
        range: NSRange,
        maximumLength: Int?
    ) -> ([ElementTuple], String) {
        let type = InteractiveLabelType.url
        var text = text
        let matches = RegexParser.getElements(from: text, with: type.pattern, range: range)
        let nsstring = text as NSString
        var elements: [ElementTuple] = []
        
        for match in matches where match.range.length > 2 {
            let word = nsstring.substring(with: match.range)
                .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            guard let maxLength = maximumLength, word.count > maxLength else {
                let range = maximumLength == nil ? match.range : (text as NSString).range(of: word)
                let element = InteractiveLabelElement.create(with: type, text: word)
                elements.append((range, element, type))
                continue
            }
            
            let trimmedWord = word.trim(to: maxLength)
            text = text.replacingOccurrences(of: word, with: trimmedWord)
            
            let newRange = (text as NSString).range(of: trimmedWord)
            let element = InteractiveLabelElement.url(original: word, trimmed: trimmedWord)
            elements.append((newRange, element, type))
        }
        return (elements, text)
    }
    
    private static func createElements(
        from text: String,
        for type: InteractiveLabelType,
        range: NSRange,
        minLength: Int = 2,
        filterPredicate: ActiveFilterPredicate?
    ) -> [ElementTuple] {
        
        let matches = RegexParser.getElements(from: text, with: type.pattern, range: range)
        let nsstring = text as NSString
        var elements: [ElementTuple] = []
        
        for match in matches where match.range.length > minLength {
            let word = nsstring.substring(with: match.range)
                .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if filterPredicate?(word) ?? true {
                let element = InteractiveLabelElement.create(with: type, text: word)
                elements.append((match.range, element, type))
            }
        }
        return elements
    }
    
    private static func createElementsIgnoringFirstCharacter(
        from text: String,
        for type: InteractiveLabelType,
        range: NSRange,
        filterPredicate: ActiveFilterPredicate?
    ) -> [ElementTuple] {
        let matches = RegexParser.getElements(from: text, with: type.pattern, range: range)
        let nsstring = text as NSString
        var elements: [ElementTuple] = []
        
        for match in matches where match.range.length > 2 {
            let range = NSRange(location: match.range.location + 1, length: match.range.length - 1)
            var word = nsstring.substring(with: range)
            if word.hasPrefix("@") {
                word.remove(at: word.startIndex)
            }
            else if word.hasPrefix("#") {
                word.remove(at: word.startIndex)
            }
            
            if filterPredicate?(word) ?? true {
                let element = InteractiveLabelElement.create(with: type, text: word)
                elements.append((match.range, element, type))
            }
        }
        return elements
    }
}
