//
//  Ext-UICollectionView.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 10/08/23.
//

import UIKit

extension UICollectionView {
    public func register<T: UICollectionViewCell>(_: T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    public func registerNib<T: UICollectionViewCell>(_: T.Type) {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        
        register(nib, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    public func registerNibs(_ cellTypes: [UICollectionViewCell.Type]) {
        for cellType in cellTypes {
            let bundle = Bundle(for: cellType.self)
            let nib = UINib(nibName: cellType.nibName, bundle: bundle)
            register(nib, forCellWithReuseIdentifier: cellType.defaultReuseIdentifier)
        }
    }
    
    public func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }
        
        return cell
    }
}

extension UICollectionViewCell: ReusableView { }

// MARK: - NibLoadableView

extension UICollectionViewCell: NibLoadableView { }

extension UICollectionView {
    
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
        titleLabel.font = .Roboto(.medium, size: 12)
        titleLabel.textColor = UIColor(hexString: "#777777")
        
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
}
