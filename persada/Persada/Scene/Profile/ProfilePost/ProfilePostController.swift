//
//  ProfilePostController.swift
//  Persada
//
//  Created by Muhammad Noor on 14/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import ContextMenu

private let cellId: String = "cellId"

class ProfilePostController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
    
    // MARK: - Private Property
    
    private var viewModel: ProfilePostViewModel?
    
    // MARK: - Public Property
    
    lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.prefetchDataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ProfilePostCell.self, forCellWithReuseIdentifier: cellId)
        return collectionView
    }()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.collectionView.reloadData()
    }
    
    convenience init(viewModel: ProfilePostViewModel) {
        self.init()
        
        self.viewModel = viewModel
        bindViewModel()
        viewModel.fetchPosts()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        collectionView.fillSuperviewSafeAreaLayoutGuide()
        collectionView.backgroundColor = .white
    }
    
    func bindViewModel()  {
        viewModel?.postHandler = { [weak self] change in
            
            guard let self = self else {
                return
            }
            
            switch change {
            case .didEncounterError(let error):
                print(error?.statusMessage ?? "")
            case .didUpdatePostProfile(let index):
                
                guard let _ = index else {
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                    return
                }
            }
        }
    }
    
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= viewModel?.currentCount ?? 0 - 1
    }
    
    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = collectionView.indexPathsForVisibleItems
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
    
}

extension ProfilePostController {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.totalCount ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ProfilePostCell

        if isLoadingCell(for: indexPath) {

        } else {
            cell.item = viewModel?.posts(at: indexPath.row)
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 12, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: 400)
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            self.viewModel?.fetchPosts()
        }
    }
}
