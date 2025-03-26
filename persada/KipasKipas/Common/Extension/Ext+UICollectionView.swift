//
//  Ext+UICollectionView.swift
//  KipasKipas
//
//  Created by DENAZMI on 19/08/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView {
    func setupPinterestLayout(columnCount: Int = 0, minColumnSpacing: CGFloat = 0.0, minInteritemSpacing: CGFloat = 0.0) {
        let layout = DENCollectionViewLayout()
        layout.minimumColumnSpacing = minColumnSpacing
        layout.minimumInteritemSpacing = minInteritemSpacing
        layout.columnCount = columnCount
        alwaysBounceVertical = true
        collectionViewLayout = layout
    }
}

extension UICollectionView {
    
    // MARK: - Public Methods
    
    func registerCell<T>(_ cellClass: T.Type) where T: AnyObject {
        let identifier = "\(cellClass)"
        register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        
        return cell
    }
}

extension UICollectionViewCell {
    
    // MARK: - Public Methods
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
}
