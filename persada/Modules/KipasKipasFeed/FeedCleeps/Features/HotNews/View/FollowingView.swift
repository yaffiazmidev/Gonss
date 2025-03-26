//
//  FollowingView.swift
//  FeedCleeps
//
//  Created by Rahmat Trinanda Pramudya Amar on 06/02/24.
//

import UIKit
import KipasKipasShared

protocol FollowingViewDelegate: AnyObject {
    func didRefresh()
    func didFollow(account id: String)
    func didOpenProfile(for account: RemoteUserProfileData)
    func didOpenFeed(for id: String)
}

class FollowingView: UIView {
    // MARK: Variable
    weak var delegate: FollowingViewDelegate?
    private var data: [RemoteFollowingSuggestItem] = []
    
    private let containerHeight: CGFloat = 340
    private let cellWidth: CGFloat = 234
    
    // MARK: View
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .white
        label.text = "Follow orang lain untuk berinteraksi dengan mereka 😃"
        label.font = .Roboto(.bold, size: 18)
        label.textAlignment = .center
        return label
    }()
    
    lazy var refreshView: UIView = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Muat Ulang"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .Roboto(.bold, size: 16)
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .primary
        view.clipsToBounds = true
        view.layer.cornerRadius = 4
        view.addSubview(label)
        label.fillSuperview(padding: .init(top: 8, left: 12, bottom: 8, right: 12))
        return view
    }()
    
    lazy var emptyDescriptionView: UIView = {
        let icon = UIImageView(image: UIImage(named: .get(.iconGroupFillWhite)), contentMode: .scaleAspectFit)
        icon.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Klik tombol dibawah untuk mendapat rekomendasi lainnya atau menampilkan konten user yang sudah kamu ikuti."
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .Roboto(.medium, size: 13)
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews([icon, label])
        icon.anchor(top: view.topAnchor, width: 40, height: 40)
        icon.centerXTo(view.centerXAnchor)
        label.anchorFeedCleeps(top: icon.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 16)
        
        return view
    }()
    
    lazy var emptyView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white.withAlphaComponent(0.2)
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        view.addSubviews([emptyDescriptionView, refreshView])
        emptyDescriptionView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 16, paddingRight: 16)
        refreshView.anchor(top: emptyDescriptionView.bottomAnchor, bottom: view.bottomAnchor, paddingTop: 16, paddingBottom: 20)
        refreshView.centerXTo(view.centerXAnchor)
        
        return view
    }()
    
    lazy var collectionViewLayout: PagingableCollectionViewLayout = {
        let spacing = (UIScreen.main.bounds.width - cellWidth) / 2
        let layout = PagingableCollectionViewLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
        layout.itemSize = CGSize(width: cellWidth, height: containerHeight)
        layout.minimumLineSpacing = 18
        
        return layout
    }()
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.isHidden = true
        
        view.registerCustomCell(FollowingSuggestCell.self)
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        
        view.delegate = self
        view.dataSource = self
        
        return view
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews([emptyView, collectionView])
        emptyView.anchor(width: 268)
        emptyView.centerInSuperview()
        collectionView.fillSuperview()
        
        return view
    }()
    
    // MARK: Function
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
        setupNotificationObserver()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configUI()
        setupNotificationObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Internal Function
extension FollowingView {
    func configure(with data: [RemoteFollowingSuggestItem]) {
        self.data = data
        updateView()
        collectionView.reloadData()
    }
}

// MARK: - Private Function
private extension FollowingView {
    func configUI() {
        backgroundColor = .init(hexString: "#10012F")
        
        addSubviews([containerView, titleLabel])
        containerView.anchorFeedCleeps(left: leftAnchor, right: rightAnchor, height: containerHeight)
        containerView.centerYTo(centerYAnchor)
        titleLabel.anchor(left: leftAnchor, bottom: containerView.topAnchor, right: rightAnchor, paddingLeft: 40, paddingBottom: 50, paddingRight: 40)
        
        updateView()
        refreshView.onTap { [weak self] in
            self?.delegate?.didRefresh()
        }
    }
    
    func updateView() {
        collectionView.isHidden = data.isEmpty
        emptyView.isHidden = !data.isEmpty
    }
    
    func removeItem(at indexPath: IndexPath) {
        data.remove(at: indexPath.item)
        collectionView.performBatchUpdates({
            self.collectionView.deleteItems(at: [indexPath])
        }, completion: nil)
        updateView()
    }
    
    func setupNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateFollow(_:)), name: .updateIsFollowFromFolowingFolower, object: nil)
    }
    
    @objc func updateFollow(_ notification: Notification) {
        guard let object = notification.userInfo as? [String: Any],
              let id = object["accountId"] as? String,
              let isFollow = object["isFollow"] as? Bool
        else { return }
        
        if isFollow, let index = data.index(by: id) {
            removeItem(at: IndexPath(item: index, section: 0))
        }
    }
}

// MARK: - CollectionView Data Source
extension FollowingView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCustomCell(with: FollowingSuggestCell.self, indexPath: indexPath)
        cell.configure(with: data[indexPath.item])
        cell.delegate = self
        return cell
    }
}

// MARK: - CollectionView Delegate
extension FollowingView: UICollectionViewDelegate {}

// MARK: - User Cell Delegate
extension FollowingView: FollowingSuggestCellDelegate {
    func didOpenProfile(for cell: FollowingSuggestCell) {
        guard let indexPath = cell.index(from: collectionView),
              let account = data[safe: indexPath.item]?.account
        else { return }
        
        delegate?.didOpenProfile(for: account)
    }
    
    func didClose(for cell: FollowingSuggestCell) {
        guard let indexPath = cell.index(from: collectionView) else { return }
        
        removeItem(at: indexPath)
    }
    
    func didFollow(for cell: FollowingSuggestCell) {
        guard let indexPath = cell.index(from: collectionView),
              let id = data[safe: indexPath.item]?.account?.id
        else { return }
        
        delegate?.didFollow(account: id)
        removeItem(at: indexPath)
    }
    
    func didOpenFeed(for cell: FollowingSuggestCell, with media: RemoteFeedItemMedias) {
        guard let indexPath = cell.index(from: collectionView),
              let item = data[safe: indexPath.item],
              let id = item.post(by: media)?.id
        else { return }
        
        delegate?.didOpenFeed(for: id)
    }
}

// MARK: - User Cell Helper
fileprivate extension FollowingSuggestCell {
    func index(from collection: UICollectionView) -> IndexPath? {
        return collection.indexPath(for: self)
    }
}

// MARK: - Array Helper
fileprivate extension Array where Element == RemoteFollowingSuggestItem {
    func index(by id: String) -> Int? {
        return firstIndex(where: { $0.account?.id == id })
    }
}

// MARK: Data Helper
fileprivate extension RemoteFollowingSuggestItem {
    func post(by medias: RemoteFeedItemMedias) -> RemoteFeedItemContent? {
        return feeds?.first(where: { $0.post?.medias?.contains(where: { $0 == medias }) ?? false })
    }
}
