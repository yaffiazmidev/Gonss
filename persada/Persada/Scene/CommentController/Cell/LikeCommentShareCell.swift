//
//  LikeCommentShareCell.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 07/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//
import UIKit
import IGListKit

protocol LikeCommentShareCellDelegate : AnyObject {
    func didTapLike(cell: LikeCommentShareCell)
    func didTapComment(cell: LikeCommentShareCell)
    func didTapShare(cell: LikeCommentShareCell)
}

class LikeCommentShareCell : UICollectionViewCell, ListBindable {
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var totalLikeLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var totalCommentLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    
    weak var delegate: LikeCommentShareCellDelegate? = nil
    weak var viewModel: LikeAndCommentViewModel? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bindViewTap()
    }
    
    func updateLike(vc : CommentViewController){
        guard let viewModel = viewModel else { return }
        DispatchQueue.main.async {
            if viewModel.isLiked {
                viewModel.totalLikes = viewModel.totalLikes + 1
                vc.likeChange(viewModel.isLiked, viewModel.totalLikes)
                self.totalLikeLabel.text = "\(viewModel.totalLikes)"
                self.likeButton.image(.get(.iconHeart))
            } else {
                viewModel.totalLikes = viewModel.totalLikes - 1
                vc.likeChange(viewModel.isLiked, viewModel.totalLikes)
                self.totalLikeLabel.text = "\(viewModel.totalLikes)"
                self.likeButton.image(.get(.iconLike))
            }
        }
    }
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? LikeAndCommentViewModel else { return }
        self.viewModel = viewModel
        totalLikeLabel.text = "\(viewModel.totalLikes)"
        totalCommentLabel.text = "\(viewModel.totalComment)"
        
        if viewModel.isLiked {
            likeButton.setImage(UIImage(named: .get(.iconHeart)), for: .normal)
        }
    }
    
    func bindViewTap(){
        likeButton.onTap {
            self.delegate?.didTapLike(cell: self)
        }
        
        commentButton.onTap {
            self.delegate?.didTapComment(cell: self)
        }
        
        shareButton.onTap {
            self.delegate?.didTapShare(cell: self)
        }
    }
}

