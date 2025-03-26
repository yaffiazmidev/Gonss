//
//  ActiveLabelExtension.swift
//  KipasKipas
//
//  Created by OWS on 26/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import UIKit

extension ActiveLabel {
	func setLabel(prefixText: String, expanded: Bool, mainText: String,_ limitMainText: Int, prefixTap: (() -> Void)?, suffixTap: (() -> Void)?, mentionTap: ((_ mention: String) -> Void)?, hashtagTap: ((_ hashtag: String) -> Void)?) {
        self.font = .Roboto(.regular, size: 14)
        self.textColor = .black
        
		let prefixRegex = ActiveType.custom(pattern: "^\(prefixText)\\b") //Regex that looks for "prefixText"
		let suffixRegex = ActiveType.custom(pattern: "more $")
		
		self.customize { (label) in
            if expanded {
                label.enabledTypes = [.mention, .hashtag, prefixRegex]
            } else {
                if mainText.count < limitMainText {
                    label.enabledTypes = [.mention, .hashtag, prefixRegex]
                } else {
                    label.enabledTypes = [.mention, .hashtag, prefixRegex, suffixRegex]
                }
            }
			if !expanded {
				label.text = mainText.count > limitMainText ? prefixText + " " + mainText.prefix(limitMainText) + "... more " : prefixText + " " + mainText
			} else {
				label.text = prefixText + " " + mainText
			}
			
			label.configureLinkAttribute = .some({ (ActiveType, _: [NSAttributedString.Key : Any], Bool) -> ([NSAttributedString.Key : Any]) in
				if ActiveType == .custom(pattern: "^\(prefixText)\\b") {
					return [NSAttributedString.Key.font: UIFont.Roboto(.bold, size: 14), NSAttributedString.Key.foregroundColor: UIColor.black]
				} else if ActiveType == .mention || ActiveType == .hashtag {
                    return [NSAttributedString.Key.font: UIFont.Roboto(.regular, size: 14), NSAttributedString.Key.foregroundColor: UIColor.secondary]
                } else if ActiveType == .custom(pattern: "more $") {
                    if expanded {
                        return [NSAttributedString.Key.font: UIFont.Roboto(.medium, size: 14), NSAttributedString.Key.foregroundColor: UIColor.black]
                    } else {
                        return [NSAttributedString.Key.font: UIFont.Roboto(.medium, size: 14), NSAttributedString.Key.foregroundColor: UIColor.placeholder]
                    }
				}
				return [NSAttributedString.Key: Any]()
			})
			
			label.handleCustomTap(for: prefixRegex) { (String) in
				prefixTap!()
			}
			label.handleCustomTap(for: suffixRegex) { (String) in
				suffixTap!()
			}
			label.handleMentionTap { (String) in
				mentionTap!(String)
			}
			label.handleHashtagTap { (String) in
				hashtagTap!(String)
			}
		}
	}
    
    func setCaption(
        text: String,
        shouldTrim: Bool = true,
        attributeFont: UIFont = .roboto(.medium, size: 15),
        attributeColor: UIColor = .white,
        mentionTap: @escaping (String) -> Void,
        hashtagTap: @escaping (String) -> Void
    ) {
        self.customize { [weak self] (label) in
            guard let self = self else { return }
            label.numberOfLines = 0
            label.enabledTypes = [.mention, .hashtag]
      
            if text.count > textLimit && shouldTrim {
                label.text = self.addSpaceForWordWithAddAndHashtag(for: self.getLimitedTextWithoutCuttedHashtag(limitText: textLimit, for: text) + "...")
            } else {
                label.text = self.addSpaceForWordWithAddAndHashtag(for: self.insertSpaceInFrontOfHashtag(for: text))
            }
            
            label.configureLinkAttribute = .some({ (ActiveType, _: [NSAttributedString.Key : Any], Bool) -> ([NSAttributedString.Key : Any]) in
                 if ActiveType == .mention || ActiveType == .hashtag {
                    return [NSAttributedString.Key.font: attributeFont, NSAttributedString.Key.foregroundColor: attributeColor]
                 } else {
                     return [NSAttributedString.Key: Any]()
                 }
            })
            
            label.handleMentionTap(mentionTap)
            label.handleHashtagTap(hashtagTap)
            label.sizeToFit()
        }
    }
    
