//
//  NewsTopTitleWithDescriptionViewCell.swift
//  KipasKipas
//
//  Created by PT.Koanba on 07/12/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

class NewsTopTitleWithDescriptionViewCell: UITableViewCell {

    @IBOutlet weak var labelNewsTitle: UILabel!
    @IBOutlet weak var labelNewsDescription: UILabel!
    @IBOutlet weak var imageNews: UIImageView!
    
    @IBOutlet weak var labelCommentCount: UILabel!
    @IBOutlet weak var labelNewsPostedDate: UILabel!
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
        imageNews.loadImage(at: item.imageNewsUrl ?? "", low: item.imageNewsUrl ?? "" , .w576, .w40)
        labelNewsTitle.text = item.title ?? ""
        labelNewsSource.text = item.source
        let time = TimeFormatHelper.soMuchTimeAgoMini(date: item.published ?? 0) ?? "1h"
        labelCommentCount.text = "\(item.comment ?? 0)"
        labelNewsPostedDate.text = time
        
        let htmlString = item.newsDetail?.postNews?.content ?? ""
        labelNewsDescription.text = htmlString.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}
