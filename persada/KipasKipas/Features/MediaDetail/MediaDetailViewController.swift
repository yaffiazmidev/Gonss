//
//  MediaDetailViewController.swift
//  KipasKipas
//
//  Created by DENAZMI on 13/09/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class MediaDetailViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var medias: [Medias] = []
    var selectedMediaIndex: Int = 0
    var isPlayVideo = false
    
    init(medias: [Medias], selectedMediaIndex: Int = 0, isPlayVideo: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self.medias = medias
        self.selectedMediaIndex = selectedMediaIndex
        self.isPlayVideo = isPlayVideo
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerXibCell(MediaDetailCollectionViewCell.self)
                
        pageControl.numberOfPages = medias.count
        pageControl.isEnabled = false
        overrideUserInterfaceStyle = .light
        DispatchQueue.main.async {
            self.collectionView.selectItem(at: IndexPath(item: self.selectedMediaIndex, section: 0), animated: false, scrollPosition: .centeredHorizontally)
            self.collectionView.layoutIfNeeded()
            self.pageControl.currentPage = self.selectedMediaIndex
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.async {
            self.collectionView.visibleCells.forEach { cell in
                if let cell = cell as? MediaDetailCollectionViewCell {
                    cell.resetVideo()
                }
            }
        }
    }
}

extension MediaDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return medias.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(MediaDetailCollectionViewCell.self, for: indexPath)
        let media = medias[indexPath.item]
        cell.videoPlayerView.onTap {
            cell.handleOnTapPlayerView()
        }
        cell.setupView(media: media)
        cell.setupVideo(url: media.url ?? "")
        cell.thumbnailImageView.loadImage(at: media.thumbnail?.large ?? "")
        if isPlayVideo {
            cell.autoPlayVideo()
        }
        return cell
    }
}

extension MediaDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? MediaDetailCollectionViewCell {
            cell.resetVideo()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size
        
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = collectionView.indexPathForItem(at: visiblePoint) else { return }
        
        if let _ = collectionView.cellForItem(at: indexPath) as? MediaDetailCollectionViewCell {
            pageControl.currentPage = indexPath.item
        }
    }
}

extension MediaDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}
