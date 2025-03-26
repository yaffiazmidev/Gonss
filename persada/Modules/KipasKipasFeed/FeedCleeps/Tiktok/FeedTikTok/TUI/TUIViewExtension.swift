//
//  TUIViewExtension.swift
//  FeedCleeps
//
//  Created by Rahmat Trinanda Pramudya Amar on 24/09/23.
//

import Foundation
import UIKit
import TUIPlayerShortVideo

extension TUIShortVideoView {
    func containerView() -> UIImageView? {
        if let view = self.subviews.first as? UIImageView {
            return view
        }
        return nil
    }
    
    public func tableView() -> UITableView? {
        if let view = self.containerView()?.subviews.first as? UITableView {
            return view
        }
        return nil
    }
    
    func tuiCellForItem(at index: Int) -> TUIShortVideoItemView? {
        if let cell = self.tableView()?.cellForRow(at: IndexPath(row: index, section: 0)) as? TUIShortVideoItemView {
            return cell
        }
        return nil
    }
}
