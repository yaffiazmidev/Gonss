//
//  ExploreHeaderCollectionReusableView.swift
//  KipasKipas
//
//  Created by DENAZMI on 11/04/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

protocol ExploreHeaderDelegate: AnyObject {
    func didClickRecomChannelWith(index: Int)
    func didClickSeeMoreChannel()
    func showAuthPopUp()
}

class ExploreHeaderCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var delegate: ExploreHeaderDelegate?
    
    var channels: [ChannelsItemContent] = [] {
        didSet { collectionView.reloadData() }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        backgroundColor = .white
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerXibCell(ExploreChannelItemCollectionViewCell.self)
    }
}

extension ExploreHeaderCollectionReusableView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 2 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? channels.count : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(ExploreChannelItemCollectionViewCell.self, for: indexPath)
            let item = channels[indexPath.item]
            cell.channelTitleLabel.text = item.name
            cell.channelIcon.loadImage(at: item.photo, .w100)
            cell.containerStackView.alignment = .leading
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(ExploreChannelItemCollectionViewCell.self, for: indexPath)
            cell.channelTitleLabel.text = .get(.seeAllChannel)
            cell.channelIcon.image = UIImage(named: "iconMoreChannels")
            cell.containerStackView.alignment = .center
            return cell
        }
    }
}

extension ExploreHeaderCollectionReusableView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            guard AUTH.isLogin() else {
                delegate?.showAuthPopUp()
                return
            }
            
            delegate?.didClickRecomChannelWith(index: indexPath.item)
        } else {
            delegate?.didClickSeeMoreChannel()
        }
    }
}

extension ExploreHeaderCollectionReusableView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: collectionView.frame.width / 2 - 4, height: 44)
        } else {
            return CGSize(width: collectionView.frame.width, height: 44)
        }
    }
}
