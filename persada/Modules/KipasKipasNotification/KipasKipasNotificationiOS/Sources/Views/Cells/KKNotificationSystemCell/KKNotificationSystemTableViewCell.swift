//
//  KKNotificationSystemTableViewCell.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 25/04/24.
//

import UIKit
import KipasKipasShared
import KipasKipasNotification

class KKNotificationSystemTableViewCell: UITableViewCell {

    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet weak var typeIconImageView: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var menuIconImageView: UIImageView!
    @IBOutlet weak var redDotView: UIView!
    @IBOutlet weak var createAtLabel: UILabel!
    @IBOutlet weak var viewMoreStackView: UIStackView!
    @IBOutlet weak var headerContainerStackView: UIStackView!
    @IBOutlet weak var titleMenuIconImageView: UIImageView!
    
    var didSelectMenu: (() -> Void)?
    var didSelectHeader: (() -> Void)?
    var didClickViewMore: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerStackView.clipsToBounds = true
        containerStackView.layer.cornerRadius = 4
        let iconHorizontalElipsisGrey: UIImage? = .iconHorizontalElipsisGrey?.withTintColor(UIColor(hexString: "#707070"), renderingMode: .alwaysOriginal)
        menuIconImageView.image = iconHorizontalElipsisGrey
        titleMenuIconImageView.image = iconHorizontalElipsisGrey
        
        let onTapMenuIconImageViewGesture = UITapGestureRecognizer(target: self, action: #selector(handleOnTapMenuIconImageView))
        menuIconImageView.isUserInteractionEnabled = true
        menuIconImageView.addGestureRecognizer(onTapMenuIconImageViewGesture)
        
        let onTapHeaderViewGesture = UITapGestureRecognizer(target: self, action: #selector(handleOnTapHeaderView))
        headerContainerStackView.isUserInteractionEnabled = true
        headerContainerStackView.addGestureRecognizer(onTapHeaderViewGesture)
        
        let onTapTitleMenuIconImageViewGesture = UITapGestureRecognizer(target: self, action: #selector(handleOnTapMenuIconImageView))
        titleMenuIconImageView.isUserInteractionEnabled = true
        titleMenuIconImageView.addGestureRecognizer(onTapTitleMenuIconImageViewGesture)
        
        let onTapViewMoreGesture = UITapGestureRecognizer(target: self, action: #selector(handleOnTapViewMore))
        viewMoreStackView.isUserInteractionEnabled = true
        viewMoreStackView.addGestureRecognizer(onTapViewMoreGesture)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        typeLabel.text = nil
        titleLabel.text = nil
        descriptionLabel.text = nil
        createAtLabel.text = nil
        didSelectMenu = nil
        didSelectHeader = nil
    }
    
    func configure(with item: NotificationSystemContent) {
        typeLabel.text = item.types
        titleLabel.text = item.title.isEmpty ? item.subTitle : item.title
        descriptionLabel.text = item.subTitle
//        redDotView.backgroundColor = item.isRead ? .clear : .warning
        redDotView.backgroundColor = .clear
        
        if item.types == "account" {
            typeIconImageView.image = .iconArrowUpGray
            typeLabel.text = "Akun Update"
        } else if item.types == "live" {
            typeIconImageView.image = .iconVideo
            typeLabel.text = item.types.uppercased()
        } else if item.types == "hotroom" {
            typeIconImageView.image = .iconNewsPaperGray
            typeLabel.text = "Sosial"
        } else if item.types == "undian" {
            let imageLotteryConfiguration = UIImage.SymbolConfiguration(weight: .bold)
            let imageLottery = UIImage(systemName: "gift", withConfiguration: imageLotteryConfiguration)?.withTintColor(.black, renderingMode: .alwaysOriginal)
            typeIconImageView.image = imageLottery
            typeLabel.text = "Undian"
        }
 
        let validEpoch = item.createdAt / 1000
        let date = Date(timeIntervalSince1970: TimeInterval(validEpoch))

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM"
        
        createAtLabel.text = dateFormatter.string(from: date)
    }
    
    @objc func handleOnTapMenuIconImageView() {
        didSelectMenu?()
    }
    
    @objc func handleOnTapHeaderView() {
        didSelectHeader?()
    }
    
    @objc func handleOnTapViewMore() {
        didClickViewMore?()
    }
}
