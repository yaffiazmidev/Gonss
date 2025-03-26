//
//  NewsPortalMenuView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 09/01/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import UIKit
import KipasKipasShared

protocol NewsPortalMenuViewDelegate {
    func didOpen(_ item: NewsPortalItem)
    func didQuickAccessAdd(_ item: NewsPortalItem, at index: Int?)
    func didQuickAccessRemove(_ item: NewsPortalItem)
    func didQuickAccessSave()
}

class NewsPortalMenuView: UIView {
    
    var delegate: NewsPortalMenuViewDelegate?
    private let numberOfItemsInRow: Int = 5
    
    var showTitle: Bool = true {
        didSet {
            titleTopSpacing.isHidden = !showTitle
            titleView.isHidden = !showTitle
            mainView.layer.maskedCorners = showTitle ? [.layerMaxXMinYCorner, .layerMinXMinYCorner] : []
        }
    }
    
//    var maxQuickAccess: Int = 7 {
//        didSet {
//            contentView.reloadData()
//        }
//    }
    
    var showEditAction: Bool = false {
        didSet {
            contentView.reloadData()
        }
    }
    
    var data: [NewsPortalData] = [] {
        didSet {
            contentView.reloadData()
        }
    }
    
    private var draggedIndexPath: IndexPath?
    
    // MARK: Title
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .Roboto(.medium, size: 12)
        label.textColor = .black
        label.text = "Portal Berita"
        return label
    }()
    
    lazy var closeView: UIView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.image = UIImage(named: .get(.iconClose))
        image.clipsToBounds = true
        image.isUserInteractionEnabled = true
        image.translatesAutoresizingMaskIntoConstraints = false
        
        let view = UIView()
        view.addSubview(image)
        view.translatesAutoresizingMaskIntoConstraints = false
        image.anchor(bottom: view.bottomAnchor, right: view.rightAnchor, width: 14, height: 14)
        
        return view
    }()
    
    private lazy var titleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubviews([titleLabel, closeView])
        
        titleLabel.anchor(bottom: view.bottomAnchor)
        titleLabel.centerXTo(view.centerXAnchor)
        
        closeView.anchor(top: view.topAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingRight: 10, width: 24, height: 14)
        
        return view
    }()
    
    // MARK: Header
    private lazy var dropdownLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .Roboto(.medium, size: 12)
        label.textColor = .black
        label.text = "Indonesia"
        return label
    }()
    
    private lazy var drowpdownIconView: UIView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "ic_caret_down_solid_black")
        image.contentMode = .scaleAspectFit
        
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(image)
        image.anchor(width: 16, height: 16)
        image.centerInSuperview()
        
        return view
    } ()
    
    lazy var dropdownView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [dropdownLabel, drowpdownIconView])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.distribution = .fill
        view.alignment = .center
        view.spacing = 3
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = .init(top: 6, left: 12, bottom: 6, right: 8)
        view.clipsToBounds = true
        view.layer.borderColor = UIColor.gainsboro.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 8
        drowpdownIconView.anchor(width: 24, height: 24)
        
        return view
    }()
    
    private lazy var searchField: KKBaseTextField = {
        let field = KKBaseTextField()
        field.textColor = .black
        field.font = .roboto(.medium, size: 12)
        field.placeholderText = "Cari Portal Berita"
        field.placeholderColor = .gainsboro
        field.placeholderLabel.font = .roboto(.medium, size: 12)
        
        return field
    }()
    
    lazy var searchIconView: UIView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "search")
        image.contentMode = .scaleAspectFit
        
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(image)
        image.anchor(width: 16, height: 16)
        image.centerInSuperview()
        
        return view
    } ()
    
    private lazy var searchView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [searchField, searchIconView])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.distribution = .fill
        view.alignment = .center
        view.spacing = 3
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = .init(top: 6, left: 12, bottom: 6, right: 8)
        view.clipsToBounds = true
        view.layer.borderColor = UIColor.gainsboro.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 8
        searchIconView.anchor(width: 24, height: 24)
        
        return view
    }()
    
    
    // MARK: Main
    private lazy var headerView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [dropdownView, searchView])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.alignment = .center
        view.spacing = 10
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = .init(all: 12)
        
        return view
    }()
    
    private lazy var contentView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: .init())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        
        view.registerCustomCell(NewsPortalMenuItemCell.self)
        view.registerReusableView(NewsPortalMenuHeaderCell.self, kind: UICollectionView.elementKindSectionHeader)
        view.registerReusableView(NewsPortalMenuFooterCell.self, kind: UICollectionView.elementKindSectionFooter)
        
        view.delegate = self
        view.dataSource = self
        
        view.reorderingCadence = .immediate
        view.dragInteractionEnabled = false
        view.dropDelegate = self
        view.dragDelegate = self
        
        return view
    }()
    
    private lazy var titleTopSpacing: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.anchor(height: 12)
        return view
    }()
    
    private lazy var mainView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleTopSpacing, titleView, headerView, contentView])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.axis = .vertical
        view.spacing = 0
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.clipsToBounds = true
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        contentView.collectionViewLayout = createContentLayout()
        
        addSubview(mainView)
        mainView.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NewsPortalMenuView {
    private func createContentLayout() -> UICollectionViewCompositionalLayout {
        let itemFractionalWidth = 1 / CGFloat(numberOfItemsInRow)
        
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environtent) -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(itemFractionalWidth), heightDimension: .estimated(64))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(64))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(32)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            
            let footer = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(1)
                ),
                elementKind: UICollectionView.elementKindSectionFooter,
                alignment: .bottom
            )
            
            section.contentInsets = .init(top: 16, bottom: 16)
            section.boundarySupplementaryItems = [header, footer]
            
            if sectionIndex == 0 {
                let sectionBackground = NSCollectionLayoutDecorationItem.background(elementKind: "background")
                section.decorationItems = [sectionBackground]
            }
            
            return section
        }
        
        layout.register(NewsPortalMenuBackgroundView.self, forDecorationViewOfKind: "background")
        
        return layout
    }
}

