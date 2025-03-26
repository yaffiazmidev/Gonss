//
//  RowTagProduct.swift
//  AppVideo
//
//  Created by Icon+ Gaenael on 18/02/21.
//

import UIKit

class RowTagProduct: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
		@IBOutlet weak var btnDelete: UIButton!
	
		@IBOutlet weak var photoMarginLeft: NSLayoutConstraint!
    @IBOutlet weak var lblNameMarginRight: NSLayoutConstraint!
    @IBOutlet weak var lblPriceMarginRight: NSLayoutConstraint!
	
		var onCloseClick : (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        imgView.layer.cornerRadius = 8
        lblName.font = UIFont.Roboto(.regular, size: 16)
        lblPrice.font = UIFont.Roboto(.bold, size: 16)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupMargin(_ margin: CGFloat){
        photoMarginLeft.constant = margin
        lblNameMarginRight.constant = margin
        lblPriceMarginRight.constant = margin
    }
    
    func setupData(_ d: Product){
			if let imgUrl = d.medias?.first?.thumbnail?.small{
            imgView.loadImage(at: imgUrl)
        }
        lblName.text = d.name
        lblPrice.text = d.price?.toMoney()
    }
    
    func disable(){
        imgView.alpha = 0.5
        lblName.alpha = 0.5
        lblPrice.alpha = 0.5
    }
    
	@IBAction func onDeleteClick(_ sender: Any) {
		onCloseClick?()
	}
}
