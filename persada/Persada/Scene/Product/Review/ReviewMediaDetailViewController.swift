//
//  ReviewMediaDetailViewController.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 25/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class ReviewMediaDetailViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    
    var router: ReviewRouter?
    var loader: ReviewMediaPagedLoader?
    var request: ReviewPagedRequest?
    var onMediasUpdated: (([ReviewMedia], ReviewPagedRequest, Bool) -> Void)?
    
    private var medias: [ReviewMedia]
    private var currentIndex: Int
    private var isLoadingPaging: Bool
    private var isLast: Bool
    private var hasLoaded: Bool
    
    init(medias: [ReviewMedia], itemAt: Int) {
        self.medias = medias
        self.currentIndex = itemAt
        self.isLoadingPaging = false
        self.isLast = false
        self.hasLoaded = false
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = .get(.reviewPhotoAll)
        navigationController?.hideKeyboardWhenTappedAround()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: .get(.iconCloseWhite)),
                                                           style: .plain, target: self, action: #selector(back))
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        setupNavbarStyle()
        setupCollectionView()
        if medias.isEmpty{
            loadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.backgroundColor = nil
        
        let customNavBarAppearance = UINavigationBarAppearance()
        customNavBarAppearance.configureWithOpaqueBackground()
        customNavBarAppearance.backgroundColor = .white
        customNavBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationController?.navigationBar.scrollEdgeAppearance = customNavBarAppearance
        navigationController?.navigationBar.compactAppearance = customNavBarAppearance
        navigationController?.navigationBar.standardAppearance = customNavBarAppearance
        if #available(iOS 15.0, *) {
            navigationController?.navigationBar.compactScrollEdgeAppearance = customNavBarAppearance
        }
    }
    
    @objc private func back() {
        router?.dismiss()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if currentIndex < medias.count && !hasLoaded{ //handle for out of range
            mediaCollectionView.isPagingEnabled = false
            mediaCollectionView.scrollToItem(at: IndexPath(row: currentIndex, section: 0), at: .centeredHorizontally, animated: false)
            mediaCollectionView.isPagingEnabled = true
            hasLoaded = true
        }
    }

    private func setupCollectionView(){
        mediaCollectionView.delegate = self
        mediaCollectionView.dataSource = self
        mediaCollectionView.registerXibCell(ReviewMediaDetailCollectionViewCell.self)
        mediaCollectionView.layoutIfNeeded()
    }
    
    private func setupNavbarStyle(){
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.isTranslucent = false

        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        if #available(iOS 15.0, *) {
            navigationController?.navigationBar.compactScrollEdgeAppearance = appearance
        }
    }
}

extension ReviewMediaDetailViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return medias.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ReviewMediaDetailCollectionViewCell.self, for: indexPath)
        let index = indexPath.row
        let media = medias[index]
        cell.setupView(media, itemAt: index, itemsCount: medias.count)
        cell.onMore = {
            let view = ReviewMediaDetailCaptionView()
            let vc = ReviewMediaDetailCaptionController(data: media.toReviewItem(), view: view)
            
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .overFullScreen
            nav.navigationBar.isHidden  = true
            self.present(nav, animated: false)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isDragging else { return }
          
        let offsetX = scrollView.contentOffset.x
        let contentWidth = scrollView.contentSize.width - 300
        if (offsetX > contentWidth - scrollView.frame.width) {
            if let _ = self.request, let _ = self.loader{
                if !isLoadingPaging && !isLast {
                    isLoadingPaging = true
                    self.request!.page += 1
                    loadData()
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visibleRect = CGRect(origin: mediaCollectionView.contentOffset, size: mediaCollectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let indexPath = mediaCollectionView.indexPathForItem(at: visiblePoint)
        if let index = indexPath?.row {
            currentIndex = index
        }
    }
}

extension ReviewMediaDetailViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}

// MARK: - Network
extension ReviewMediaDetailViewController{
    private func loadData(){
        guard let loader = loader, let request = request else { return }
        loader.load(request: request) { [weak self] (result) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoadingPaging = false
                switch(result){
                case .success(let data):
                    self.medias.append(contentsOf: data.content)
                    self.mediaCollectionView.reloadData()
                    self.onMediasUpdated?(self.medias, self.request!, self.isLast)
                    self.isLast = data.last
                    break
                case .failure(let error):
                    print("*** failed load media review \(error)")
                    if let error = error as? RemoteReviewLoader.Error {
                        if error == .noData {
                            break
                        }
                    }
                    
                    Toast.share.show(message: "Gagal memuat data")
                    break
                }
            }
        }
    }
}
