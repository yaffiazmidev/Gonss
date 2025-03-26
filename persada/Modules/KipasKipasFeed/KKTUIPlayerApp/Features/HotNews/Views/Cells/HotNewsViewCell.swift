//
//  HotNewsViewCell.swift
//  KKTUIPlayerApp
//
//  Created by DENAZMI on 25/09/23.
//

import UIKit
import TUIPlayerShortVideo

extension Notification.Name {
    static let handleWhenClickLikeOnHotNews = Notification.Name("handleWhenClickLikeOnHotNews")
}

class HotNewsViewCell: UIView {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var totalLikeLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    
    weak var delegate: TUIPlayerShortVideoControlDelegate?
    
    private var feed: FeedItem = FeedItem() {
        didSet {
            likeImageView.image = UIImage(named: "ic_love_\(feed.isLike == true ? "red" : "white")")
            totalLikeLabel.text = "\(feed.likes ?? 0)"
            usernameLabel.text = feed.account?.username ?? "-"
            captionLabel.text = feed.post?.description ?? "-"
        }
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
        
        likeImageView.onTap { [weak self] in
            guard let self = self else { return }
            
            if self.feed.isLike == false {
                self.feed.likes = (self.feed.likes ?? 0) + 1
            } else {
                self.feed.likes = (self.feed.likes ?? 0) - 1
            }
            
            self.feed.isLike?.toggle()
            self.videoModel = feed
            NotificationCenter.default.post(name: .handleWhenClickLikeOnHotNews, object: self.feed)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadViewFromNib()
    }
}

extension HotNewsViewCell: TUIPlayerShortVideoControl {
    var videoModel: TUIPlayerVideoModel {
        get {
            return self.feed
        }
        set {
            let item = FeedItem()
            item.coverPictureUrl = newValue.coverPictureUrl
            item.videoUrl = newValue.videoUrl
            item.duration = newValue.duration
            if let feed = newValue as? FeedItem {
                item.id = feed.id
                item.likes = feed.likes
                item.isLike = feed.isLike
                item.account = feed.account
                item.post = feed.post
            }
            
            self.feed = item
        }
    }
    
    var currentPlayerStatus: TUITXVodPlayerStatus {
        get {
            return self.currentPlayerStatus
        }
        set(currentPlayerStatus) {
//            self.currentPlayerStatus = currentPlayerStatus
        }
    }
    
    
    func showCenterView() {}
    
    func hideCenterView() {}
    
    func showLoadingView() {}
    
    func hiddenLoadingView() {}
    
    func setDurationTime(_ time: Float) {}
    
    func setCurrentTime(_ time: Float) {}
    
    func setProgress(_ progress: Float) {}
    
    func showSlider() {}
    
    func hideSlider() {}
}
