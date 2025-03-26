//
//  ConversationRevokeCell.swift
//  KipasKipasDirectMessageUI
//
//  Created by MissYasiky on 2024/4/24.
//

import Foundation
import UIKit
import KipasKipasDirectMessage

protocol ConversationRevokeCellDelegate: NSObject {
    func didReEdit(with cell: ConversationRevokeCell, message: TXIMMessage)
}

class ConversationRevokeCell: UITableViewCell {
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
        label.text = "Kamu menarik kembali pesan" //"Dia menarik kembali pesan."
        return label
    }()
    
    let secondlabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(hexString: "#3478F6")
        label.textAlignment = .center
        label.text = "Mengedit kembali pesan"
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
        self.bubbleView.addSubview(self.secondlabel)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.message = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let boundWidth = self.contentView.bounds.size.width
        
        if let _ = self.message {
            let bubbleSize = self.secondlabel.isHidden ? CGSize(width: 183, height: 30) : CGSize(width: 199, height: 44)
            let bubbleOrigin = CGPoint(x: (boundWidth - bubbleSize.width) / 2.0, y: 6)
            self.bubbleView.frame = CGRect(origin: bubbleOrigin, size: bubbleSize)
            self.label.frame = CGRect(origin: CGPoint(x: 0, y: 8), size: CGSize(width: bubbleSize.width, height: 14))
            self.secondlabel.frame = CGRect(origin: CGPoint(x: 0, y: self.label.frame.origin.y + self.label.frame.size.height), size: CGSize(width: bubbleSize.width, height: 14))
        } else {
            self.bubbleView.frame = CGRectZero
            self.label.frame = CGRectZero
            self.secondlabel.frame = CGRectZero
        }
    }
    
    func updateMessage(_ message: TXIMMessage) {
        self.message = message
        if message.isSelf {
            self.label.text = "Kamu menarik kembali pesan"
        } else {
            self.label.text = "Dia menarik kembali pesan"
        }
        let timestamp = message.revokeTimestamp ?? message.timestamp
        self.secondlabel.isHidden = timestamp.timeIntervalSinceNow <= -5 * 60 || !message.isSelf
        self.secondlabel.onTap { [weak self] in
            guard let self, let message = self.message else { return }
            self.delegate?.didReEdit(with: self, message: message)
        }
    }
    
    static func height(with message: TXIMMessage) -> CGFloat {
        let timestamp = message.revokeTimestamp ?? message.timestamp
        let twoLine = timestamp.timeIntervalSinceNow > -5 * 60 && message.isSelf
        return 6 + (twoLine ? 44 : 30) + 6
    }
}
