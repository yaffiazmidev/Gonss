//
//  KKLoading.swift
//  KipasKipas
//
//  Created by DENAZMI on 09/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class KKLoading {
    static let shared = KKLoading()
    private var view: LoadingView!
    
    let loading = NVActivityIndicatorView(frame: .zero, type: .lineScale, color: .white, padding: 0)
    
    init() {
        view = LoadingView()
    }
    
    func show(message: String? = nil, completion: (() -> Void)? = nil) {
        guard let topMostView = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }

        topMostView.endEditing(true)
        topMostView.addSubview(view)
        topMostView.bringSubviewToFront(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.messageLabel.isHidden = message == nil
        view.messageLabel.text = message
        view.activityContainerView.addSubview(loading)
        loading.translatesAutoresizingMaskIntoConstraints = false
        loading.startAnimating()
        
        NSLayoutConstraint.activate([
            view.leftAnchor.constraint(equalTo: topMostView.leftAnchor),
            view.topAnchor.constraint(equalTo: topMostView.topAnchor),
            view.rightAnchor.constraint(equalTo: topMostView.rightAnchor),
            view.bottomAnchor.constraint(equalTo: topMostView.bottomAnchor),
            
            loading.leftAnchor.constraint(equalTo: view.activityContainerView.leftAnchor),
            loading.topAnchor.constraint(equalTo: view.activityContainerView.topAnchor),
            loading.rightAnchor.constraint(equalTo: view.activityContainerView.rightAnchor),
            loading.bottomAnchor.constraint(equalTo: view.activityContainerView.bottomAnchor),
        ])
        
        animateView(animations: {
            self.view.contentView?.alpha = 1
            self.loading.startAnimating()
        }) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                
            }
        }
    }
    
    func hide(completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            self.animateView(animations: {
                self.view.contentView?.alpha = 0
            }) {
                self.view.removeFromSuperview()
                completion?()
            }
        }
    }
    
    private func animateView(animations: @escaping () -> Void, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3, animations: animations) { _ in
            completion()
        }
    }
}
