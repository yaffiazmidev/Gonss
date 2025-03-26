//
//  CommentInputView.swift
//  KipasKipas
//
//  Created by DENAZMI on 13/03/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import UIKit

class CommentInputView: UIView {
    
    @IBOutlet weak var mentionContainerStackView: UIStackView!
    @IBOutlet weak var sendIconContainerStackView: UIStackView!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateTextViewHeight() {
        let textHeight = textView.contentSize.height
        let calculateTextViewHeight = textHeight >= 150 ? 150 : textHeight >= 28 ? textHeight : 28
        textViewHeightConstraint.constant = calculateTextViewHeight
        layoutIfNeeded()
    }
}
