//
//  FeedbarView.swift
//  FeedCleeps
//
//  Created by Rahmat Trinanda Pramudya Amar on 26/07/22.
//

import UIKit

class FeedbarView: UIView{
    var progressView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.backgroundColor = .gray
        progressView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 2))
        progressView.backgroundColor = .white
        self.layer.cornerRadius = 2
        self.layer.masksToBounds = true
        self.addSubview(progressView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
