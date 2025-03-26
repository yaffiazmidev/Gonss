//
//  TransactionView.swift
//  KipasKipasNotificationiOS
//
//  Created by Rahmat Trinanda Pramudya Amar on 27/03/24.
//

import UIKit
import KipasKipasShared
import KipasKipasNotification

protocol TransactionViewDelegate: AnyObject {
    func didSelected(item: NotificationTransactionItem)
    func didRefresh()
    func didLoadMore()
}

class TransactionView: UIView {
    
    weak var delegate: TransactionViewDelegate?
    private(set) var data: [NotificationTransactionItem] = []
    
    private lazy var refreshControl: UIRefreshControl = {
        let view = UIRefreshControl()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .primary
        view.layer.zPosition = -1
        
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: .init())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.alwaysBounceVertical = true
        view.refreshControl = refreshControl
        
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        
        view.registerCustomCell(TransactionCollectionViewCell.self)
        view.delegate = self
        view.dataSource = self
        
        return view
    }()
    
    private lazy var emptyView: TransactionEmptyView = {
        let view = TransactionEmptyView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var noInternetView: NoInternetConnectionView = {
        let view = NoInternetConnectionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        
        return view
    }()
    
    // MARK: Function
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configUI()
    }
}

// MARK: - Internal Helper
extension TransactionView {
    func setData(data items: [NotificationTransactionItem]) {
        data = items
        collectionView.reloadData()
        emptyView.isHidden = !data.isEmpty
    }
    
    func appendData(data items: [NotificationTransactionItem]) {
        guard !items.isEmpty else { return }
        
        let originalCount = data.count
        data.append(contentsOf: items)
        var indexPaths: [IndexPath] = []
        for i in 0..<items.count {
            indexPaths.append(IndexPath(item: originalCount + i, section: 0))
        }
        collectionView.performBatchUpdates({
            self.collectionView.insertItems(at: indexPaths)
        }, completion: nil)
        emptyView.isHidden = !data.isEmpty
    }
    
    func startLoading() {
        refreshControl.beginRefreshing()
    }
    
    func stopLoading() {
        refreshControl.endRefreshing()
    }
    
    func setNoInternetViewVisibility(_ visible: Bool) {
        noInternetView.isHidden = !visible
    }
}

// MARK: - Private Helper
private extension TransactionView {
    func configUI() {
        backgroundColor = .white
        
        addSubviews([collectionView, emptyView, noInternetView])
        
        collectionView.anchors.leading.equal(anchors.leading)
        collectionView.anchors.trailing.equal(anchors.trailing)
        collectionView.anchors.top.equal(anchors.top, constant: 8)
        collectionView.anchors.bottom.equal(safeAreaLayoutGuide.anchors.bottom, constant: -8)
        collectionView.collectionViewLayout = createLayout()
        
        emptyView.anchors.leading.equal(anchors.leading, constant: 32)
        emptyView.anchors.trailing.equal(anchors.trailing, constant: -32)
        emptyView.anchors.centerY.equal(anchors.centerY, constant: -100)
        
        noInternetView.anchors.edges.pin(insets: 0)
        
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        noInternetView.handleTapRetryButton = { [weak self] in
            self?.delegate?.didRefresh()
        }
    }
    
    @objc private func didPullToRefresh(_ sender: Any) {
        delegate?.didRefresh()
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environtent) -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(69))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(64))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            
            return section
        }
        
        return layout
    }
}

extension TransactionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelected(item: data[indexPath.item])
    }
}

extension TransactionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCustomCell(with: TransactionCollectionViewCell.self, indexPath: indexPath)
        
        cell.configure(with: data[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard !data.isEmpty, indexPath.item == (data.count - 2) else { return }
        delegate?.didLoadMore()
    }
}
