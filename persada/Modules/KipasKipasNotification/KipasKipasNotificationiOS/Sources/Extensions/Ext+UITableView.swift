//
//  Ext+UITableView.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 19/03/24.
//

import UIKit

extension UITableView {
    func customReloadSections(_ sections: IndexSet, with animation: UITableView.RowAnimation = .none) {
        var valid = true
        for section in sections {
            if numberOfRows(inSection: section) < 1 {
                valid = false
                break
            }
        }
        
        if valid {
            reloadSections(sections, with: animation)
        } else {
            reloadData()
        }
    }
    
    func customReloadSection(_ section: Int, with animation: UITableView.RowAnimation = .none) {
        var valid = true
        if numberOfRows(inSection: section) < 1 {
            valid = false
        }
        
        if valid {
            reloadSections([section], with: animation)
        } else {
            reloadData()
        }
    }
}


extension UITableView {
    public func register<T: UITableViewCell>(_: T.Type) {
        register(T.self, forCellReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    public func registerNib<T: UITableViewCell>(_: T.Type) {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        
        register(nib, forCellReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    public func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }
        
        return cell
    }
    
    func registerCustomCell<T: UITableViewCell>(_ viewType: T.Type) {
        register(viewType, forCellReuseIdentifier: viewType.defaultReuseIdentifier)
    }
    
    func dequeueReusableCustomCell<T: UITableViewCell>(with cellType: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            fatalError("Error dequeuing cell for identifier \(T.defaultReuseIdentifier)")
        }
        return cell
    }
}

// MARK: - ReusableView

public protocol ReusableView: AnyObject {
    static var defaultReuseIdentifier: String { get }
}

extension ReusableView where Self: UIView {
    public static var defaultReuseIdentifier: String {
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

extension UITableView {
    
    func deleteEmptyView() {
        backgroundView = nil
    }
    
    func setEmptyView(_ title: String) {
        let emptyView = UIView(frame: frame)
        emptyView.backgroundColor = .white
        
        let titleLabel = UILabel(frame: CGRect(x: 32, y: (emptyView.frame.height / 2) - 110, width: emptyView.frame.width - 64, height: 100))
        titleLabel.text = title
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = UIColor(hexString: "")
        
        emptyView.addSubview(titleLabel)
        backgroundView = emptyView
        
    }
    
    func setLoadingActivity() {
        let containerView = UIView(frame: frame)
        containerView.backgroundColor = .white
        
        let loadingActivity = UIActivityIndicatorView(frame: CGRect(x: (containerView.frame.width / 2) - 16, y: (containerView.frame.height / 2) - 110, width: 32, height: 32))
        loadingActivity.tintColor = .lightGray
        loadingActivity.startAnimating()
        
        containerView.addSubview(loadingActivity)
        backgroundView = containerView
    }
    
    func setLoadingActivityOnTop() {
        let containerView = UIView(frame: frame)
        containerView.backgroundColor = .white
        containerView.accessibilityIdentifier = "loadingActivityOnTopTableView"
        let loadingActivity = UIActivityIndicatorView(frame: CGRect(x: (containerView.frame.width / 2) - 16, y: (containerView.frame.height / 2) - 110, width: 32, height: 32))
        loadingActivity.tintColor = .lightGray
        loadingActivity.startAnimating()
        
        containerView.addSubview(loadingActivity)
        addSubview(containerView)
    }
    
    func removeLoadingActivityOnTop() {
        removeSubview(withIdentifier: "loadingActivityOnTopTableView")
    }
    
    func emptyView(isEmpty: Bool, title: String = "", icon: UIImage? = nil) {
        guard isEmpty else {
            removeSubview(withIdentifier: "emptyViewOnTopTableView")
            backgroundView = nil
            return
        }
        
        guard backgroundView == nil else { return }
        
        let emptyView = UIView(frame: frame)
        emptyView.backgroundColor = .white
        emptyView.accessibilityIdentifier = "emptyViewOnTopTableView"
        
        let titleLabel = UILabel(frame: CGRect(x: 32, y: (emptyView.frame.height / 2) - 110, width: emptyView.frame.width - 64, height: 100))
        titleLabel.text = title
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        titleLabel.textColor = UIColor(hexString: "#777777")
        
        emptyView.addSubview(titleLabel)
        
        if let icon = icon {
            let iconImageView = UIImageView()
            iconImageView.contentMode = .scaleAspectFit
            iconImageView.image = icon.withTintColor(UIColor(hexString: "#DDDDDD"), renderingMode: .alwaysOriginal)
            iconImageView.frame = .init(x: (emptyView.frame.width / 2) - 20, y: (emptyView.frame.height / 2) - 118, width: 40, height: 32)
            emptyView.addSubview(iconImageView)
        }
        
        
        backgroundView = emptyView
    }
}
