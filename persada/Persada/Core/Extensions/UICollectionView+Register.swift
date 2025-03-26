//
//  UICollectionView+Register.swift
//  Persada
//
//  Created by Muhammad Noor on 07/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

extension UICollectionView {

	// MARK: - Public Methods
	func registerCustomCell<T: UICollectionViewCell>(_ cellType: T.Type) {
		register(cellType, forCellWithReuseIdentifier: T.identifier)
	}

	func registerCustomReusableHeaderView<T: UICollectionReusableView>(_ viewType: T.Type) {
		register(viewType, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.identifier)
	}

	func registerCustomReusableFooterView<T: UICollectionReusableView>(_ viewType: T.Type) {
		register(viewType, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: T.identifier)
	}

	func dequeueReusableCustomCell<T: UICollectionViewCell>(with cellType: T.Type, indexPath: IndexPath) -> T {
			return dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as! T
	}

	func dequeueReusableCustomHeaderView<T: UICollectionReusableView>(with cellType: T.Type, indexPath: IndexPath) -> T {
			return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.identifier, for: indexPath) as! T
	}

	func dequeueReusableCustomFooterView<T: UICollectionReusableView>(with cellType: T.Type, indexPath: IndexPath) -> T {
			return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: T.identifier, for: indexPath) as! T
	}
    
    func registerXibCell<T>(_ cellClass: T.Type) where T: AnyObject {
        let identifier = "\(cellClass)"
        register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
    }
    
    func registerXibCell<T>(_ cellClass: T.Type, kind: String) where T: AnyObject {
        let identifier = "\(cellClass)"
        register(UINib(nibName: identifier, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: identifier)
    }
    
    func dequeueReusableCell<T>(_ cellClass: T.Type, for indexPath: IndexPath) -> T where T: AnyObject {
        let identifier = "\(cellClass)"
        if let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? T {
            return cell
        }

        fatalError("Error dequeueing cell")
    }
    
    func dequeueReusableSupplementaryCell<T>(_ cellClass: T.Type, for indexPath: IndexPath, kind: String) -> T where T: AnyObject {
        let identifier = "\(cellClass)"
        if let cell = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath) as? T {
            return cell
        }
        
        fatalError("Error dequeueing cell")
    }
    
    func registerReusableView<T>(_ cellClass: T.Type, kind: String) where T: AnyObject {
        let identifier = "\(cellClass)"
        register(cellClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
    }
    
    func registerReusableViewXib<T>(_ cellClass: T.Type, kind: String) where T: AnyObject {
        let identifier = "\(cellClass)"
        register(UINib(nibName: identifier, bundle: nil), forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
    }
    
    func dequeueReusableView<T>(_ cellClass: T.Type, kind: String, for indexPath: IndexPath) -> T where T: AnyObject {
        let identifier = "\(cellClass)"
        if let cell = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath) as? T {
            return cell
        }
        fatalError("Error dequeueing cell")
    }
}

extension UICollectionReusableView {

		static var identifier: String {
				return className
		}
}

extension NSObjectProtocol {

		static var className: String {
				return String(describing: self)
		}
}

extension UICollectionView {
    func scrollToBottom(animated: Bool = true) {
        let bottomOffset = CGPoint(x: 0,
                                   y: contentSize.height - bounds.size.height + contentInset.bottom)
        setContentOffset(bottomOffset, animated: animated)
    }
}
