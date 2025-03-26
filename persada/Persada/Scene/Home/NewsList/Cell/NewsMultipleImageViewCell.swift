//
//  NewsMultipleImageViewCell.swift
//  KipasKipas
//
//  Created by PT.Koanba on 07/12/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class NewsMultipleImageViewCell: UITableViewCell {
    @IBOutlet weak var imageNewsOne: UIImageView!
    
    @IBOutlet weak var imageNewsThree: UIImageView!
    @IBOutlet weak var labelNewsPostedDate: UILabel!
    @IBOutlet weak var imageNewsTwo: UIImageView!
    @IBOutlet weak var labelCommentCount: UILabel!
    @IBOutlet weak var labelNewsTitle: UILabel!
    @IBOutlet weak var labelNewsSource: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpCell(item: NewsCellViewModel) {
    
        imageNewsOne.loadImage(at: item.imageNewsUrl ?? "", low: item.imageNewsUrl ?? "", .w480, .w40)
        imageNewsTwo.loadImageWithoutOSS(at: item.imageList[0])
        imageNewsThree.loadImageWithoutOSS(at: item.imageList[1])
        
        labelNewsTitle.text = item.title ?? ""
        labelNewsSource.text = item.source
        let time = TimeFormatHelper.soMuchTimeAgoMini(date: item.published ?? 0) ?? "1h"
        labelCommentCount.text = "\(item.comment ?? 0)"
        labelNewsPostedDate.text = time
    }
}
