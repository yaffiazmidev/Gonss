//
//  CommentHalftView.swift
//  KipasKipas
//
//  Created by DENAZMI on 08/08/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class CommentHalftView: UIView {
    
    lazy var commentCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0 comment"
        label.font = .Roboto(.medium, size: 12)
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var closeIcon: UIView = {
        let view = UIView()
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.image = UIImage(named: .get(.iconClose))
        image.clipsToBounds = true
        image.isUserInteractionEnabled = true
        image.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(image)
        image.centerInSuperview(size: CGSize(width: 16.0, height: 16.0))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = .white
        view.separatorStyle = .none
        view.bounces = false
        view.alpha = 0
        return view
    }()
    
    lazy var commentTextViewPlaceholder: UILabel = {
        let label = UILabel()
        label.font = .Roboto(size: 12)
        label.textColor = .placeholder
        label.text = "Tulis Komentar"
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
//    lazy var commentTextView: UITextView = {
//        let view = UITextView()
//        view.font = .Roboto(size: 12)
//        view.backgroundColor = .white
//        view.textColor = .black
//        view.setBorderColor = .gainsboro
//        view.setBorderWidth = 1
//        view.setCornerRadius = 8
//        view.contentInset = UIEdgeInsets(top: 7, left: 12, bottom: 12, right: 12)
//        view.clipsToBounds = true
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
    
    lazy var sendIcon: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.image = UIImage(named: .get(.iconFeatherSendGray))
        image.clipsToBounds = true
        image.isUserInteractionEnabled = true
        image.translatesAutoresizingMaskIntoConstraints = false
        image.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        return image
    }()
    
    lazy var userProfileImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.image = UIImage(named: .get(.iconFeatherSendGray))
        image.clipsToBounds = true
        image.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        image.layer.cornerRadius = 18
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
//    lazy var commentStackView: UIStackView = {
//        let stackView = UIStackView(arrangedSubviews: [commentTextView, sendIcon])
//        stackView.axis = .horizontal
//        stackView.alignment = .center
//        stackView.spacing = 12.0
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        return stackView
//    }()
    
    lazy var commentInputView: CommentInputView = {
        let view = CommentInputView().loadViewFromNib() as! CommentInputView
        view.textView.isEditable = false
        return view
    }()
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [tableView])
        stackView.axis = .vertical
        stackView.spacing = 12.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    var commentInputViewHeightConstraint: NSLayoutConstraint! {
        didSet {
            commentInputViewHeightConstraint.isActive = true
        }
    }
    
    lazy var loadingActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.style = .medium
        indicator.color = .gray
        indicator.startAnimating()
        indicator.autoresizingMask = [
            .flexibleLeftMargin, .flexibleRightMargin,
            .flexibleTopMargin, .flexibleBottomMargin
        ]
        return indicator
    }()
    
    lazy var emptyCommentLabel: UILabel = {
        let label = UILabel()
        label.text = "Belum ada komentar"
        label.font = .Roboto(.medium, size: 12)
        label.textAlignment = .center
        label.textColor = .placeholder
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var navigationLine: UIView = {
        let view = UILabel()
        view.backgroundColor = .whiteSnow
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var startPaidView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondary
        view.setCornerRadius = 4
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    lazy var totalCoin: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "1"
        label.textColor = .white
        label.font = .roboto(.medium, size: 12)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    
    lazy var paidMessageContainerView: UIView = {
        let view = UILabel()
        view.backgroundColor = .white
        view.isUserInteractionEnabled = true
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let sendMessageLebel = UILabel()
        sendMessageLebel.text = "Kirim Pesan Berbayar"
        sendMessageLebel.font = .roboto(.medium, size: 12)
        sendMessageLebel.textColor = .contentGrey
        sendMessageLebel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sendMessageLebel)
        
        view.addSubview(startPaidView)
        
        let coinIcon = UIImageView()
        coinIcon.image = UIImage(named: "ic_coin_gold")
        coinIcon.contentMode = .scaleAspectFit
        coinIcon.isUserInteractionEnabled = true
        
        let totalCoinContainerStackView = UIStackView()
        totalCoinContainerStackView.axis = .horizontal
        totalCoinContainerStackView.alignment = .center
        totalCoinContainerStackView.spacing = 4
        totalCoinContainerStackView.addArrangedSubview(coinIcon)
        totalCoinContainerStackView.addArrangedSubview(totalCoin)
        totalCoinContainerStackView.translatesAutoresizingMaskIntoConstraints = false
        startPaidView.addSubview(totalCoinContainerStackView)
        
        NSLayoutConstraint.activate([
            sendMessageLebel.leftAnchor.constraint(equalTo: view.leftAnchor),
            sendMessageLebel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            
            startPaidView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            startPaidView.rightAnchor.constraint(equalTo: view.rightAnchor),
            startPaidView.widthAnchor.constraint(equalToConstant: 92),
            startPaidView.heightAnchor.constraint(equalToConstant: 26),
            
            coinIcon.widthAnchor.constraint(equalToConstant: 14),
            coinIcon.heightAnchor.constraint(equalToConstant: 14),
            
            totalCoinContainerStackView.centerYAnchor.constraint(equalTo: startPaidView.centerYAnchor, constant: 0),
            totalCoinContainerStackView.centerXAnchor.constraint(equalTo: startPaidView.centerXAnchor, constant: 0),
        ])
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commentInputView.textView.inputAccessoryView = nil
        commentInputView.userProfileImageView.loadImageWithoutOSS(at: LoggedUserKeychainStore(key: .loggedInUser).retrieve()?.photoUrl ?? "", placeholder: UIImage(named: "default-profile-image-small-circle"))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getCommentTextViewHeight(with value: String) -> CGFloat {
        let textHeight = commentInputView.textView.contentSize.height
        let calculateTextViewHeight = textHeight >= 80 ? 80 : textHeight >= 40 ? textHeight : 40
        return calculateTextViewHeight
    }
    
    func calculateTextViewHeight(with size: CGSize) -> CGFloat {
        let textHeight = size.height
        let calculateTextViewHeight = textHeight >= 100 ? 100 : textHeight >= 44 ? textHeight : 44
        return calculateTextViewHeight
    }
    
    func defaultTextView() {
        commentInputView.textView.text = nil
        commentInputView.placeholderLabel.isHidden = false
        commentInputView.sendIconContainerStackView.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.commentInputViewHeightConstraint?.constant = 44
            self.commentInputView.textViewHeightConstraint.constant = 28
            self.commentInputView.layoutIfNeeded()
            self.layoutIfNeeded()
        }
    }
}
