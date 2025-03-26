//
//  ProfilePostView.swift
//  KipasKipasProfileUI
//
//  Created by DENAZMI on 24/12/23.
//

import UIKit
import FeedCleeps

protocol ProfilePostViewDelegate: AnyObject {
    func didSelectPost(content: RemoteFeedItemContent)
}

class ProfilePostView: UIView {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var posts: [RemoteFeedItemContent] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    weak var delegate: ProfilePostViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerNib(ProfilePostCollectionViewCell.self)
    }
}

extension ProfilePostView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ProfilePostCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.setupView(with: posts[indexPath.item])
        return cell
    }
}

extension ProfilePostView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectPost(content: posts[indexPath.item])
    }
}

extension ProfilePostView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let dividerWidth = 1
        let numberOfItemsInRow = 3
        let numberOfDividers = numberOfItemsInRow - 1
        let totalSpacing = dividerWidth * numberOfDividers // Adjust the spacing value as needed
        
        let screenWidth = UIScreen.main.bounds.width
        let cellWidth = (screenWidth - CGFloat(totalSpacing)) / CGFloat(numberOfItemsInRow)
        
        return CGSize(width: cellWidth, height: 185)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}
