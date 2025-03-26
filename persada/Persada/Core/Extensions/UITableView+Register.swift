//
//  UITableView+Register.swift
//  Persada
//
//  Created by Muhammad Noor on 07/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

extension UITableView {
	
	// MARK: - Public Methods
	
	func registerCustomCell<T: UITableViewCell>(_ viewType: T.Type) {
		register(viewType, forCellReuseIdentifier: viewType.reuseIdentifier)
	}
	
	func registerCustomReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_ viewType: T.Type) {
		register(viewType, forHeaderFooterViewReuseIdentifier: viewType.identifier)
	}
	
	func dequeueReusableCustomCell<T: UITableViewCell>(with cellType: T.Type, indexPath: IndexPath) -> T {
		return dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T
	}
	
	func dequeueReusableCustomHeaderFooterView<T: UITableViewHeaderFooterView>(with cellType: T.Type) -> T {
		return dequeueReusableHeaderFooterView(withIdentifier: cellType.identifier) as! T
	}
    
    func registerCell<T>(_ cellClass: T.Type) where T: AnyObject {
        let identifier = "\(cellClass)"
        register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
    }
    
    func registerNibCell<T>(_ cellClass: T.Type) where T: AnyObject {
        let identifier = "\(cellClass)"
        register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
    }

    func dequeueReusableCell<T>(_ cellClass: T.Type, for indexPath: IndexPath) -> T where T: AnyObject {
        let identifier = "\(cellClass)"
        if let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T {
            return cell
        }

        fatalError("Error dequeueing cell")
    }
    
    func registerXIBCells<T>(with cells: [T.Type]) where T: AnyObject {
        cells.forEach { registerCell($0) }
    }
    
    func setup(delegate: UITableViewDelegate? = nil, dataSource: UITableViewDataSource? = nil, rowHeight: CGFloat = UITableView.automaticDimension) {
        self.delegate = delegate
        self.dataSource = dataSource
        self.rowHeight = rowHeight
    }
}

extension UITableView {
    func scrollToBottom(animated: Bool = true) {
        let bottomOffset = CGPoint(x: 0,
                                   y: contentSize.height - bounds.size.height + contentInset.bottom)
        setContentOffset(bottomOffset, animated: animated)
    }
}

extension UITableViewCell {
	
	// MARK: - Public Methods
	
	static var reuseIdentifier: String {
		return String(describing: self)
	}
	
	static var nib: UINib {
		return UINib(nibName: reuseIdentifier, bundle: nil)
	}
}

extension UITableViewHeaderFooterView {
	
	static var identifier: String {
		return className
	}
}
