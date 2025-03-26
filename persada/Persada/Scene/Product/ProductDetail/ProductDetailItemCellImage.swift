//
//  ProductDetailItemCellImage.swift
//  Persada
//
//  Created by movan on 22/07/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

class ProductDetailItemCellImage: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var items: [String]? {
        didSet {
            if let numberOfPages = items?.count {
                pageControl.numberOfPages = numberOfPages
            }
        }
    }
    
    var handleOption: (() -> Void)?
    var dismiss: (() -> Void)?
    
    lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.dataSource = self
        view.delegate = self
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.registerCustomCell(ImageCell.self)
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var backButton: UIButton = {
        let image = UIImage(named: .get(.iconBack))?.withRenderingMode(.alwaysOriginal)
        let button = UIButton(image: image!, target: self, action: #selector(onClickBack))
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.clipsToBounds = true
        button.layer.masksToBounds = false
        button.backgroundColor = UIColor.black25
        return button
    }()
    
    lazy var optionButton: UIButton = {
        let image = UIImage(named: .get(.iconKebab))?.withRenderingMode(.alwaysOriginal)
        let button = UIButton(image: image!, target: self, action: #selector(handleOptionButton))
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.clipsToBounds = true
        button.layer.masksToBounds = false
        button.backgroundColor = UIColor.black25
        return button
    }()
    
    let pageControl: UIPageControl = {
        let page = UIPageControl()
        page.currentPageIndicatorTintColor = .primary
        page.pageIndicatorTintColor = .white
        return page
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleOptionButton() {
        self.handleOption?()
    }
    
    func setupViewCell() {
        
        addSubview(collectionView)
        addSubview(pageControl)
        
        addSubview(optionButton)
        addSubview(backButton)
        collectionView.fillSuperview()
        //		collectionView.addSubview(optionButton)
        //		collectionView.addSubview(backButton)
        backButton.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        
        optionButton.anchor(top: safeAreaLayoutGuide.topAnchor, right: safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingRight: 16, width: 40, height: 40)
        
        pageControl.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 30, paddingRight: 0, width: 0, height: 10)
        
    }
    
    @objc private func onClickBack() {
        self.dismiss?()
    }
    
}

extension ProductDetailItemCellImage {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = collectionView.frame.size.width
        pageControl.currentPage = Int(collectionView.contentOffset.x / pageWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCustomCell(with: ImageCell.self, indexPath: indexPath)
        let url = items?[indexPath.row] ?? ""
        
        //		cell.imageView.loadImage(at: url)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let imageWidth = frame.size.width
        let imageHeight = imageWidth + (imageWidth / 3)
        return CGSize(width: imageWidth, height: imageHeight)
    }
}

class ImageCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewCell()
    }
    
    let mediaContainerView: UIView = {
        let view: UIView = UIView()
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    let image = UIImageView(frame: .zero)
    let imagePause = UIImageView(frame: .zero)
    let iconPause = UIImage(named: "play.circle.fill")
    
    var onImageClick = {}
    func setupViewCell(){
        imagePause.image = iconPause
        
        
        
        addSubview(mediaContainerView)
        mediaContainerView.fillSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpCell(media: Medias) {
        if media.type == "video"  {
            
            mediaContainerView.addSubview(image)
            imagePause.isHidden = false
            image.clipsToBounds = true
            imagePause.isHidden = true
            image.contentMode = .scaleAspectFill
            image.fillSuperview()
            image.loadImage(at: media.thumbnail?.large ?? "", low: media.thumbnail?.medium ?? "")
            mediaContainerView.addSubview(imagePause)
            mediaContainerView.bringSubviewToFront(imagePause)
            imagePause.centerXAnchor.constraint(equalTo: mediaContainerView.centerXAnchor).isActive = true
            imagePause.centerYAnchor.constraint(equalTo: mediaContainerView.centerYAnchor).isActive = true
            imagePause.isHidden = false
            imagePause.anchor(width: 30, height: 30)
            
        } else {
            mediaContainerView.addSubview(image)
            image.clipsToBounds = true
            imagePause.isHidden = true
            image.contentMode = .scaleAspectFill
            image.fillSuperview()
            image.loadImage(at: media.thumbnail?.large ?? "", low: media.thumbnail?.medium ?? "")
        }
    }
}

extension ImageCell : AGVideoPlayerViewDelegate {
    func timeChange(_ time: String) {
        
    }
    
    func videoPlaying() {
        imagePause.isHidden = true
    }
    
    func videoPause() {
        imagePause.isHidden = false
    }
    
    
}
