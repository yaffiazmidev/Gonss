//
//  ChannelSearchHashtagController.swift
//  KipasKipas
//
//  Created by movan on 04/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol ChannelSearchHashtagDisplayLogic where Self: UIViewController {
    
    func displayViewModel(_ viewModel: ChannelSearchHashtagModel.ViewModel)
}

final class ChannelSearchHashtagController: UIViewController, Displayable, ChannelSearchHashtagDisplayLogic {
    
    let mainView: ChannelSearchHashtagView
    var interactor: ChannelSearchHashtagInteractable!
    private var router: ChannelSearchHashtagRouting!
    
    init(mainView: ChannelSearchHashtagView, dataSource: ChannelSearchHashtagModel.DataSource) {
        self.mainView = mainView
        
        super.init(nibName: nil, bundle: nil)
        interactor = ChannelSearchHashtagInteractor(viewController: self, dataSource: dataSource)
        router = ChannelSearchHashtagRouter(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let hashtag = ChannelSearchHashtagSimpleCache.instance.getHashtags, !hashtag.isEmpty {
            interactor.dataSource.data = hashtag
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
    
    
    // MARK: - ChannelSearchHashtagDisplayLogic
    func displayViewModel(_ viewModel: ChannelSearchHashtagModel.ViewModel) {
        DispatchQueue.main.async {
            switch viewModel {
                
            case .hashtag(let viewModel):
                self.displayDoHashtagChannel(viewModel)
            case .hashtagError(message: let message):
                self.displayDoHashtagChannelError(message)
            }
        }
    }
}


// MARK: - ChannelSearchHashtagViewDelegate
extension ChannelSearchHashtagController: UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let items = self.interactor.dataSource.data else {
            return 0
        }
        
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ChannelSearchHashtagItemCell.self, for: indexPath)
        
        guard let items = self.interactor.dataSource.data else {
            return cell
        }
        
        cell.item = items[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width - 32, height: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(all: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let item = self.interactor.dataSource.data, let tag = item[indexPath.row].name else {
            return
        }
        
        router.routeTo(.showHashtag(tag))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { return 20 }
}


// MARK: - Private Zone
private extension ChannelSearchHashtagController {
    
    func displayDoHashtagChannel(_ viewModel: [Hashtag]) {
        self.interactor.dataSource.data = viewModel
        DispatchQueue.main.async {
            self.mainView.collectionView.backgroundView = viewModel.isEmpty ? self.mainView.emptyView(self.interactor.dataSource.text) : nil
            self.mainView.collectionView.reloadData()
        }
    }
    
    func displayDoHashtagChannelError(_ message: String) {
        self.interactor.dataSource.data = nil
        DispatchQueue.main.async {
            self.mainView.collectionView.backgroundView = self.mainView.emptyView(self.interactor.dataSource.text)
            self.mainView.collectionView.reloadData()
        }
    }
}
