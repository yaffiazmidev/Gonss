//
//  KKLoadingIdicatorV1.swift
//  FeedCleeps
//
//  Created by DENAZMI on 27/04/23.
//

import UIKit

class KKLoadingIdicatorV1: UIView {
    private lazy var loadingLine: UIView = {
        let lineView = UIView()
        return lineView
    }()
    
    private let screenSize = UIScreen.main.bounds
    var isAnimating: Bool = false
    var lineColor: UIColor = .red
    var trackColor: UIColor = .gray
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupView() {
        backgroundColor = trackColor
        addSubview(loadingLine)
        loadingLine.frame =  CGRect(x: screenSize.width / 2, y: 0, width: 0, height: frame.height)
    }
    
    func startAnimating() {
        guard !isAnimating else {
            return
        }
        
        setupView()
        loadingLine.backgroundColor = lineColor
        loadingLine.isHidden = false
        isHidden = false
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.6, delay: 0, options: [.repeat, .autoreverse], animations: {
                self.isAnimating = true
                self.loadingLine.frame.size.width = self.screenSize.width
                self.loadingLine.transform = CGAffineTransform(translationX: -(self.screenSize.width / 2), y: 0)
            }, completion: nil)
        }
    }
    
    func stopAnimating() {
        guard isAnimating else {
            return
        }
        
        isAnimating = false
        loadingLine.transform = .identity
        loadingLine.isHidden = true
        isHidden = true
        loadingLine.layer.removeAllAnimations()
        loadingLine.removeFromSuperview()
    }
}
