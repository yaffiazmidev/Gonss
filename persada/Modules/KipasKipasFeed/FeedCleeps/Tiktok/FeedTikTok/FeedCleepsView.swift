//
//  FeedTikTokView.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 24/05/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

public class FeedCleepsView: UIView {

    lazy var collectionView: UICollectionView = {
        let flow = UICollectionViewFlowLayout()
        flow.estimatedItemSize = .zero
        let coll = UICollectionView(frame: .zero, collectionViewLayout: flow)
        coll.translatesAutoresizingMaskIntoConstraints = false
        coll.allowsMultipleSelection = false
        coll.isMultipleTouchEnabled = false
        coll.backgroundColor = .white
        coll.showsVerticalScrollIndicator = false
        coll.isPagingEnabled = true
        coll.bounces = true
        coll.backgroundColor = .black
        coll.contentMode = .scaleAspectFit
        coll.register(UINib(nibName: "TiktokPostViewCell", bundle: SharedBundle.shared.bundle), forCellWithReuseIdentifier: "TiktokPostViewCell")
        return coll
    }()
    
    var handleLogin: (() -> Void)?
    
    lazy var reloadButton: UIButton = {
        let view = UIButton()
        view.backgroundColor = .gradientStoryOne
        view.setTitle("Refresh", for: .normal)
        view.tintColor = .white
        view.layer.cornerRadius = 8
        view.titleLabel?.font = .Roboto(.regular, size: 10)
        return view
    }()
    
