//
//  CommentReplyTableViewCell.swift
//  ExpandableTableView
//
//  Created by DENAZMI on 08/08/22.
//

import UIKit
import Kingfisher

protocol CommentReplyTableViewCellDelegate: AnyObject {
    func didpReplaySubcomment(commentId: String, username: String)
    func didDeleteSubcomment(commentId: String, subcommentId: String)
    func didReportSubcomment(subcommentId: String, accountId: String)
    func didLikeSubcomment(id: String, commentId: String, isLike: Bool)
    func navigateToProfileSubcomment(id: String, type: String)
}

class CommentReplyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var reportLabel: UILabel!
    @IBOutlet weak var deleteLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentLabel: ActiveLabel!
    @IBOutlet weak var replayLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var likeIcon: UIImageView!
    @IBOutlet weak var createDateLabel: UILabel!
    @IBOutlet weak var badgeImageView: UIImageView!
    @IBOutlet weak var likeContainerStackView: UIStackView!
    @IBOutlet weak var verifiedIconImageView: UIImageView!
    
    weak var delegate: CommentReplyTableViewCellDelegate?
    private var isLike: Bool = false
    private var commentId: String = ""
    private var accountId: String = ""
    private var subcommentId: String = ""
    private var accountType: String = ""
    var mentionHandler: ((_ mention: String) -> Void)?
    var hashtagHandler: ((_ hashtag: String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        handleOnTap()
    }
    
    private func handleOnTap() {
        replayLabel.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didpReplaySubcomment(commentId: self.commentId, username: "@\(self.usernameLabel.text ?? "") ")
        }
        
        deleteLabel.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didDeleteSubcomment(commentId: self.commentId, subcommentId: self.subcommentId)
        }
        
        reportLabel.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didReportSubcomment(subcommentId: self.subcommentId, accountId: self.accountId)
        }
        
        likeContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didLikeSubcomment(id: self.subcommentId, commentId: self.commentId, isLike: self.isLike)
        }
        
        usernameLabel.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.navigateToProfileSubcomment(id: self.accountId, type: self.accountType)
        }
        
        userImage.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.navigateToProfileSubcomment(id: self.accountId, type: self.accountType)
        }
    }
    
    func setupView(subcomment: CommentEntityReply?, commentId: String ) {
        self.commentId = commentId
//        subcommentId = subcomment?.id ?? ""
        accountId = subcomment?.accountId ?? ""
        isLike = subcomment?.isLike ?? false
        subcommentId = subcomment?.id ?? ""
        accountType = subcomment?.accountType ?? ""
        verifiedIconImageView.isHidden = !(subcomment?.isVerified ?? false)
        
        reportLabel.isHidden = accountId == getIdUser()
        deleteLabel.isHidden = accountId != getIdUser()
        
        createDateLabel.text = subcomment?.createAt.timeAgoDisplay()
        userImage.loadImage(at: subcomment?.photoUrl ?? "")
        usernameLabel.text = subcomment?.username ?? ""
        likeCountLabel.text = subcomment?.likes.formatViews()
        let iconLike = UIImage(named: .get(.iconLike))?.withTintColor(.grey, renderingMode: .alwaysOriginal)
        let iconHeart = UIImage(named: .get(.iconHeart))
        likeIcon.image = subcomment?.isLike == true ? iconHeart : iconLike
        
        badgeImageView.isHidden = (subcomment?.urlBadge ?? "").isEmpty
        badgeImageView.kf.indicatorType = .activity
        badgeImageView.loadImage(at: subcomment?.urlBadge ?? "", .w80)
        badgeImageView.isHidden = subcomment?.isShowBadge == false
        
        commentLabel.numberOfLines = 0
        commentLabel.enabledTypes = [.mention, .hashtag, .url]
        commentLabel.text = subcomment?.messages ?? ""
        
        commentLabel.customize { [weak self] label in
            guard let self = self else { return }
            
            label.lineSpacing = 0.2
            label.font = .systemFont(ofSize: 15, weight: .medium)
            label.textColor = .black
            label.hashtagColor = .secondary
            label.mentionColor = .secondary
            label.URLColor = .link
            
            label.handleMentionTap {
                self.mentionHandler?($0)
            }
            
            label.handleHashtagTap {
                self.hashtagHandler?($0)
            }
            
            label.handleURLTap {
                print($0.absoluteString)
            }
        }
    }
}
