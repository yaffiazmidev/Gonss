//
//  KKDefaultLoading.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 03/08/23.
//

import UIKit

public class KKDefaultLoading {
    
    public static let shared = KKDefaultLoading()
    
    private lazy var loadingView: KKDefaultLoadingView = {
        let view = KKDefaultLoadingView().loadViewFromNib() as! KKDefaultLoadingView
        return view
    }()
    
    public init() {}
    
    public func show(message: String? = nil, completion: (() -> Void)? = nil) {
        guard let topMostView = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }

        topMostView.endEditing(true)
        topMostView.addSubview(loadingView)
        topMostView.bringSubviewToFront(loadingView)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.activityLoadingView.startAnimating()
        loadingView.messageLabel.isHidden = message == nil
        loadingView.messageLabel.text = message
        
        NSLayoutConstraint.activate([
            loadingView.leftAnchor.constraint(equalTo: topMostView.leftAnchor),
            loadingView.topAnchor.constraint(equalTo: topMostView.topAnchor),
            loadingView.rightAnchor.constraint(equalTo: topMostView.rightAnchor),
            loadingView.bottomAnchor.constraint(equalTo: topMostView.bottomAnchor),
        ])
        
        animateView(animations: { [weak self] in
            guard let self = self else { return }
            
            self.loadingView.alpha = 1
        }) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                
            }
        }
    }
    
    public func hide(completion: (() -> Void)? = nil) {
        animateView(animations: { [weak self] in
            guard let self = self else { return }
            
            self.loadingView.alpha = 0
        }) { [weak self] in
            guard let self = self else { return }
            
            self.loadingView.removeFromSuperview()
            completion?()
        }
    }
    
    private func animateView(animations: @escaping () -> Void, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3, animations: animations) { _ in
            completion()
        }
    }
}

