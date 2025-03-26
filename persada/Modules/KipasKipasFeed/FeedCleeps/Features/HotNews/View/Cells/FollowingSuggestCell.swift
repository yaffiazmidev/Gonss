//
//  FollowingSuggestCell.swift
//  FeedCleeps
//
//  Created by Rahmat Trinanda Pramudya Amar on 08/02/24.
//

import UIKit
import KipasKipasShared

protocol FollowingSuggestCellDelegate: AnyObject {
    func didClose(for cell: FollowingSuggestCell)
    func didFollow(for cell: FollowingSuggestCell)
    func didOpenProfile(for cell: FollowingSuggestCell)
    func didOpenFeed(for cell: FollowingSuggestCell, with media: RemoteFeedItemMedias)
}

class FollowingSuggestCell: UICollectionViewCell {
    
    // MARK: Variable
    weak var delegate: FollowingSuggestCellDelegate?
    
    private var medias: [RemoteFeedItemMedias]?
    private let profileSize: CGFloat = 80
    
    // MARK: View
    lazy var closeView: UIView = {
        let icon = UIImageView(image: UIImage(named: .get(.iconCloseWhite)))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(icon)
        icon.anchor(width: 12, height: 12)
        icon.centerInSuperview()
        
        return view
    }()
    
    lazy var profileImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: .get(.iconPersonWithCornerRadius))
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.layer.cornerRadius = profileSize / 2
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        
        return view
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .Roboto(.bold, size: 15)
        label.numberOfLines = 1
        return label
    }()
    
    lazy var verifyImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "ic_verified_solid_blue"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    lazy var nameVerifyView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [nameLabel, verifyImageView])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = 2
        view.alignment = .center
        verifyImageView.anchor(width: 12, height: 12)
        return view
    }()
    
    lazy var postCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        
        view.registerCustomCell(FollowingSuggestUserPostCell.self)
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        
        view.delegate = self
        view.dataSource = self
        
        return view
    }()
    
    lazy var followView: UIView = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Follow"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .Roboto(.bold, size: 16)
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .primary
        view.clipsToBounds = true
        view.layer.cornerRadius = 4
        view.addSubview(label)
        label.centerInSuperview()
        return view
    }()
    
    // MARK: Function
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = UIImage(named: .get(.iconPersonWithCornerRadius))
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
private extension FollowingSuggestCell {
    func configUI() {
        backgroundColor = .white.withAlphaComponent(0.2)
        clipsToBounds = true
        layer.cornerRadius = 8
        
        addSubviews([closeView, profileImageView, nameVerifyView, postCollectionView, followView])
        closeView.anchor(top: topAnchor, right: rightAnchor, paddingTop: 6, paddingRight: 6, width: 24, height: 24)
        profileImageView.anchor(top: topAnchor, paddingTop: 32, width: profileSize, height: profileSize)
        profileImageView.centerXTo(centerXAnchor)
        nameVerifyView.anchor(top: profileImageView.bottomAnchor, paddingTop: 8, paddingLeft: 12, paddingRight: 12, height: 18)
        nameVerifyView.centerXTo(centerXAnchor)
        postCollectionView.anchor(top: nameVerifyView.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 20, paddingLeft: 12, paddingRight: 12)
        followView.anchor(top: postCollectionView.bottomAnchor, bottom: bottomAnchor, paddingTop: 20, paddingBottom: 16, width: 130, height: 26)
        followView.centerXTo(centerXAnchor)
        
        setupOnTap()
    }
    
    func setupOnTap() {
        closeView.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didClose(for: self)
        }
        
        followView.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didFollow(for: self)
        }
        
        profileImageView.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didOpenProfile(for: self)
        }
        
        nameLabel.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didOpenProfile(for: self)
        }
    }
    
    func cellSize(for collectionView: UICollectionView) -> CGSize {
        let spacing = 5.0 * 2
        let size = collectionView.bounds
        return CGSize(width: (size.width - spacing) / 3, height: size.height)
    }
}

// MARK: - Internal Function
extension FollowingSuggestCell {
    func configure(with data: RemoteFollowingSuggestItem) {
        if let photo = data.account?.photo {
            profileImageView.loadImage(at: photo, .w140, emptyImageName: "iconPersonWithCornerRadius")
        }
        
        nameLabel.text = data.account?.name ?? ""
        verifyImageView.isHidden = !(data.account?.isVerified ?? false)
        
        medias = []
        for feed in data.feeds ?? [] {
            if let media = feed.post?.medias?.first {
                medias?.append(media)
                if (medias?.count ?? 0) >= 3 {
                    break
                }
            }
        }
        
        postCollectionView.reloadData()
    }
}

// MARK: - CollectionView Data Source
extension FollowingSuggestCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return medias?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCustomCell(with: FollowingSuggestUserPostCell.self, indexPath: indexPath)
        if let media = medias?[indexPath.item] {
            cell.configure(with: media)
            cell.delegate = self
        }
        return cell
    }
}

// MARK: - CollectionView Delegate
extension FollowingSuggestCell: UICollectionViewDelegate {}

// MARK: - CollectionView Layout Delegate
extension FollowingSuggestCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize(for: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let count = CGFloat(medias?.count ?? 0)
        let totalCellWidth = cellSize(for: collectionView).width * count
        let totalSpacingWidth = 5 * (count - 1)
        
        let leftInset = (collectionView.bounds.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
}

extension FollowingSuggestCell: FollowingSuggestUserPostCellDelegate {
    func didOpenFeed(for cell: FollowingSuggestUserPostCell) {
        guard let indexPath = cell.index(from: postCollectionView),
              let item = medias?[safe: indexPath.item]
        else { return }
        
        delegate?.didOpenFeed(for: self, with: item)
    }
}

// MARK: - User Cell Helper
fileprivate extension FollowingSuggestUserPostCell {
    func index(from collection: UICollectionView) -> IndexPath? {
        return collection.indexPath(for: self)
    }
}

// MARK: - Array Helper
fileprivate extension Array where Element == RemoteFeedItemMedias {
    func index(by id: String) -> Int? {
        return firstIndex(where: {$0.id == id})
    }
}