    lazy var emptyView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var emptyIcon: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: .get(.iconWarning))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.alignment = .center
        view.distribution = .fill
        view.spacing = 16
        
        
        let emtyTitle = UILabel()
        emtyTitle.text = .get(.cleepsHabis)
        emtyTitle.textColor = .warning
        emtyTitle.font = .Roboto(.regular, size: 12)
        
        view.addArrangedSubview(emptyIcon)
        view.addArrangedSubview(emtyTitle)
        view.addArrangedSubview(reloadButton)
        return view
    }()
    
    lazy var overlayView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    
    lazy var buttonClose: UIButton = {
      let button = UIButton()
        button.backgroundColor = .whiteAlpha30
        button.tintColor = .white
        button.titleLabel?.font = .Roboto(.bold, size: 12)
        button.setTitle(.get(.close), for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(buttonCloseAction), for: .touchUpInside)
        addSubview(button)
        button.isHidden = true
        button.anchorFeedCleeps(width: 55, height: 22)
        return button
    }()
    
    lazy var loginView: UIView = {
        let view = UIView()
        view.accessibilityIdentifier = "loginview-feedcleeps"
        
        let iconImage = UIImageView(image: UIImage(systemName: "exclamationmark.circle"))
        iconImage.tintColor = .grey
        let emptyLabel = UILabel(text: .get(.loginFirst), font: .Roboto(.bold, size: 14), textColor: .grey, textAlignment: .center, numberOfLines: 0)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        lazy var loginButton = PrimaryButton(title: .get(.signIn), titleColor: .white)
        loginButton.setup(color: .gradientStoryOne, textColor: .white, font: .Roboto(.bold, size: 14))
        if #available(iOS 14.0, *) {
            loginButton.addAction(UIAction(handler: { [weak self] _ in
                self?.handleLogin?()
            }), for: .touchUpInside)
        } else {
            loginButton.addTarget(self, action: #selector(self.whenTappedLoginButton), for: .touchUpInside)
        }
        
        view.addSubview(emptyLabel)
        view.addSubview(iconImage)
        view.addSubview(loginButton)
        
        emptyLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        emptyLabel.widthAnchor.constraint(equalToConstant: 300).isActive = true
        emptyLabel.centerXTo(view.centerXAnchor)
        emptyLabel.centerYTo(view.centerYAnchor)
        
        iconImage.anchorFeedCleeps(bottom: emptyLabel.topAnchor, paddingBottom: 20, width: 40, height: 40)
        iconImage.centerXTo(view.centerXAnchor)
        
        loginButton.anchorFeedCleeps(top: emptyLabel.bottomAnchor, paddingTop: 20, width: 100, height: 40)
        loginButton.centerXTo(view.centerXAnchor)
        
        return view
    }()
    
    lazy var deletedView: UIView = {
        let view = UIView()
        let labelCaption = UILabel(text: .get(.feedDeleted), font: .Roboto(.medium, size: 12), textColor: .grey, textAlignment: .center, numberOfLines: 0)
        
        view.addSubview(labelCaption)
        labelCaption.heightAnchor.constraint(equalToConstant: 40).isActive = true
        labelCaption.widthAnchor.constraint(equalToConstant: 182).isActive = true
        labelCaption.centerXTo(view.centerXAnchor)
        labelCaption.centerYTo(view.centerYAnchor)
        
        return view
    }()
    
    var onCloseButtonPressed: (() -> Void)?
    
    let loading = NVActivityIndicatorView(frame: .zero, type: .lineScale, color: .lightSilver, padding: 0)
    let bottomLoading = NVActivityIndicatorView(frame: .zero, type: .ballPulse, color: .lightSilver, padding: 0)
    let topLoading = NVActivityIndicatorView(frame: .zero, type: .ballPulse, color: .lightSilver, padding: 0)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        
        addSubview(collectionView)
        collectionView.anchorFeedCleeps(top: topAnchor, leading: leadingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, trailing: trailingAnchor)
        emptyView.frame = collectionView.bounds
        emptyView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 32),
            stackView.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -32),
            stackView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: 50),
            reloadButton.widthAnchor.constraint(equalToConstant: 96),
            reloadButton.heightAnchor.constraint(equalToConstant: 32),
            emptyIcon.widthAnchor.constraint(equalToConstant: 32),
            emptyIcon.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        addSubview(loading)
        loading.centerInSuperview(size: CGSize(width: 40, height: 40))
        
        addSubview(topLoading)
        topLoading.anchorFeedCleeps(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 10, width: 30, height: 30)
        
        overlayView.addSubview(bottomLoading)
        bottomLoading.anchorFeedCleeps(left: overlayView.leftAnchor, bottom: overlayView.bottomAnchor, right: overlayView.rightAnchor, paddingBottom: 10, width: 30, height: 30)
        
        bringSubviewToFront(buttonClose)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        setEmptyViewBacgroundLayerColor()
        
        let clear = UIColor.clear.cgColor
        let color = UIColor.black.withAlphaComponent(0.35).cgColor
        
        let overlayViewGradient = CAGradientLayer()
        overlayViewGradient.colors = [color, clear, clear, color]
        overlayViewGradient.locations = [0, 0.12, 0.80, 1]
        overlayViewGradient.frame = bounds
        
        overlayView.backgroundColor = .blueCetacean
        overlayView.layer.insertSublayer(overlayViewGradient, at: 0)
        
        collectionView.backgroundView = overlayView
    }
    
    func showCloseButton() {
        buttonClose.isHidden = false
    }
    
    @objc
    func buttonCloseAction() {
        onCloseButtonPressed?()
    }
    
    func changeCollectionViewBackgroundToLogin() {
        let clear = UIColor.clear.cgColor
        let color = UIColor.black.withAlphaComponent(0.25).cgColor
        
        let overlayViewGradient = CAGradientLayer()
        overlayViewGradient.colors = [color, clear, clear, color]
        overlayViewGradient.locations = [0, 0.12, 0.80, 1]
        overlayViewGradient.frame = bounds
        
        addSubview(loginView)
        loginView.fillSuperviewFeedCleeps()
        collectionView.reloadData()
    }
    
    func changeCollectionViewBackgroundToDeletedPost(){
        addSubview(deletedView)
        deletedView.fillSuperviewFeedCleeps()
        collectionView.reloadData()
    }
    
    func setEmptyViewBacgroundLayerColor() {
        let clear = UIColor.clear.cgColor
        let color = UIColor.black.withAlphaComponent(0.1).cgColor
        
        let layer1 = CAGradientLayer()
        layer1.colors = [color, clear, clear, color]
        layer1.locations = [0, 0.25, 0.6, 1]
        layer1.frame = self.bounds
        
        emptyView.backgroundColor = .white
        emptyView.layer.insertSublayer(layer1, at: 0)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setEmptyTiktokView(isEmpty: Bool) {
        collectionView.backgroundView = isEmpty ? emptyView : nil
    }

    @objc func whenTappedLoginButton() {
        self.handleLogin?()
    }
}

