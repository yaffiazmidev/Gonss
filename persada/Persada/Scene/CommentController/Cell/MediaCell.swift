//
//  MediaCell.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 06/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import IGListKit

protocol MediaCellDelegate : AnyObject {
    func didTapSeeProduct(cell : MediaCell)
}
class MediaCell : UICollectionViewCell, ListBindable {
	
    @IBOutlet weak var productView: UIView!
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    @IBOutlet weak var mediaPageControl: UIPageControl!
    @IBOutlet weak var seeProductButton: UIButton!

    @IBOutlet weak var priceLabel: UILabel!
    var controller : CommentSectionController!
    
    weak var delegate: MediaCellDelegate? = nil
    
    weak var viewModel: MediaViewModel? = nil
    
	override func awakeFromNib() {
		super.awakeFromNib()
        
        bindViewTap()
	}
	
	func bindViewModel(_ viewModel: Any) {
		guard let viewModel = viewModel as? MediaViewModel else { return }
        self.viewModel = viewModel
        
		mediaPageControl.numberOfPages = viewModel.media.count
		seeProductButton.isHidden = !viewModel.isHaveProduct
        priceLabel.text = viewModel.price
        
		if viewModel.media.count == 1 && !viewModel.isHaveProduct {
			productView.isHidden = true
			productView.heightAnchor.constraint(equalToConstant: 0).isActive = true
		}
        
        if !viewModel.isHaveProduct {
            productView.backgroundColor = .white
        }
		
	}
    
    func setDelegate(){
        controller.mediaDelegate = self
    }
    
    func bindViewTap(){
        seeProductButton.onTap {
            self.delegate?.didTapSeeProduct(cell: self)
        }
    }
}

extension MediaCell : MediaProtocol {
    func mediaDidEndDecelerating() {
        let pageWidth = mediaCollectionView.frame.size.width
        mediaPageControl.currentPage = Int(mediaCollectionView.contentOffset.x / pageWidth)
    }
}


