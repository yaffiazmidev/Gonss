//
//  Toast.swift
//  KipasKipas
//
//  Created by DENAZMI on 29/12/21.
//  Copyright © 2021 Koanba. All rights reserved.
//


import UIKit

class Toast {
    static let share = Toast()
    private var view: ToastView!
    
    init() {
        view = ToastView()
    }
    
    func show(
        duration: CGFloat = 3.0,
        message: String? = nil,
        _ alignment: NSTextAlignment = .center,
        textColor: UIColor = .white,
        backgroundColor: UIColor? = .primary,
        cornerRadius: CGFloat? = nil,
        completion: (() -> Void)? = nil
    ) {
        guard let topMostView = UIApplication.shared.topMostViewController()?.view else { return }
        topMostView.endEditing(true)
        topMostView.addSubview(view)
        topMostView.bringSubviewToFront(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.subView.translatesAutoresizingMaskIntoConstraints = false
        view.messageLabel.text = message
        view.messageLabel.textColor = textColor
        view.messageLabel.textAlignment = alignment
        view.subView.backgroundColor = backgroundColor
        
        if let cornerRadius = cornerRadius {
            view.subView.layer.cornerRadius = cornerRadius
        }
        
        
        let margins = topMostView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            view.leftAnchor.constraint(equalTo: topMostView.leftAnchor),
            view.rightAnchor.constraint(equalTo: topMostView.rightAnchor),
            view.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -12),
            
            view.subView.leftAnchor.constraint(equalTo: margins.leftAnchor),
            view.subView.rightAnchor.constraint(equalTo: margins.rightAnchor),
            view.subView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -16)
        ])
        
        animateView(animations: {
            self.view.subView?.alpha = 1
        }) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.animateView(animations: {
                    self.view.subView?.alpha = 0
                }) {
                    self.view.removeFromSuperview()
                    completion?()
                }
            }
        }
    }
    
    private func animateView(animations: @escaping () -> Void, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3, animations: animations) { _ in
            completion()
        }
    }
}
