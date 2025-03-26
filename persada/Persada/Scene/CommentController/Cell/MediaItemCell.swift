//
//  MediaItemCell.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 13/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//
import UIKit
import IGListKit
import CoreMedia
import KipasKipasShared

class MediaItemCell : UICollectionViewCell, ListBindable {
    
    @IBOutlet weak var mediaContainerView: UIView!
    @IBOutlet weak var mediaPageControl: UIPageControl!
    @IBOutlet weak var seeProductButton: UIButton!
    @IBOutlet weak var visitStoreButton: UIButton!
    @IBOutlet weak var iconPauseImage: UIImageView!
    @IBOutlet weak var timerBackgroundView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    
    
    var video : AGVideoPlayerView?
    let image = UIImageView(frame: .zero)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        video?.delegate = self
        backgroundColor = .white
    }
    
    func bindViewModel(_ viewModel: Any){
        guard let viewModel = viewModel as? MediaItemViewModel else { return }
        if viewModel.isVideo {
            video = nil
            video?.showsCustomControls = true
            video?.previewLowImageUrl = URL(string: viewModel.thumbnail)
            video?.previewImageUrl = URL(string: viewModel.thumbnail)
            video?.videoUrl = URL(string: viewModel.url)
            video?.shouldAutoplay = true
            video?.shouldAutoRepeat = true
            video?.videoScalingMode = .resizeAspectFill
            video?.minimumVisibilityValueForStartAutoPlay = 0.9
            if let video = video {
                mediaContainerView.addSubview(video)
            }
            timerBackgroundView.isHidden = false
            iconPauseImage.isHidden = true
            video?.fillSuperview()
        } else {
            video = AGVideoPlayerView()
            video?.delegate = self
            timerBackgroundView.isHidden = true
            iconPauseImage.isHidden = true
            mediaContainerView.addSubview(image)
            image.clipsToBounds = true
            image.contentMode = .scaleAspectFit
            image.fillSuperview()
            image.loadImage(at: viewModel.url
                                            , low: viewModel.thumbnail)
        }
    }
    
    func bindData(medias: KKMediaItem){
        switch medias.type {
            case .photo:
            video = nil
            image.backgroundColor = .white
            image.image = UIImage(data: medias.data!)
            timerBackgroundView.isHidden = true
            iconPauseImage.isHidden = true
            mediaContainerView.addSubview(image)
            image.clipsToBounds = true
            image.contentMode = .scaleAspectFit
            image.fillSuperview()
        case .video:
            video = AGVideoPlayerView()
            video?.delegate = self
            image.backgroundColor = .white
            video?.backgroundColor = .white
            video?.showsCustomControls = true
            video?.videoUrl = URL(string: medias.path)
            video?.shouldAutoplay = false
            video?.shouldAutoRepeat = true
            video?.videoScalingMode = .resizeAspectFill
            if let video = video {
                mediaContainerView.addSubview(video)
            }
            timerBackgroundView.isHidden = false
            iconPauseImage.isHidden = true
            video?.fillSuperview()
            }
    }
    
    func bindData(medias: Medias){
            switch medias.type {
            case "image":
                video = nil
                image.backgroundColor = .white
                image.loadImage(at: medias.url ?? "")
                timerBackgroundView.isHidden = true
                iconPauseImage.isHidden = true
                mediaContainerView.addSubview(image)
                image.clipsToBounds = true
                image.contentMode = .scaleAspectFit
                image.fillSuperview()
            case "video":
                video = AGVideoPlayerView()
                video?.delegate = self
                image.backgroundColor = .white
                video?.backgroundColor = .white
                video?.showsCustomControls = true
                video?.videoUrl = URL(string: medias.url ?? "")
                video?.shouldAutoplay = true
                video?.shouldAutoRepeat = true
                video?.videoScalingMode = .resizeAspectFill
                video?.minimumVisibilityValueForStartAutoPlay = 0.9
                if let video = video {
                    mediaContainerView.addSubview(video)
                }
                timerBackgroundView.isHidden = false
                iconPauseImage.isHidden = true
                video?.fillSuperview()
            default :
                return
            }
    }
}

extension MediaItemCell : AGVideoPlayerViewDelegate {
    func videoPlaying() {
        iconPauseImage.isHidden = true
    }
    
    func videoPause() {
        iconPauseImage.isHidden = false
    }
    
    func timeChange(_ time: String) {
        if !timerBackgroundView.isHidden {
            timerLabel.text = time
        }
    }
    
    
}
