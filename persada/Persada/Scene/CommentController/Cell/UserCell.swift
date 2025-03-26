//
//  UserCell.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 06/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import IGListKit


protocol UserCellDelegate: AnyObject {
    func didTapUserPhoto(cell: UserCell)
    func didTapUserName(cell: UserCell)
    func didTapSubtitleLabel(cell: UserCell)
    func didTapShop(cell: UserCell)
    func didTapChat(cell: UserCell)
    func didTapKebabButton(cell: UserCell)
}

class UserCell : UICollectionViewCell, ListBindable {
	@IBOutlet weak var userPhotoImageView: UIImageView!
	@IBOutlet weak var userNameLabel: UILabel!
	@IBOutlet weak var postedDateLabel: UILabel!
	@IBOutlet weak var kebabMenuButton: UIButton!
    @IBOutlet weak var shopButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    
    @IBOutlet weak var iconVerifiedImageView: UIImageView!
    
    weak var delegate: UserCellDelegate? = nil
    
    weak var viewModel: UserViewModel? = nil
    
    override func awakeFromNib() {
		super.awakeFromNib()
        
        bindViewTap()
	}
	
	func bindViewModel(_ viewModel: Any){
		guard let viewModel = viewModel as? UserViewModel else { return }
        self.viewModel = viewModel
		userPhotoImageView.loadImage(at: viewModel.userPhoto)
		userNameLabel.text = viewModel.userName
        
        if viewModel.isHaveShop {
            shopButton.isHidden = false
        }
        
        if viewModel.isOnWikipedia {
            setOnWikipediaLabel()
        }
        
        if viewModel.isVerified {
            iconVerifiedImageView.isHidden = false
        }
	}
    
    func setOnWikipediaLabel() {
        self.postedDateLabel.isHidden = false
        let imageAttachment = NSTextAttachment()
                imageAttachment.image = UIImage(named: AssetEnum.wikipedia.rawValue.uppercased())
        imageAttachment.bounds = CGRect(x: 0, y: 0, width: imageAttachment.image!.size.width * 1.1, height: imageAttachment.image!.size.height * 1.1)

        let wikiImage = NSAttributedString(attachment: imageAttachment)
        let onText = NSAttributedString(string: "on ")
        
        let completeText = NSMutableAttributedString(string: "")
        completeText.append(onText)
        completeText.append(wikiImage)
        self.postedDateLabel.textAlignment = .left
        self.postedDateLabel.attributedText = completeText
    }
    
    func bindViewTap(){
        userPhotoImageView.onTap {
            self.delegate?.didTapUserPhoto(cell: self)
        }
        
        userNameLabel.onTap {
            self.delegate?.didTapUserName(cell: self)
        }
        
        postedDateLabel.onTap {
            self.delegate?.didTapSubtitleLabel(cell: self)
        }
        
        kebabMenuButton.onTap {
            self.delegate?.didTapKebabButton(cell: self)
        }
        
        shopButton.onTap {
            self.delegate?.didTapShop(cell: self)
        }
        
        chatButton.onTap {
            self.delegate?.didTapChat(cell: self)
        }
    }
}
