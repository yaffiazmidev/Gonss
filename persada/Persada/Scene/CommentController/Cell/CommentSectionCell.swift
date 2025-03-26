//
//  CommentCell.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 12/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import IGListKit

protocol CommentSectionCellDelegate : AnyObject {
    func didTapUserphotoComment(cell: CommentSectionCell)
    func didTapUsernameComment(cell: CommentSectionCell)
    func didTapLikeComment(cell: CommentSectionCell)
    func didTapReportComment(cell: CommentSectionCell)
    func didTapReplyComment(cell: CommentSectionCell)
    func didTapDeleteComment(cell: CommentSectionCell)
    func didTapMentionComment(cell: CommentSectionCell, mention: String)
    func didTapHashtagComment(cell: CommentSectionCell, hashtag: String)
}

class CommentSectionCell : UICollectionViewCell, ListBindable {
	
	@IBOutlet weak var userPhotoImage: UIImageView!
	
	@IBOutlet weak var userNameLabel: UILabel!
	
	
    @IBOutlet weak var userCommentLabel: ActiveLabel!
    @IBOutlet weak var likeButton: UIButton!
	@IBOutlet weak var totalLikeLabel: UILabel!
	
	@IBOutlet weak var deleteButton: UIButton!
	@IBOutlet weak var reportButton: UIButton!
	@IBOutlet weak var replyButton: UIButton!
	@IBOutlet weak var datePostedLabel: UILabel!
    
    weak var viewModel: CommentViewModel? = nil
	
    weak var delegate : CommentSectionCellDelegate? = nil
    
	override func awakeFromNib() {
		super.awakeFromNib()
        
        bindViewTap()
	}
    
    func updateReplyCounter(){
        DispatchQueue.main.async {
            guard let viewModel = self.viewModel else { return }
            self.replyButton.setTitle("\(viewModel.totalComment) Reply", for: .normal)
        }
    }
	
    func updateLike(){
        guard let viewModel = viewModel else { return }
        DispatchQueue.main.async {
            if viewModel.isLike {
                viewModel.totalLikes = viewModel.totalLikes + 1
                self.totalLikeLabel.text = "\(viewModel.totalLikes)"
                self.likeButton.image(.get(.iconHeart))
            } else {
                viewModel.totalLikes = viewModel.totalLikes - 1
                self.totalLikeLabel.text = "\(viewModel.totalLikes)"
                self.likeButton.image(.get(.iconLike))
            }
        }
    }
    
	func bindViewModel(_ viewModel: Any) {
		guard let viewModel = viewModel as? CommentViewModel else { return }
        self.viewModel = viewModel
        
		userNameLabel.text = viewModel.userName
        replyButton.setTitle("\(viewModel.totalComment) Reply", for: .normal)
        
        totalLikeLabel.text = String(viewModel.totalLikes)
        datePostedLabel.text = viewModel.date
        
        if viewModel.userID == getIdUser() {
            reportButton.isHidden = true
            deleteButton.isHidden = false
        } else {
            reportButton.isHidden = false
            deleteButton.isHidden = true
        }
        
        
        if viewModel.isLike {
            likeButton.setImage(UIImage(named: .get(.iconHeart)), for: .normal)
        }
        
        userCommentLabel.setLabel(prefixText: "", expanded: true, mainText: viewModel.comment, 100) {
            
        } suffixTap: {
            
        } mentionTap: { mention in
            self.delegate?.didTapMentionComment(cell: self, mention: mention)
        } hashtagTap: { hashtag in
            self.delegate?.didTapHashtagComment(cell: self, hashtag: hashtag)
        }
        guard let text = userCommentLabel.text?.startIndex else { return }
        userCommentLabel.text?.remove(at: text)
		var photo = viewModel.userPhoto
        
		userPhotoImage.loadImage(at: photo)
	}
	

    func bindViewTap(){
        userPhotoImage.onTap {
            self.delegate?.didTapUsernameComment(cell: self)
        }
        
        userNameLabel.onTap {
            self.delegate?.didTapUserphotoComment(cell: self)
        }
        
        likeButton.onTap {
            self.delegate?.didTapLikeComment(cell: self)
        }
        
        deleteButton.onTap {
            self.delegate?.didTapDeleteComment(cell: self)
        }
        
        reportButton.onTap {
            self.delegate?.didTapReportComment(cell: self)
        }
        
        replyButton.onTap {
            self.delegate?.didTapReplyComment(cell: self)
        }
    }
}
