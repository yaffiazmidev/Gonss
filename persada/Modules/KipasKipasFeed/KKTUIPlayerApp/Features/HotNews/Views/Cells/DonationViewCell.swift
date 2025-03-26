//
//  DonationViewCell.swift
//  KKTUIPlayerApp
//
//  Created by DENAZMI on 02/10/23.
//

import UIKit
import TUIPlayerShortVideo

class DonationViewCell: UIView {
    
    weak var delegate: TUIPlayerShortVideoControlDelegate?
    
    private var feed: FeedItem = FeedItem() {
        didSet {
            
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadViewFromNib()
    }
}

extension DonationViewCell: TUIPlayerShortVideoControl {
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
            //self.currentPlayerStatus = currentPlayerStatus
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
