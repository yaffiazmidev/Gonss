//
//  ReviewMediaViewController.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 17/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class ReviewMediaViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    
    let idProduct: String
    let loader: ReviewMediaPagedLoader
    var router: ReviewRouter?
    
    var medias: [ReviewMedia]
    var request: ReviewPagedRequest
    private var isLoadingPaging: Bool
    private var isLast: Bool
    
    lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl(backgroundColor: .white)
        refresh.tintColor = .primary
        refresh.addTarget(self, action: #selector(refreshUI), for: .valueChanged)
        return refresh
    }()
    
    init(idProduct: String, loader: ReviewMediaPagedLoader) {
        self.idProduct = idProduct
        self.loader = loader
        self.medias = []
        self.isLoadingPaging = false
        self.isLast = false
        self.request = ReviewPagedRequest(productId: idProduct, size: 10, isPublic: !AUTH.isLogin())
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = .get(.reviewPhotoAll)
        navigationController?.hideKeyboardWhenTappedAround()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: .get(.arrowleft)),
                                                           style: .plain, target: self, action: #selector(back))
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        setupCollectionView()
        loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.backgroundColor = nil
    }
    
    @objc func refreshUI() {
        request.page = 0
        isLast = false
        medias = []
        mediaCollectionView.reloadData()
        loadData()
    }
    
    @objc private func back() {
        router?.dismiss()
    }
    
    private func setupCollectionView(){
        mediaCollectionView.delegate = self
        mediaCollectionView.dataSource = self
        mediaCollectionView.refreshControl = refreshControl
        mediaCollectionView.registerXibCell(ReviewMediaCollectionViewCell.self)
        
        let flowLayout = DENCollectionViewLayout()
        flowLayout.columnCount = 2
        flowLayout.minimumInteritemSpacing = 8
        flowLayout.minimumColumnSpacing = 12
        mediaCollectionView.showsVerticalScrollIndicator = false
        mediaCollectionView.alwaysBounceVertical = true
        mediaCollectionView.collectionViewLayout = flowLayout
    }
}

extension ReviewMediaViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return medias.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ReviewMediaCollectionViewCell.self, for: indexPath)
        cell.setupView(medias[indexPath.row], showRatingDate: true)
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isDragging else { return }
          
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height - 500
        if (offsetY > contentHeight - scrollView.frame.height) {
            if !isLoadingPaging && !isLast {
                isLoadingPaging = true
                request.page += 1
                loadData()
            }
        }
    }
}

extension ReviewMediaViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        router?.detailMedia(medias, itemAt: indexPath.row, loader: loader, request: request, onMediasUpdated: { [weak self] (medias, request, isLast) in
            guard let self = self else { return }
            self.medias = medias
            self.request = request
            self.isLast = isLast
            self.mediaCollectionView.reloadData()
        })
    }
}

extension ReviewMediaViewController: DENCollectionViewDelegateLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.width - 48) / 2 //padding horizontal (2x20) + spacing(8)
        let height = width + 18 //rating date view height(12) + spacer(6)
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetsFor section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(horizontal: 20, vertical: 16)
    }
    
}

// MARK: - Network
extension ReviewMediaViewController{
    private func loadData(){
        loader.load(request: request) { [weak self] (result) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.isLoadingPaging = false
                switch(result){
                case .success(let data):
                    self.medias.append(contentsOf: data.content)
                    self.mediaCollectionView.reloadData()
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
