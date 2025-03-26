//
//  HotNewsLoadingView.swift
//  FeedCleeps
//
//  Created by Rahmat Trinanda Pramudya Amar on 21/03/24.
//

import UIKit
import KipasKipasShared
import NVActivityIndicatorView
import TUIPlayerShortVideo
import Lottie

class HotNewsLoadingView: UIView {
    var isBlackTitle = false
    
    lazy var loadingView: LottieAnimationView? = {
        backgroundColor =  isBlackTitle ? .white : .black
        let name = isBlackTitle ? "loading-black" : "loading-white"
        let animation = LottieAnimation.named(name)  //white title
        let animationV = LottieAnimationView(animation: animation)
        animationV.frame =  CGRectMake(0, 0, 125, 125)
        animationV.loopMode = .loop
        animationV.play()
        return animationV
    }()
    
//    lazy var loadingView: NVActivityIndicatorView? = {
//        let view = NVActivityIndicatorView(frame: .zero)
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.type = .lineScale
//        view.color = .white
//        return view
//    }()
    
    // MARK: Function
    
    init(isBlackTitle:Bool = false) { 
        self.isBlackTitle = isBlackTitle
        super.init(frame: .zero)
        configUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configUI()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil { //view attached
            startLoading()
        } else { // view dettached
            stopLoading()
        }
    }
}

extension HotNewsLoadingView {
    func configUI() {
//        backgroundColor = .black
        
        addSubviews([loadingView!])
         
        loadingView?.anchors.centerX.equal(anchors.centerX)
        loadingView?.anchors.centerY.equal(anchors.centerY)
        loadingView?.anchors.size.equal(.init(width: 125, height: 125))
    }
}

// MARK: - TUI Loading Controll
extension HotNewsLoadingView: TUIPlayerShortVideoLoadingViewProtocol {
    
    func startLoading() {
//        loadingView?.startAnimating()
    }
    
    func stopLoading() {
//        loadingView?.stopAnimating() 
    }
}
