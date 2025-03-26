//
//  MentionCellTableViewCell.swift
//  KipasKipas
//
//  Created by Yaffi Azmi on 05/09/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class MentionCellTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .white
    }
    
    func setupView(item: FeedCommentMentionEntity) {
        
        let usernameAttributedString = NSAttributedString(string: String(item.name.dropFirst()), attributes: nil)

        // Create a mutable copy of the attributed text
        var mutableAttributedString = NSMutableAttributedString(attributedString: usernameAttributedString)
        
        let followingAttributedString = NSAttributedString(string: " • Following", attributes: [
            NSAttributedString.Key.font: UIFont.Roboto(.medium, size: 11),
            NSAttributedString.Key.foregroundColor: UIColor.grey,
        ])
        
        // Append the mentionAttributedString
        mutableAttributedString.append(followingAttributedString)

        // Set the updated attributed text back to the label
        usernameLabel.attributedText = item.isFollow ? mutableAttributedString : usernameAttributedString
        
        nameLabel.text = item.fullName
        pictureImageView.loadImage(at: item.photoUrl )
    }
}
