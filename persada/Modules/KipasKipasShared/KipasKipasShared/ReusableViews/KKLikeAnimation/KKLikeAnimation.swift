//
//  KKLikeAnimation.swift
//  KipasKipasShared
//
//  Created by DENAZMI on 16/02/24.
//

import UIKit

public class KKLikeAnimation {
    
    public static let shared = KKLikeAnimation()
    
    private lazy var animationView: KKLikeAnimationView = {
        let view = KKLikeAnimationView()
        return view
    }()
    
    public init() {}
    
    public func show(duration: CGFloat = 2.5, completion: (() -> Void)? = nil) {
        guard let topMostView = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }

        topMostView.endEditing(true)
        topMostView.addSubview(animationView)
        topMostView.bringSubviewToFront(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.likeImageView.transform = .identity
        
        NSLayoutConstraint.activate([
            animationView.leftAnchor.constraint(equalTo: topMostView.leftAnchor),
            animationView.topAnchor.constraint(equalTo: topMostView.topAnchor),
            animationView.rightAnchor.constraint(equalTo: topMostView.rightAnchor),
            animationView.bottomAnchor.constraint(equalTo: topMostView.bottomAnchor),
        ])
        
        animateView(animations: { [weak self] in
            guard let self = self else { return }
            
            self.animationView.alpha = 1
            self.animationView.likeImageView.alpha = 1
            self.animationView.likeImageView.transform = CGAffineTransform(scaleX: 3.5, y: 3.5)
        }) {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.animateView(animations: {
                    self.animationView.likeImageView.transform = CGAffineTransform(scaleX: 3.5, y: 3.5)
                    self.animationView.alpha = 0
                }) {
                    self.animationView.removeFromSuperview()
                    completion?()
                }
            }
        }
    }
    
    func startIconAnimation() {
            // Animasi untuk membesar ikon
            UIView.animate(withDuration: 1.0, animations: {
                self.animationView.likeImageView.alpha = 1
                self.animationView.likeImageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }) { (completed) in
                // Animasi untuk mengecilkan ikon
                UIView.animate(withDuration: 1.0, animations: {
                    self.animationView.likeImageView.transform = CGAffineTransform.identity
                }) { (completed) in
                    // Panggil kembali fungsi untuk mengulangi animasi
                    self.startIconAnimation()
                }
            }
        }
    
    private func animateView(animations: @escaping () -> Void, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.5, animations: animations) { _ in
            completion()
        }
    }
}
