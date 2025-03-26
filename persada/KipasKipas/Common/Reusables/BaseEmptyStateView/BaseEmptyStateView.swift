//
//  BaseEmptyStateView.swift
//  KipasKipas
//
//  Created by DENAZMI on 18/03/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import UIKit

class BaseEmptyStateView: NibView {
    
    @IBOutlet weak var emptyImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
}


extension UICollectionView {
    func emptyView(isEmpty: Bool, title: String = "") {
        let emptyView = BaseEmptyStateView(frame: frame)
        emptyView.titleLabel.text = title
        backgroundView = isEmpty ? emptyView : nil
    }
    
    func isEmptyView(_ isEmpty: Bool, title: String = "", image: UIImage? = nil) {
        let emptyView = BaseEmptyStateView(frame: frame)
        emptyView.titleLabel.text = title
        emptyView.emptyImageView.isHidden = image == nil
        emptyView.emptyImageView.image = image
        backgroundView = isEmpty ? emptyView : nil
    }
}

extension UITableView {
    
    func isEmptyView(_ isEmpty: Bool, title: String = "", image: UIImage? = nil) {
        let emptyView = BaseEmptyStateView(frame: frame)
        emptyView.titleLabel.text = title
        emptyView.emptyImageView.isHidden = image == nil
        emptyView.emptyImageView.image = image
        backgroundView = isEmpty ? emptyView : nil
    }
    
    func showEmptyView(_ title: String = "", image: UIImage? = nil) {
        let emptyView = BaseEmptyStateView(frame: frame)
        emptyView.titleLabel.text = title
        emptyView.emptyImageView.isHidden = image == nil
        emptyView.emptyImageView.image = image
        backgroundView = emptyView
    }
    
    func hideEmptyView() {
        backgroundView = nil
    }
}

extension UITableView {
    func emptyView(isEmpty: Bool, title: String = "") {
        let emptyView = BaseEmptyStateView(frame: frame)
        emptyView.titleLabel.text = title
        backgroundView = isEmpty ? emptyView : nil
    }
}
