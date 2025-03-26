//
//  ProfilePostCollectionViewCell.swift
//  KipasKipasProfileUI
//
//  Created by DENAZMI on 24/12/23.
//

import UIKit
import FeedCleeps

class ProfilePostCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var postThumbnailImageView: UIImageView!
    @IBOutlet weak var postTypeIconImageView: UIImageView!
    @IBOutlet weak var totalViewsLabel: UILabel!
    @IBOutlet weak var totalViewsContainerStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupView(with item: RemoteFeedItemContent) {
        let media = item.post?.medias?.first
        let isVideo = media?.type == "video"
        let isDonation = item.typePost == "donation"
        let postTypeIcon = PostMediaType.getProfileIcon(
            typePost: item.typePost ?? "",
            mediaCount: item.post?.medias?.count ?? 0,
            mediaType: media?.type ?? "",
            isContainsProduct: item.post?.product != nil
        )
        
        postTypeIconImageView.image = postTypeIcon
        totalViewsLabel.text = item.totalView?.formatViews()
        totalViewsContainerStackView.isHidden = isDonation ? false : isVideo ? false : true
        //postThumbnailImageView.loadImage(at: media?.thumbnail?.medium ?? "")
        postThumbnailImageView.loadImage(at: media?.thumbnail?.large ?? "", .w360, emptyImageName: "bg_tiktok")
    }

}
