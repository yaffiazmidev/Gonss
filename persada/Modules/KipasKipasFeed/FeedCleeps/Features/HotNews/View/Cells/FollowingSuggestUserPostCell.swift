//
//  FollowingSuggestUserPostCell.swift
//  FeedCleeps
//
//  Created by Rahmat Trinanda Pramudya Amar on 10/02/24.
//

import UIKit

protocol FollowingSuggestUserPostCellDelegate {
    func didOpenFeed(for cell: FollowingSuggestUserPostCell)
}

class FollowingSuggestUserPostCell: UICollectionViewCell {
    
    var delegate: FollowingSuggestUserPostCellDelegate?
    
    // MARK: View
    lazy var imageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: .get(.empty)))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    // MARK: Function
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = UIImage(named: .get(.empty))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configUI()
    }
}

// MARK: - Private Function
private extension FollowingSuggestUserPostCell {
    func configUI() {
        backgroundColor = .clear
        addSubview(imageView)
        imageView.fillSuperview()
    }
}

// MARK: - Internal Function
extension FollowingSuggestUserPostCell {
    func configure(with item: RemoteFeedItemMedias) {
        imageView.loadImage(at: item.thumbnail?.medium ?? "", .w140, emptyImageName: "empty")
        
        imageView.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didOpenFeed(for: self)
        }
    }
}
