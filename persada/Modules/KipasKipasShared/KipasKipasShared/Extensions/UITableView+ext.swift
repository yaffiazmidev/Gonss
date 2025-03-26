import UIKit

public extension UITableView {
    func registerCell<Cell: UITableViewCell>(_ cell: Cell.Type) {
        let identifier = String(describing: cell)
        register(cell, forCellReuseIdentifier: identifier)
    }
    
    func registerHeader<ReusableView: UITableViewHeaderFooterView>(_ reusableView: ReusableView.Type) {
        let identifier = String(describing: reusableView)
       register(reusableView, forHeaderFooterViewReuseIdentifier: identifier)
    }
    
    func dequeueReusableCell<Cell: UITableViewCell>(at indexPath: IndexPath) -> Cell {
        let identifier = String(describing: Cell.self)
        return dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! Cell
    }
    
    func dequeueReusableCell<Cell: UITableViewCell>() -> Cell {
        let identifier = String(describing: Cell.self)
        return dequeueReusableCell(withIdentifier: identifier) as! Cell
    }
    
    func dequeueReusableHeader<Header: UITableViewHeaderFooterView>() -> Header {
        let identifier = String(describing: Header.self)
        return dequeueReusableHeaderFooterView(withIdentifier: identifier) as! Header
    }
}

public extension UITableView {
    func registerNibCell<T: UITableViewCell>(_: T.Type) {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        
        register(nib, forCellReuseIdentifier: T.defaultReuseIdentifier)
    }
}

// MARK: - ReusableView

protocol ReusableView: AnyObject {
    static var defaultReuseIdentifier: String { get }
}

extension ReusableView where Self: UIView {
    static var defaultReuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: ReusableView { }

// MARK: - NibLoadableView

protocol NibLoadableView: AnyObject {
    static var nibName: String { get }
}

extension NibLoadableView where Self: UIView {
    static var nibName: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
}

extension UITableViewCell: NibLoadableView { }
