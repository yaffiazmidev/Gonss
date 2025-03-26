//
//  CaptionCell.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 06/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import IGListKit

protocol CaptionCellDelegate: AnyObject {
    func didTapUsernameCaption(cell: CaptionCell)
    func didTapMention(cell: CaptionCell, mention: String)
    func didTapHashtag(cell: CaptionCell, hashtag: String)
}

class CaptionCell : UICollectionViewCell, ListBindable {
	
	
	
	@IBOutlet weak var captionLabel: ActiveLabel!
	
    @IBOutlet weak var dateLabel: UILabel!
    
    weak var delegate: CaptionCellDelegate? = nil
    weak var viewModel: CaptionViewModel? = nil
    
	override func awakeFromNib() {
		super.awakeFromNib()
        
	}
	
	func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? CaptionViewModel else { return }
        self.viewModel = viewModel
        
        dateLabel.text = viewModel.date
        
        var descText = viewModel.caption
        while descText.last == "\n" {
            descText.removeLast()
        }
		captionLabel.setLabel(prefixText: viewModel.userName, expanded: true, mainText: descText, 100) {
            self.delegate?.didTapUsernameCaption(cell: self)
		} suffixTap: {
            
		} mentionTap: { (mention) in
            self.delegate?.didTapMention(cell: self, mention: mention)
		} hashtagTap: { (hashtag) in
            self.delegate?.didTapHashtag(cell: self, hashtag: hashtag)
		}

	}
}
 
