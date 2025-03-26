//
//  ShortcutStoryView.swift
//  KipasKipas
//
//  Created by DENAZMI on 23/01/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import UIKit
import FeedCleeps

protocol ShortcutStoryViewDelegate: AnyObject {
    func didSelectedStory(with item: FeedItem)
    func didSelectedMyStory(with item: FeedItem?)
}

class ShortcutStoryView: UIView {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var buttonCloseContainerStackView: UIStackView!
    @IBOutlet weak var closeIconImageView: UIImageView!
    @IBOutlet weak var storyLabel: UILabel!
    
    var isExpanded: Bool = false {
        didSet {
            storyLabel.isHidden = isExpanded
            closeIconImageView.isHidden = !isExpanded
        }
    }
    
    var feeds: [FeedItem] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    weak var delegate: ShortcutStoryViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubViews()
        setupComponent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubViews()
    }
    
    private func initSubViews() {
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: Bundle(for: type(of: self)))
        nib.instantiate(withOwner: self, options: nil)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        addConstraints()
    }
    
    func setupComponent() {
        setupCollectionView()
        overrideUserInterfaceStyle = .light
        backgroundColor = .white
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        layer.cornerRadius = 12
        clipsToBounds = true
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: containerView.topAnchor),
            bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = .init(top: 0, left: 6, bottom: 0, right: 6)
        collectionView.registerXibCell(ShortcutStoryViewCell.self)
    }
}

extension ShortcutStoryView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 1 : feeds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(ShortcutStoryViewCell.self, for: indexPath)
            cell.usernameLabel.text = "My Story"
            cell.userProfileImageView.image = UIImage(named: "img_profile_empty")
            cell.addStoryIconImageView.isHidden = false
            cell.addStoryIconImageView.setBorderWidth = 0
//            cell.backgroundColor = .blue
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(ShortcutStoryViewCell.self, for: indexPath)
            let item = feeds[indexPath.item]
            cell.usernameLabel.text = item.account?.username ?? ""
            cell.userProfileImageView.loadImageWithoutOSS(at: item.account?.photo ?? "")
            cell.addStoryIconImageView.isHidden = true
            cell.addStoryIconImageView.setBorderWidth = 2
//            cell.backgroundColor = .yellow
            return cell
        }
    }
}

extension ShortcutStoryView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard getToken() != nil else {
            showLogin?()
            return
        }
        
        if indexPath.section == 0 {
            delegate?.didSelectedMyStory(with: nil)
        } else {
            let item = feeds[indexPath.item]
            delegate?.didSelectedStory(with: item)
        }
    }
}

extension ShortcutStoryView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return indexPath.section == 0 ? CGSize(width: 58, height: 86) : CGSize(width: 58, height: 86)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 12
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 12
//    }
}
