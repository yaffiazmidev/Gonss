//
//  StoryListView.swift
//  KipasKipasStoryiOS
//
//  Created by Rahmat Trinanda Pramudya Amar on 07/06/24.
//

import UIKit
import KipasKipasStory
import KipasKipasShared

public protocol StoryListViewDelegate: AnyObject {
    func didSelectedMyStory(by item: StoryFeed)
    func didSelectedLive()
    func didSelectedOtherStory(by item: StoryFeed)
    func didAddStory()
    func didRetryUpload()
    func didReachLast()
}

fileprivate enum StorySection: Int {
    case myStory = 0
    case live = 1
    case anotherStory = 2
    
    static let count: Int = {
        var max: Int = 0
        while let _ = StorySection(rawValue: max) { max += 1 }
        return max
    }()
}

public class StoryListView: UIView {
    public weak var delegate: StoryListViewDelegate?
    
    public struct Style {
        public let active: UIColor
        public let hasView: UIColor
        public let live: UIColor
        public let background: UIColor
        public let text: UIColor
        
        public init(active: UIColor, hasView: UIColor, live: UIColor, background: UIColor, text: UIColor) {
            self.active = active
            self.hasView = hasView
            self.live = live
            self.background = background
            self.text = text
        }
        
        public static var `default`: Style = .init(active: .init(hexString: "1AE2C8"), hasView: .grey, live: .primary, background: .white, text: .black)
    }
    
    public var style: Style = .default {
        didSet {
            collectionView.reloadData()
        }
    }
    
    public var myPhoto: String? {
        didSet {
            guard myPhoto != oldValue else { return }
            myCell()?.updateProfilePicture(myPhoto)
        }
    }
    
    public var myStory: StoryFeed? {
        didSet {
//            guard myStory?.stories?.isSame(with: oldValue?.stories ?? []) == false else {
//                collectionView.reloadItems(at: [.init(item: 0, section: StorySection.myStory.rawValue)])
//                return
//            }
            collectionView.reloadData()
        }
    }
    
    public var stories: [StoryFeed] = [] {
        didSet {
           // guard !stories.isSame(with: oldValue) else { return }
            collectionView.reloadData()
        }
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
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

// MARK: - Upload Progress View
public extension StoryListView {
    func setUploadError() {
        guard let cell = myCell() else { return }
        cell.progressView.isHidden = true
        cell.updateAction(.retry)
        cell.updateStatusColor(.primary)
    }
    
    func setUploadProgress(to value: Double, animated: Bool = true) {
        guard let cell = myCell() else { return }
        cell.progressView.isHidden = false
        cell.progressView.setProgress(to: value, withAnimation: animated)
        cell.updateAction(.add)
    }
    
    func setUploadDone() {
        guard let cell = myCell() else { return }
        cell.progressView.isHidden = true
        cell.progressView.setProgress(to: 0, withAnimation: false)
        cell.updateAction(.add)
        cell.updateStatusColor(style.active)
    }
}

// MARK: - Private Helper
private extension StoryListView {
    private func configUI() {
        backgroundColor = .clear
        
        addSubviews([collectionView])
        
        collectionView.anchors.leading.equal(anchors.leading)
        collectionView.anchors.trailing.equal(anchors.trailing)
        collectionView.anchors.top.equal(anchors.top)
        collectionView.anchors.bottom.equal(anchors.bottom)
        configCollectionView()
    }
    
    private func configCollectionView() {
        collectionView.contentInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerCustomCell(StoryListViewCell.self)
    }
    
    private func myCell() -> StoryListViewCell? {
        guard let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: StorySection.myStory.rawValue)) as? StoryListViewCell else { return nil }
        
        return cell
    }
    
    private func statusColor(for item: StoryFeed?) -> UIColor {
        guard let item = item else { return .clear }
        
        if item.stories?.isEmpty ?? true {
            return .clear
        }
        if item.stories?.last?.isHasView ?? false {
            return style.hasView
        }
        
        return style.active
    }
}

extension StoryListView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch StorySection(rawValue: indexPath.section) {
        case .myStory:
            let cell = collectionView.dequeueReusableCustomCell(with: StoryListViewCell.self, indexPath: indexPath)
            cell.configure(name: myStory?.stories?.isEmpty ?? true ? "Buat" : "My Story", photo: myPhoto, color: style.background, labelColor: style.text, borderColor: statusColor(for: myStory), action: .add)
            cell.delegate = self
            return cell
        case .live:
            let cell = collectionView.dequeueReusableCustomCell(with: StoryListViewCell.self, indexPath: indexPath)
            cell.configure(name: "Hardcoded Live", photo: "", color: style.background, labelColor: style.text, borderColor: style.live, action: .live)
            cell.delegate = self
            return cell
        case .anotherStory:
            let cell = collectionView.dequeueReusableCustomCell(with: StoryListViewCell.self, indexPath: indexPath)
            guard let item = stories[safe: indexPath.item] else { return UICollectionViewCell() }
            cell.configure(name: item.account?.name ?? "", photo: item.account?.photo, color: style.background, labelColor: style.text, borderColor: statusColor(for: item))
            cell.delegate = self
            return cell
        default: return UICollectionViewCell()
        }
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        StorySection.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch StorySection(rawValue: section) {
        case .myStory: 1
        case .live: 0
        case .anotherStory: stories.count
        default: 0
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard !stories.isEmpty, 
        indexPath.section == StorySection.anotherStory.rawValue else { return }
        
        if stories.count < 2 {
            delegate?.didReachLast()
            return
        }
        
        guard indexPath.item == (stories.count - 2) else { return }
        delegate?.didReachLast()
    }
}

extension StoryListView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 0, bottom: 0, right: 8)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = collectionView.frame.size
        size.width = 74
        return size
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = StorySection(rawValue: indexPath.section) else { return }
        
        switch section {
        case .myStory:
            if let feed = myStory {
                delegate?.didSelectedMyStory(by: feed)
                return
            }
            
            delegate?.didAddStory()
        case .live: delegate?.didSelectedLive()
        case .anotherStory:
            guard let item = stories[safe: indexPath.item] else { return }
            delegate?.didSelectedOtherStory(by: item)
        }
    }
}

// MARK: - Cell Delegate
extension StoryListView: StoryListViewCellDelegate {
    func didSelect(_ cell: StoryListViewCell) {
//        guard let indexPath = collectionView.indexPath(for: cell), let section = StorySection(rawValue: indexPath.section) else { return }
//        
//        switch section {
//        case .myStory:
//            if let feed = myStory {
//                delegate?.didSelectedMyStory(by: feed)
//                return
//            }
//            
//            delegate?.didAddStory()
//        case .live: delegate?.didSelectedLive()
//        case .anotherStory:
//            guard let item = stories[safe: indexPath.item] else { return }
//            delegate?.didSelectedOtherStory(by: item)
//        }
    }
    
    func didAddStory() {
        delegate?.didAddStory()
    }
    
    func didRetryUpload() {
        delegate?.didRetryUpload()
    }
    
    func didLive() {
        delegate?.didSelectedLive()
    }
}

fileprivate extension Array where Element == StoryFeed {
    func isSame(with array: Array<StoryFeed>) -> Bool {
        let old = map({$0.id})
        let new = array.map({$0.id})
        
       return old == new
    }
}

fileprivate extension Array where Element == StoryItem {
    func isSame(with array: Array<StoryItem>) -> Bool {
        let old = map({$0.id})
        let new = array.map({$0.id})
        
        return old == new
    }
}
