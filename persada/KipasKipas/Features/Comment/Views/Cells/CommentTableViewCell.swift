//
//  CommentTableViewCell.swift
//  ExpandableTableView
//
//  Created by DENAZMI on 08/08/22.
//

import UIKit
import Kingfisher

protocol CommentTableViewCellDelegate: AnyObject {
    func didTapSeeMoreReply(indexPath: IndexPath)
    func didReplayComment(id: String, username: String)
    func didDeleteComment(id: String)
    func didReportComment(id: String, accountId: String)
    func didLikeComment(id: String)
    func navigateToProfile(id: String, type: String)
}

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var createDateLabel: UILabel!
    @IBOutlet weak var reportLabel: UILabel!
    @IBOutlet weak var deleteLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentLabel: ActiveLabel!
    @IBOutlet weak var seeMoreReplayLabel: UILabel!
    @IBOutlet weak var replayLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var likeIcon: UIImageView!
    @IBOutlet weak var badgeImageView: UIImageView!
    @IBOutlet weak var likeContainerStackView: UIStackView!
    @IBOutlet weak var seeMoreReplayStackView: UIStackView!
    @IBOutlet weak var verifiedIconImageView: UIImageView!
    
    weak var delegate: CommentTableViewCellDelegate?
    private var id: String = ""
    private var accountId: String = ""
    private var isLike: Bool = false
    private var indexPath: IndexPath = IndexPath()
    private var accountType: String = ""
    var mentionHandler: ((_ mention: String) -> Void)?
    var hashtagHandler: ((_ hashtag: String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        handleOnTap()
    }
    
    private func handleOnTap() {
        seeMoreReplayStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didTapSeeMoreReply(indexPath: self.indexPath)
        }
        
        replayLabel.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didReplayComment(id: self.id, username: "@\(self.usernameLabel.text ?? "") ")
        }
        
        deleteLabel.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didDeleteComment(id: self.id)
        }
        
        reportLabel.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didReportComment(id: self.id, accountId: self.accountId)
        }
        
        likeContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didLikeComment(id: self.id)
        }
        
        usernameLabel.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.navigateToProfile(id: self.accountId, type: self.accountType)
        }
        
        userImage.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.navigateToProfile(id: self.accountId, type: self.accountType)
        }
    }
    
    func setupView(comment: CommentEntity?, indexPath: IndexPath) {
        self.indexPath = indexPath
//        id = comment?.id ?? ""
        accountId = comment?.accountId ?? ""
        isLike = comment?.isLike ?? false
        id = comment?.id ?? ""
        accountType = comment?.accountType ?? ""
        verifiedIconImageView.isHidden = !(comment?.isVerified ?? false)
        
        
        let seeMoreText = "\(!(comment?.isOpened ?? false) ? "Lihat" : "Sembunyikan") \(comment?.replys.count ?? 0) Reply"
        
        usernameLabel.text = comment?.username ?? ""
        likeCountLabel.text = comment?.likes.formatViews()
        createDateLabel.text = comment?.createAt.timeAgoDisplay()
        seeMoreReplayLabel.text = seeMoreText
        
        //userImage.kf.indicatorType = .activity
        //userImage.kf.setImage(with: URL(string: comment?.photoUrl ?? ""), placeholder: UIImage.defaultProfileImageCircle)
        
        userImage.loadImage(at: comment?.photoUrl ?? "", .w80)
        
        let iconLike = UIImage(named: .get(.iconLike))?.withTintColor(.grey, renderingMode: .alwaysOriginal)
        let iconHeart = UIImage(named: .get(.iconHeart))
        likeIcon.image = comment?.isLike == true ? iconHeart : iconLike
        
        reportLabel.isHidden = comment?.accountId ?? "" == getIdUser()
        deleteLabel.isHidden = comment?.accountId ?? "" != getIdUser()
        seeMoreReplayStackView.isHidden = comment?.replys.isEmpty == true
        
        badgeImageView.isHidden = (comment?.urlBadge ?? "").isEmpty
        badgeImageView.kf.indicatorType = .activity
        badgeImageView.loadImage(at: comment?.urlBadge ?? "", .w80)
        badgeImageView.isHidden = comment?.isShowBadge == false
        
        
        commentLabel.numberOfLines = 0
        commentLabel.enabledTypes = [.mention, .hashtag, .url]
        commentLabel.text = comment?.messages ?? ""
        
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