extension NewsPortalMenuView: UICollectionViewDelegate {}

extension NewsPortalMenuView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data[section].content.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCustomCell(with: NewsPortalMenuItemCell.self, indexPath: indexPath)
        
        var action: NewsPortalMenuItemCellAction = .none
        if showEditAction {
            action = indexPath.section == 0 ? .remove : .add
        }
        
        var item: NewsPortalItem?
        if indexPath.section != 0 {
            item = data[indexPath.section].content[indexPath.item]
        } else {
            if indexPath.item < data[indexPath.section].content.count {
                item = data[indexPath.section].content[indexPath.item]
            }
        }
        
        cell.configure(with: item, action: action, useTopSpacing: indexPath.item >= numberOfItemsInRow)
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionFooter {
            return collectionView.dequeueReusableView(NewsPortalMenuFooterCell.self, kind: UICollectionView.elementKindSectionFooter, for: indexPath)
        }
        
        let cell = collectionView.dequeueReusableView(NewsPortalMenuHeaderCell.self, kind: UICollectionView.elementKindSectionHeader, for: indexPath)
        
        var action: NewsPortalMenuHeaderCellAction = .none
        if indexPath.section == 0 {
            action = showEditAction ? .save : .setup
        }
        
        cell.configure(title: data[indexPath.section].category, action: action)
        cell.delegate = self
        
        return cell
    }
}

extension NewsPortalMenuView: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        // Guarding placeholder
        if indexPath.section == 0, indexPath.item >= data[0].content.count {
            return []
        }
        
        draggedIndexPath = indexPath
        let itemProvider = NSItemProvider(object: "\(indexPath)" as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = data[indexPath.section].content[indexPath.item]
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession) {
        draggedIndexPath = nil
    }
}

extension NewsPortalMenuView: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let section = collectionView.numberOfSections - 1
            let item = collectionView.numberOfItems(inSection: section)
            destinationIndexPath = IndexPath(item: item, section: section)
        }
        
        guard let sourceIndexPath = draggedIndexPath else { return }
        let item = data[sourceIndexPath.section].content[sourceIndexPath.item]
        
        switch coordinator.proposal.operation {
        case .copy:
            if sourceIndexPath.section != 0, destinationIndexPath.section == 0 {
                var safeIndex = destinationIndexPath.item
                if safeIndex > data[0].content.count {
                    safeIndex = data[0].content.count
                }
                delegate?.didQuickAccessAdd(item, at: safeIndex)
            }
        case .move:
            if sourceIndexPath.section == 0 {
                if destinationIndexPath.section != 0 {
                    delegate?.didQuickAccessRemove(item)
                    return
                }
                
                delegate?.didQuickAccessRemove(item)
                delegate?.didQuickAccessAdd(item, at: destinationIndexPath.item)
                
                collectionView.performBatchUpdates ({
                    collectionView.deleteItems(at: [sourceIndexPath])
                    collectionView.insertItems(at: [destinationIndexPath])
                })
                
                return
            }
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        guard collectionView.hasActiveDrag,
              let destinationIndexPath = destinationIndexPath,
              let sourceIndexPath = draggedIndexPath
        else {
            return UICollectionViewDropProposal(operation: .forbidden)
        }
        
        // from section 0 to section 0
        if sourceIndexPath.section == 0, destinationIndexPath.section == 0  {
            if destinationIndexPath.item >= data[0].content.count {
                return UICollectionViewDropProposal(operation: .forbidden)
            }
            
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        
        // from section != 0 to section 0
        if destinationIndexPath.section == 0 {
            // check limit
//            if data[0].data.count >= maxQuickAccess {
//                return UICollectionViewDropProposal(operation: .forbidden)
//            }
            
            return UICollectionViewDropProposal(operation: .copy, intent: .insertIntoDestinationIndexPath)
        }
        
        return UICollectionViewDropProposal(operation: .move)
    }
}

extension NewsPortalMenuView: NewsPortalMenuHeaderCellDelegate {
    func didSetup() {
        showEditAction = true
//        contentView.dragInteractionEnabled = true
    }
    
    func didSave() {
        showEditAction = false
//        contentView.dragInteractionEnabled = false
        delegate?.didQuickAccessSave()
    }
}

extension NewsPortalMenuView: NewsPortalMenuItemCellDelegate {
    func didRemove(_ item: NewsPortalItem) {
        delegate?.didQuickAccessRemove(item)
    }
    
    func didAdd(_ item: NewsPortalItem) {
        delegate?.didQuickAccessAdd(item, at: nil)
    }
    
    func didSelect(_ item: NewsPortalItem) {
        delegate?.didOpen(item)
    }
}

extension NSDirectionalEdgeInsets {
    init(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) {
        self.init(top: top, leading: left, bottom: bottom, trailing: right)
    }
}
