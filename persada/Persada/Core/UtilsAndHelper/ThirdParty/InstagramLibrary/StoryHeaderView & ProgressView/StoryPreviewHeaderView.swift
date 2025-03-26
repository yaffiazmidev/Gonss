//
//  StoryPreviewHeaderView.swift
//  RnDPersada
//
//  Created by NOOR on 13/01/21.
//  Copyright © 2021 Muhammad Noor. All rights reserved.
//

import UIKit

protocol StoryPreviewHeaderProtocol: AnyObject {
    func didTapCloseButton()
    func didTapProfile()
}

fileprivate let maxSnaps = 30

//Identifiers
public let progressIndicatorViewTag = 88
public let progressViewTag = 99

//Identifiers

final class StoryPreviewHeaderView: UIView {
    
    //MARK: - Overriden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        
        loadUIElements()
        installLayoutConstraints()  
        
        //MARK:- Add Tap Gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapProfile(_:)))
        snaperImageView.isUserInteractionEnabled = true
        snaperImageView.addGestureRecognizer(tap)
        
        let tapDetail = UITapGestureRecognizer(target: self, action: #selector(didTapProfile(_:)))
        detailView.isUserInteractionEnabled = true
        detailView.addGestureRecognizer(tapDetail)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - iVars
    public weak var delegate:StoryPreviewHeaderProtocol?
    fileprivate var snapsPerStory:Int = 0
    
    public var story: StoriesItem? {
        didSet {
            snapsPerStory  = (story?.storiesCount)! < maxSnaps ? (story?.storiesCount)! : maxSnaps
        }
    }
    
    fileprivate var progressView:UIView?
    
    internal let snaperImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let detailView:UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let snaperNameLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .Roboto(.bold, size: 17)
        
        return label
    }()
    
    internal let lastUpdatedLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .Roboto(.regular, size: 12)
        return label
    }()
    
    private lazy var closeButton:UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: String.get(.arrowleft))?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(didTapClose(_:)), for: .touchUpInside)
        button.tintColor = .white
        return button
    }()
    
    public var getProgressView: UIView {
        if let progressView = self.progressView {
            return progressView
        }
        
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        self.progressView = v
        self.addSubview(self.getProgressView)
        return v
    }
    
    //MARK: - Private functions
    private func loadUIElements(){
        backgroundColor = .clear
        
        addSubview(getProgressView)
        addSubview(snaperImageView)
        addSubview(detailView)
        detailView.addSubview(snaperNameLabel)
        detailView.addSubview(lastUpdatedLabel)
        addSubview(closeButton)
    }
    
    private func installLayoutConstraints(){
        
        //Setting constraints for progressView
        let pv = getProgressView
        NSLayoutConstraint.activate([
            pv.leftAnchor.constraint(equalTo: self.leftAnchor),
            pv.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            pv.rightAnchor.constraint(equalTo: self.rightAnchor),
            pv.heightAnchor.constraint(equalToConstant: 10)
        ])
        
        //Setting constraints for snapperImageView
        NSLayoutConstraint.activate([
            snaperImageView.widthAnchor.constraint(equalToConstant: 40),
            snaperImageView.heightAnchor.constraint(equalToConstant: 40),
            snaperImageView.leftAnchor.constraint(equalTo: closeButton.rightAnchor, constant: 0),
            snaperImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0.0)
        ])
        
        //Setting constraints for detailView
        NSLayoutConstraint.activate([
            detailView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            detailView.heightAnchor.constraint(equalToConstant: 40),
            detailView.widthAnchor.constraint(equalToConstant: 200),
            detailView.leftAnchor.constraint(equalTo: snaperImageView.rightAnchor, constant: 10),
        ])
        
        //Setting constraints for closeButton
        NSLayoutConstraint.activate([
            closeButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            closeButton.leftAnchor.constraint(equalTo: self.leftAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 60),
            closeButton.heightAnchor.constraint(equalToConstant: self.frame.height)
        ])
        
        //Setting constraints for snapperNameLabel
        NSLayoutConstraint.activate([
            snaperNameLabel.topAnchor.constraint(equalTo: detailView.topAnchor),
            snaperNameLabel.leftAnchor.constraint(equalTo: detailView.leftAnchor),
            lastUpdatedLabel.leftAnchor.constraint(equalTo: detailView.rightAnchor, constant: 10.0),
            snaperNameLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
        ])
        
        //Setting constraints for lastUpdatedLabel
        NSLayoutConstraint.activate([
            lastUpdatedLabel.topAnchor.constraint(equalTo: snaperNameLabel.bottomAnchor, constant: 2),
            lastUpdatedLabel.leftAnchor.constraint(equalTo: detailView.leftAnchor)
        ])
        
        layoutIfNeeded()
    }
    private func applyShadowOffset() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
    }
    
    private func applyProperties<T:UIView>(_ view:T,with tag:Int,alpha:CGFloat = 1.0)->T {
        view.layer.cornerRadius = 1
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.whiteSmoke.withAlphaComponent(alpha)
        view.tag = tag
        return view
    }
    
    //MARK: - Selectors
    @objc func didTapClose(_ sender: UIButton) {
        delegate?.didTapCloseButton()
    }
    @objc func didTapProfile(_ sender: UIButton) {
        delegate?.didTapProfile()
    }
    
    //MARK: - Public functions
    public func clearTheProgressorSubviews() {
        
        getProgressView.subviews.forEach { v in
            v.subviews.forEach{v in (v as! SnapProgressView).stop()}
            v.removeFromSuperview()
        }
    }
    
    public func createSnapProgressors(){
        
        let padding: CGFloat = 4 //GUI-Padding
        let height: CGFloat = 3
        var x: CGFloat = padding
        let y: CGFloat = (self.getProgressView.frame.height/2)-height
        let width = (IGScreen.width - ((snapsPerStory+1).toFloat * padding))/snapsPerStory.toFloat
        
        for i in 0..<snapsPerStory {
            let pvIndicator = UIView.init(frame: CGRect(x: x, y: y, width: width, height: height))
            getProgressView.addSubview(applyProperties(pvIndicator, with: i+progressIndicatorViewTag,alpha:0.5))
            let pv = SnapProgressView.init(frame: CGRect(x: x, y: y, width: 0, height: height))
            getProgressView.addSubview(applyProperties(pv,with: i+progressViewTag))
            
            x = x + width + padding
        }
        
        snaperNameLabel.text = story?.account?.username
    }
}
