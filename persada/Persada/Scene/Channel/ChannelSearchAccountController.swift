//
//  ChannelSearchAccountController.swift
//  KipasKipas
//
//  Created by movan on 04/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol ChannelSearchAccountDisplayLogic where Self: UIViewController {
    
    func displayViewModel(_ viewModel: ChannelSearchAccountModel.ViewModel)
}

final class ChannelSearchAccountController: UIViewController, Displayable, ChannelSearchAccountDisplayLogic {
    
    let mainView: ChannelSearchAccountView
    var interactor: ChannelSearchAccountInteractable!
    private var router: ChannelSearchAccountRouting!
    var isLoading: Bool!
    
    init(mainView: ChannelSearchAccountView, dataSource: ChannelSearchAccountModel.DataSource) {
        self.mainView = mainView
        self.isLoading = false
        super.init(nibName: nil, bundle: nil)
        interactor = ChannelSearchAccountInteractor(viewController: self, dataSource: dataSource)
        router = ChannelSearchAccountRouter(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let accounts = ChannelSearchAccountSimpleCache.instance.getAccounts, !accounts.isEmpty {
            interactor.dataSource.data = accounts
            print("FROM CACHE FEEDS 0")
            mainView.collectionView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hideKeyboardWhenTappedAround()
        navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.backgroundColor = nil
    }
    
    override func loadView() {
        view = mainView
        mainView.collectionView.delegate = self
        mainView.collectionView.dataSource = self
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
    }
        
    // MARK: - ChannelSearchAccountDisplayLogic
    func displayViewModel(_ viewModel: ChannelSearchAccountModel.ViewModel) {
        DispatchQueue.main.async {
            self.isLoading = false
            let emptyView = self.mainView.emptyView(self.interactor.dataSource.text)
            
            switch viewModel {
                
            case .accounts(let viewModel):
                if self.interactor.dataSource.data == nil {
                    self.interactor.dataSource.data = viewModel
                }else{
                    self.interactor.dataSource.data?.append(contentsOf: viewModel)
                }
                self.mainView.collectionView.backgroundView = viewModel.isEmpty ? emptyView : nil
                self.mainView.collectionView.reloadData()
                
            case .failedSeachAccounts(_):
                self.interactor.dataSource.data = nil
                self.mainView.collectionView.backgroundView = emptyView
                self.mainView.collectionView.reloadData()
            }
        }
    }
}


// MARK: - ChannelSearchAccountViewDelegate
extension ChannelSearchAccountController: UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let data = self.interactor.dataSource.data else {
            return 0
        }
        
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ChannelSearchAccountCell.self, for: indexPath)
        
        guard let item = self.interactor.dataSource.data?[indexPath.row] else {
            return cell
        }
        
        cell.data = item
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 32, height: 46)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(horizontal: 16, vertical: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let item = self.interactor.dataSource.data, let id = item[indexPath.row].id else {
            return
        }
        
        router.routeTo(.showProfile(id: id))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { return 12 }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let view = collectionView.dequeueReusableCustomHeaderView(with: ChannelHeaderView.self, indexPath: indexPath)
            view.label.text = "Result"
            return view
            
        default:
            fatalError("Unexpected viewForSupplementaryElementOfKind in collection view")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let isEmpty = interactor.dataSource.data?.isEmpty ?? true
        return CGSize(width: collectionView.frame.width, height: isEmpty ? 0 : 48)
    }
    
    // MARK: - Enable this code when using pagination
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        guard scrollView.isDragging, let items = self.interactor.dataSource.data else { return }
//
//        let offsetY = scrollView.contentOffset.y
//        let contentHeight = scrollView.contentSize.height - 500
//        if (offsetY > contentHeight - scrollView.frame.height) {
//            if !isLoading {
//                let page = interactor.page
//                if ( (items.count/10) >= page ) {
//                    self.isLoading = true
//                    self.interactor?.setPage(page + 1)
//                    self.interactor?.doRequest(.searchAccount)
//                }
//            }
//        }
//    }
}
