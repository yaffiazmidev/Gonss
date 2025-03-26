//
//  SubcommentTableViewCell.swift
//  KipasKipas
//
//  Created by Yaffi Azmi on 14/09/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class SubcommentTableViewCell: UITableViewCell {
    
    static let identifier = "SubcommentTableViewCell"
    static let cellNib = UINib(nibName: "SubcommentTableViewCell", bundle: nil)
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var componentBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var userImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var userImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var componentLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var componentTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentLabel: ActiveLabel!
    @IBOutlet weak var headerCommentLabel: ActiveLabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var deleteLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var likeStackView: UIStackView!
    @IBOutlet weak var headerCommentStackView: UIStackView!
    @IBOutlet weak var likeIcon: UIImageView!
    
    var isHeader: Bool = false {
        didSet {
            userImageHeightConstraint.constant = isHeader ? 50 : 32
            userImageWidthConstraint.constant = isHeader ? 50 : 32
            componentLeadingConstraint.constant = isHeader ? 24 : 16
            componentTrailingConstraint.constant = isHeader ? 24 : 16
            componentBottomConstraint.constant = isHeader ? 16 : 0
            userImageView.layer.cornerRadius = isHeader ? 25 : 16
            likeStackView.isHidden = isHeader
            commentLabel.isHidden = isHeader
            headerCommentLabel.isHidden = !isHeader
            headerCommentStackView.isHidden = !isHeader
            likeCountLabel.isHidden = isHeader
            layoutIfNeeded()
        }
    }
        
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .white
    }
    
    func setupCommentBodyView(item: Subcomment?) {
        userImageView.loadImage(at: item?.account?.photo ?? "", .w80)
        
        usernameLabel.text = item?.account?.username ?? ""
        commentLabel.text = item?.value ?? ""
        likeCountLabel.text = "\(item?.like ?? 0)"
        likeIcon.image = UIImage(named: item?.isLike == true ?
                                    String.get(.iconHeart) : String.get(.iconLike))
        
        let createAtFormat = Date(timeIntervalSince1970: TimeInterval((item?.createAt ?? 1000)/1000 )).timeAgoDisplay()
        dateLabel.text = createAtFormat
    }
    
    func setupCommentHeaderView(item: SubcommentModel.SubcommentHeader?) {
        userImageView.loadImage(at: item?.imageUrl ?? "", .w80)
        
        usernameLabel.text = item?.username ?? ""
        headerCommentLabel.text = item?.description ?? ""
        let createAtFormat = Date(timeIntervalSince1970: TimeInterval((item?.date ?? 1000)/1000 )).timeAgoDisplay()
        dateLabel.text = createAtFormat
    }
}
