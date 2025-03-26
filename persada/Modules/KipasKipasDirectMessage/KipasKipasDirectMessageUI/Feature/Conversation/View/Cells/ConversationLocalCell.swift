//
//  ConversationLocalCell.swift
//  KipasKipasDirectMessageUI
//
//  Created by MissYasiky on 2024/4/24.
//

import Foundation
import UIKit
import KipasKipasDirectMessage

class ConversationLocalCell: UITableViewCell {
    let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10.0
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor(hexString: "#F5F4F4")
        return view
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(hexString: "#4A4A4A")
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    public weak var delegate: ConversationRevokeCellDelegate?
    private var message: TXIMMessage?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.contentView.addSubview(self.bubbleView)
        self.bubbleView.addSubview(self.label)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.message = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let boundWidth = self.contentView.bounds.size.width
        
        if let _ = self.message {
            let maxBubbleWidth = boundWidth - 22 * 2
            let labelWidth = maxBubbleWidth - 16 * 2
            let size = self.label.sizeThatFits(CGSizeMake(labelWidth, CGFLOAT_MAX))
            
            let bubbleSize = CGSize(width: size.width + 16 * 2, height: size.height + 8 * 2)
            let bubbleOrigin = CGPoint(x: (boundWidth - bubbleSize.width) / 2.0, y: 5)
            self.bubbleView.frame = CGRect(origin: bubbleOrigin, size: bubbleSize)
            self.label.frame = CGRect(origin: CGPoint(x: 16, y: 8), size: CGSize(width: size.width, height: size.height))
        } else {
            self.bubbleView.frame = CGRectZero
            self.label.frame = CGRectZero
        }
    }
    
    func updateMessage(_ message: TXIMMessage) {
        self.message = message
        self.label.text = message.text ?? ""
    }
    
    static func height(with message: TXIMMessage) -> CGFloat {
        var maxBubbleWidth = UIScreen.main.bounds.size.width - 22 * 2
        let labelWidth = maxBubbleWidth - 16 * 2
        
        let label: UILabel = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = message.text ?? ""
        label.numberOfLines = 2
        let size = label.sizeThatFits(CGSizeMake(labelWidth, CGFLOAT_MAX))
        let bubbleHeight = 8 + size.height + 8
        return 5 + bubbleHeight + 5
    }
}
