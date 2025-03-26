//
//  EidtMediaView.swift
//  KipasKipas
//
//  Created by Ibrohim Dasuqi on 27/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import AVKit

protocol EidtMediaViewDelegate where Self: UIViewController {

    func removeMedia(_ index: Int)
    func changeMedia(_ index: Int)
}

private let cellId: String = "cellId"

final class EidtMediaView: UIView {
    
    weak var delegate: EidtMediaViewDelegate?
    
    var images: [Medias] = []
    var index: Int = 0
    
    lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.dataSource = self
        view.delegate = self
        view.isPagingEnabled = true
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        view.register(UINib(nibName: "MediaItemCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        return view
    }()
    
    let pageControl: UIPageControl = {
        let page = UIPageControl()
        page.currentPageIndicatorTintColor = UIColor.black
        page.pageIndicatorTintColor = UIColor(white: 0, alpha: 0.25)
        page.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        return page
    }()
    
    lazy var changeMediaButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: String.get(.iconSwap))?.withRenderingMode(.alwaysOriginal)
        button.setImage(image, for: .normal)
        button.setTitleColor(.contentGrey, for: .normal)
        button.setTitle("Ganti Foto", for: .normal)
        button.addTarget(self, action: #selector(handleChangeMediaButton), for: .touchUpInside)
        return button
    }()
    
    lazy var removeMediaButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.contentGrey, for: .normal)
        button.setTitle(.get(.deletePost), for: .normal)
        let image = UIImage(named: String.get(.iconBin))?.withRenderingMode(.alwaysOriginal)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(handleRemoveMediaButton), for: .touchUpInside)
        return button
    }()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        addSubview(collectionView)
        addSubview(changeMediaButton)
        addSubview(removeMediaButton)
        addSubview(pageControl)

        changeMediaButton.anchor(top: nil, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 16, paddingRight: 0, width: 0, height: 40)

        removeMediaButton.widthAnchor.constraint(equalTo: changeMediaButton.widthAnchor, multiplier: 1).isActive = true
        
        removeMediaButton.anchor(top: nil, left: changeMediaButton.rightAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 16, paddingRight: 0, width: 0, height: 40)
        
        pageControl.anchor(top: nil, left: leftAnchor, bottom: changeMediaButton.topAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 16, paddingRight: 16, width: 0, height: 40)
        
        collectionView.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: pageControl.topAnchor, right: rightAnchor, paddingTop: 16, paddingLeft: 16, paddingBottom: 16, paddingRight: 16, width: 0, height: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func removeImage(_ index: Int) {
        images.remove(at: index)
        pageControl.numberOfPages = images.count
        self.index = pageControl.currentPage
        collectionView.reloadData()
    }
    
    func replaceImage(_ index: Int, media: Medias) {
        images.remove(at: index)
        images.insert(media, at: index)
        pageControl.numberOfPages = images.count
        collectionView.reloadData()
    }
    
    @objc func handleChangeMediaButton() {
        self.delegate?.changeMedia(index)
    }
    
    @objc func handleRemoveMediaButton() {
        self.delegate?.removeMedia(index)
    }
}

extension EidtMediaView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MediaItemCell
        cell.bindData(medias: images[indexPath.row])
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets.init(top: 0, left: 20, bottom: 0, right: 20)
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = collectionView.frame.size.width
        pageControl.currentPage = Int(collectionView.contentOffset.x / pageWidth)
        index = pageControl.currentPage
    }
    
}
