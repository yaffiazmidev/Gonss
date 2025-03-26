import UIKit

public extension UICollectionView {
    func registerCell<Cell: UICollectionViewCell>(_ cell: Cell.Type) {
        let identifier = String(describing: cell)
        register(cell, forCellWithReuseIdentifier: identifier)
    }
    
    func registerHeader<ReusableView: UICollectionReusableView>(_ reusableView: ReusableView.Type) {
        let identifier = String(describing: reusableView)
        register(reusableView, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: identifier)
    }
    
    func registerFooter<ReusableView: UICollectionReusableView>(_ reusableView: ReusableView.Type) {
        let identifier = String(describing: reusableView)
        register(reusableView, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: identifier)
    }
    
    func registerCustomCell<T: UICollectionViewCell>(_ cellType: T.Type) {
        register(cellType, forCellWithReuseIdentifier: T.identifier)
    }

    func dequeueReusableCustomCell<T: UICollectionViewCell>(with cellType: T.Type, indexPath: IndexPath) -> T {
            return dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as! T
    }
    
    func dequeueReusableCell<Cell: UICollectionViewCell>(at indexPath: IndexPath) -> Cell {
        let identifier = String(describing: Cell.self)
        return dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! Cell
    }
    
    func dequeueReusableHeader<Header: UICollectionReusableView>(at indexPath: IndexPath) -> Header {
        let identifier = String(describing: Header.self)
        return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: identifier, for: indexPath) as! Header
    }
    func dequeueReusableFooter<Footer: UICollectionReusableView>(at indexPath: IndexPath) -> Footer {
        let identifier = String(describing: Footer.self)
        return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: identifier, for: indexPath) as! Footer
    }
    
    var visibleHeaders: [UICollectionReusableView] {
        return visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader)
    }
}

public extension UICollectionView {
    
    private struct EmptyKey {
        static var key: String = "com.KipasKipas.UICollectionView.empty"
    }
    
    var emptyView: UIView? {
        get {
            withUnsafePointer(to: &EmptyKey.key) {
                return objc_getAssociatedObject(self, $0) as? UIView
            }
        }
        set {
            withUnsafePointer(to: &EmptyKey.key) {
                objc_setAssociatedObject(self, $0, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    func reloadEmpty() {
        reloadData()
        guard let emptyView, isCollectionEmpty else { return }
        backgroundView = emptyView
    }
    
    func forceReloadData() {
        backgroundView = nil
        reloadData()
    }
    
    private var isCollectionEmpty: Bool {
        let sectionCount = self.numberOfSections
        var itemsCount = 0
        for i in 0..<sectionCount {
            itemsCount += self.numberOfItems(inSection: i)
        }
        return itemsCount == 0
    }
}

fileprivate extension UICollectionReusableView {
    static var identifier: String {
        return className
    }
}

fileprivate extension NSObjectProtocol {
    static var className: String {
        return String(describing: self)
    }
}

public extension UICollectionView {
    func registerNibCell<T: UICollectionViewCell>(_: T.Type) {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        
        register(nib, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }
}

extension UICollectionViewCell: ReusableView { }
extension UICollectionViewCell: NibLoadableView { }
