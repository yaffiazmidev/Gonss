//
//  FeedbarModel.swift
//  FeedCleeps
//
//  Created by Rahmat Trinanda Pramudya Amar on 26/07/22.
//

import Foundation

class FeedbarModel {
    var view: FeedbarView!
    var duration: TimeInterval!
    
    init(view: FeedbarView, duration: TimeInterval) {
        self.view = view
        self.duration = duration
    }
}
