//
//  ConversationCellEmojiView.swift
//  KipasKipasDirectMessageUI
//
//  Created by MissYasiky on 2024/4/30.
//

import Foundation
import UIKit

enum ConversationCellEmojiViewType {
    case none
    case onlyOneEmoji(emoji: String)
    case oneEmojiAndNumber(emoji: String)
    case twoEmojiAndNumber(emoji1: String, emoji2: String)
}

class ConversationCellEmojiView: UIView {
    private(set) var type: ConversationCellEmojiViewType = .none
    private var numberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.textColor = UIColor(hexString: "#8C9289")
        label.text = "2"
        return label
    }()
    
    private var labels: [UILabel] = []
    public var caculateSize: CGSize {
        get {
            switch type {
            case .none:
                return CGSizeZero
            case .onlyOneEmoji(_):
                return CGSize(width: 32, height: 24)
            case .oneEmojiAndNumber(_):
                return CGSize(width: 56, height: 24)
            case .twoEmojiAndNumber(_, _):
                return CGSize(width: 71, height: 24)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: CGRectZero)
        
        self.backgroundColor = .white
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 12.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(hexString: "#EFE9E0").cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        switch type {
        case .none:
            print("")
        case .onlyOneEmoji(_):
            if let label = labels.first {
                label.frame = CGRectMake(8.5, 4, 16, 16)
            }
        case .oneEmojiAndNumber(_), .twoEmojiAndNumber(_, _):
            var originX: CGFloat = 8.0
            for label in labels {
                label.frame = CGRectMake(originX, 4, 16, 16)
                originX += 16 + 8
            }
            numberLabel.frame = CGRect(x: originX - 8, y: 4, width: caculateSize.width - (originX - 8), height: 16)
        }
    }
    
    func updateEmoji(_ reactions: [(String, [String])]) {
        print("【DM】reaction \(reactions)")
        if reactions.count == 0 {
            self.type = .none
        } else if reactions.count == 1 {
            let reacion = reactions[0]
            if reacion.1.count > 1 {
                self.type = .oneEmojiAndNumber(emoji: reacion.0)
            } else {
                self.type = .onlyOneEmoji(emoji: reacion.0)
            }
        } else {
            let emoji1: String = reactions[0].0
            let emoji2: String = reactions[1].0
            self.type = .twoEmojiAndNumber(emoji1: emoji1, emoji2: emoji2)
        }
        
        for subView in self.subviews {
            subView.removeFromSuperview()
        }
        labels.removeAll()
        
        switch type {
        case .none:
            print("")
        case .onlyOneEmoji(let emoji):
            let label = emojiLabel(emoji)
            self.addSubview(label)
            labels.append(label)
        case .oneEmojiAndNumber(let emoji):
            let label = emojiLabel(emoji)
            self.addSubview(label)
            labels.append(label)
            self.addSubview(numberLabel)
        case .twoEmojiAndNumber(let emoji1, let emoji2):
            let emojiLabel1 = emojiLabel(emoji1)
            self.addSubview(emojiLabel1)
            labels.append(emojiLabel1)
            let emojiLabel2 = emojiLabel(emoji2)
            self.addSubview(emojiLabel2)
            labels.append(emojiLabel2)
            self.addSubview(numberLabel)
        }
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    private func emojiLabel(_ emoji: String) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.text = emoji
        return label
    }
}