    func setTiktokCaption(text: String, limitText: Int? = 120, moreTap: (() -> Void)?, lessTap: (() -> Void)?, mentionTap: ((_ mention: String) -> Void)?, hashtagTap: ((_ hashtag: String) -> Void)?) {
        self.textColor = .white
        
        let moreType = ActiveType.custom(pattern: "\\smore\\b")
        let lessType = ActiveType.custom(pattern: "\\sless\\b")
        
        self.customize { [weak self] (label) in
            guard let self = self else { return }
            label.enabledTypes = [moreType, lessType, .mention, .hashtag]
            
            let limitText = limitText ?? 120
            if text.count > limitText {
                label.text = self.addSpaceForWordWithAddAndHashtag(for: self.getLimitedTextWithoutCuttedHashtag(limitText: limitText, for: text)) + "...\n\nMore"
            } else {
                label.text = "\(self.addSpaceForWordWithAddAndHashtag(for: self.insertSpaceInFrontOfHashtag(for: text)))"
            }
            
            label.configureLinkAttribute = .some({ (ActiveType, _: [NSAttributedString.Key : Any], Bool) -> ([NSAttributedString.Key : Any]) in
                if ActiveType == moreType || ActiveType == lessType {
                    return [NSAttributedString.Key.font: UIFont.Roboto(.medium, size: 15), NSAttributedString.Key.foregroundColor: UIColor.white]
                } else if ActiveType == .mention || ActiveType == .hashtag {
                    return [NSAttributedString.Key.font: UIFont.Roboto(.medium, size: 15), NSAttributedString.Key.foregroundColor: UIColor.white]
                }
                return [NSAttributedString.Key: Any]()
            })
            
            label.handleCustomTap(for: moreType) { (String) in
                moreTap!()
                label.text = self.insertSpaceInFrontOfHashtag(for: text) + "\n\nLess"
            }
            
            label.handleCustomTap(for: lessType) { (String) in
                lessTap!()
                label.text = self.getLimitedTextWithoutCuttedHashtag(limitText: limitText, for: text) + "...\n\nMore "
            }
            label.handleMentionTap { (String) in
                mentionTap!(String)
            }
            label.handleHashtagTap { (String) in
                hashtagTap!(String)
            }
        }
        
    }
    
    private func getLimitedTextWithoutCuttedHashtag(limitText: Int, for text: String) -> String {
        let replacedText = insertSpaceInFrontOfHashtag(for: text)
        let limitedText = replacedText.prefix(limitText)
        let textCaptionArray = limitedText.components(separatedBy: " ")
        let textCountForLastWordInTheCaption = limitText - (textCaptionArray.last?.count)!
        if textCountForLastWordInTheCaption == 0 {
            return "\(limitedText)"
        }
        let getLimitedTextWithoutCuttedHashtag = replacedText.prefix(textCountForLastWordInTheCaption)
        return "\(getLimitedTextWithoutCuttedHashtag)"
    }
    
    private func insertSpaceInFrontOfHashtag(for text: String) -> String {
        let replacedSpaceText = text.replacingOccurrences(of: " #", with: "#")
        let replacedText = replacedSpaceText.replacingOccurrences(of: "#", with: " #")
        let finalText = replacedText.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "\n ", with: "\n")
        return finalText
    }
    
    private func addSpaceForWordWithAddAndHashtag(for text: String) -> String {
        var replacedText = text
        let words = text.components(separatedBy: " ")
   
        for word in words {
            if words.count == 1 {
                if word.hasPrefix("@") || word.hasPrefix("#") {
                    replacedText = text.replacingOccurrences(of: word, with: "\(word)  ")
                }
            } else {
                if word.hasPrefix("@") && word.contains("\n") {
                    replacedText = text.replacingOccurrences(of: word, with: "\(word)  ")
                }
            }
        }
        return replacedText
    }
}
