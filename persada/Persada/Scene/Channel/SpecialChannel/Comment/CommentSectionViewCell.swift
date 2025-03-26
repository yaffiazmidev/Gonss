//
//  CommentSectionViewCell.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 22/06/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

enum LikeState{
    case enabled
    case disabled
}

class CommentSectionViewCell: UICollectionViewCell{
    static let className = "CommentSectionViewCell"
    static let idCell = "commentSectionViewCell"
    
    @IBOutlet var ivProfile: UIImageView!
    @IBOutlet var vSection: UIView!
    @IBOutlet var lUsername: UILabel!
    @IBOutlet var lContent: UILabel!
    @IBOutlet var lTime: UILabel!
    @IBOutlet var lLike: UILabel!
    @IBOutlet var bReport: UIButton!
    @IBOutlet var bDelete: UIButton!
    @IBOutlet var bLike: UIButton!
    @IBOutlet var svComment: UIStackView!
    @IBOutlet var lShowReply: UILabel!
    @IBOutlet var cvSubComment: UICollectionView!
    
    private var data: Comment!
    private var replyHandler: ((_ item: Comment) -> Void)!
    private var reportHandler: ((_ item: Comment) -> Void)!
    private var deleteHandler: ((_ item: Comment) -> Void)!
    private var likeHandler: ((_ item: Comment, _ isLiked: Bool) -> Void)!
    
    private var isSubComment: Bool!
    private var likeState: LikeState!
    
    @IBAction func onReply(_ sender: Any){
        self.replyHandler(self.data)
    }
    
    @IBAction func onReport(_ sender: Any){
        self.reportHandler(self.data)
    }
    
    @IBAction func onDelete(_ sender: Any){
        self.deleteHandler(self.data)
    }
    
    @IBAction func onLike(_ sender: Any){
        self.handleLike()
        self.likeHandler(self.data, self.likeState == .enabled)
    }
    
    func setupView(data: Comment, isSubComment: Bool , onReply: @escaping ((_ item: Comment) -> Void), onReport: @escaping ((_ item: Comment) -> Void), onDelete: @escaping ((_ item: Comment) -> Void), onLike: @escaping ((_ item: Comment, _ isLiked: Bool) -> Void)){
        self.data = data
        self.replyHandler = onReply
        self.reportHandler = onReport
        self.deleteHandler = onDelete
        self.likeHandler = onLike
        self.isSubComment = isSubComment
        
        if data.isLike ?? false {
            self.updateLikeState(.enabled)
        }else {
            self.updateLikeState(.disabled)
        }
        
        self.lUsername.text = data.account?.username ?? ""
        self.lContent.text = data.value ?? ""
        self.lContent.sizeToFit()
        self.lLike.text = "\(data.like ?? 0)"
        self.ivProfile.loadImage(at: data.account?.photo ?? "", .w360)
        self.ivProfile.contentMode = .scaleAspectFill
        self.ivProfile.layer.borderWidth = 1
        self.ivProfile.layer.masksToBounds = false
        self.ivProfile.layer.borderColor = UIColor.black.cgColor
        self.ivProfile.layer.cornerRadius = self.ivProfile.frame.height/2
        self.ivProfile.clipsToBounds = true
        
        if data.account?.id == getIdUser() {
            self.bReport.isHidden = true
        }else {
            self.bDelete.isHidden = true
        }
        
        if isSubComment {
            svComment.isHidden = true
        }else{
            if data.comments ?? 0 == 0 {
                svComment.isHidden = true
            }else{
                lShowReply.text = "Lihat \(data.comments ?? 0) Reply"
                lShowReply.onTap{
                    
                }
                
                cvSubComment.register(UINib(nibName: CommentSectionViewCell.className, bundle: nil), forCellWithReuseIdentifier: CommentSectionViewCell.idCell)
                cvSubComment.isHidden = true
            }
        }
    }
    
    func handleLike(){
        var count = self.data.like ?? 0
        if self.likeState == .enabled {
            self.updateLikeState(.disabled)
            count -= 1
        }else{
            self.updateLikeState(.enabled)
            count += 1
        }
        self.data.like = count
        self.lLike.text = "\(data.like ?? 0)"
    }
    
    private func updateLikeState(_ state: LikeState){
        self.likeState = state
        
        switch likeState {
        case .enabled:
            self.bLike.setImage(UIImage(named: .get(.iconCommentLikeEnabled)), for: .normal)
        case .disabled:
            self.bLike.setImage(UIImage(named: .get(.iconCommentLikeDisabled)), for: .normal)
        case .none:
            break
        }
    }
}
