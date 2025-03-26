//
//  UIRefreshControl+beginRefreshingManually.swift
//  FeedCleeps
//
//  Created by PT.Koanba on 22/09/22.
//

import UIKit

extension UIRefreshControl {
    func beginRefreshingManually() {
        if !isRefreshing {
            if let scrollView = superview as? UIScrollView {
                scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y - frame.height), animated: true)
            }
            beginRefreshing()
        }
        
    }
}
