//
//  ReviewViewController.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 14/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

class ReviewViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var collectionView: ReviewCollectionView!
    
    let idProduct: String
    let loader: ReviewPagedLoader
    var router: ReviewRouter?
    
    var review: Review?
    var request: ReviewPagedRequest
    private var isLoadingPaging: Bool
    private var isLast: Bool
    
    lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl(backgroundColor: .white)
        refresh.tintColor = .primary
        refresh.addTarget(self, action: #selector(refreshUI), for: .valueChanged)
        return refresh
    }()
    
    init(idProduct: String, loader: ReviewPagedLoader) {
        self.idProduct = idProduct
        self.loader = loader
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
        title = .get(.reviewAll)
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
        review = nil
        isLast = false
        request.page = 0
        collectionView.withHeader = false
        collectionView.setData([])
        loadData()
    }
    
    @objc private func back() {
        router?.dismiss()
    }
    
    private func setupCollectionView(){
        collectionView.refreshControl = refreshControl
        collectionView.showDivider = true
        collectionView.viewInsets = UIEdgeInsets(all: 20)
        collectionView.withHeader = false
        collectionView.handleItemTapped = { review in
            
        }
        collectionView.handleMediaItemTapped = { review, media, atMedia in
            self.router?.detailMedia(review.medias ?? [], itemAt: atMedia)
        }
        collectionView.handleScrollViewDidScroll = { [weak self] (scrollView) in
            guard let self = self else { return }
            guard scrollView.isDragging else { return }
              
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height - 300
            if (offsetY > contentHeight - scrollView.frame.height) {
                if !self.isLoadingPaging && !self.isLast {
                    self.isLoadingPaging = true
                    self.request.page += 1
                    self.loadData()
                }
            }
        }
    }
}

extension ReviewViewController {
    func loadData(){
        loader.load(request: request) { [weak self] (result) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.isLoadingPaging = false
                switch(result){
                case .success(let review):
                    if self.review == nil {
                        self.review = review
                    }else{
                        if self.review!.reviews == nil{
                            self.review!.reviews = []
                        }
                        review.reviews?.forEach({ item in
                            self.review!.reviews!.append(item)
                        })
                    }
                    self.collectionView.withHeader = true
                    self.collectionView.setData(self.review?.reviews ?? [], ratingAverage: review.ratingAverage, ratingCount: review.ratingCount, reviewCount: review.reviewCount)
                    break
                case .failure(let error):
                    print("*** failed load review \(error)")
                    if let error = error as? RemoteReviewLoader.Error {
                        if error == .noData {
                            self.isLast = true
                            break
                        }
                    }
                    
                    Toast.share.show(message: "Gagal memuat review")
                    break
                }
            }
        }
    }
    
}
