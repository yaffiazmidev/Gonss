//
//  PostPreviewMediaController.swift
//  Persada
//
//  Created by movan on 10/07/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import AVKit
import KipasKipasShared

protocol PostPreviewMediaDisplayLogic where Self: UIViewController {
	
	func displayViewModel(_ viewModel: PostPreviewMediaModel.ViewModel)
}

final class PostPreviewMediaController: UIViewController, Displayable, PostPreviewMediaDisplayLogic {
	
	private var mainView: PostPreviewMediaView
	private var interactor: PostPreviewMediaInteractable!
	private var router: PostPreviewMediaRouting!
    var sourceController: PostControllerType?
	
	init(mainView: PostPreviewMediaView, dataSource: PostPreviewMediaModel.DataSource) {
		self.mainView = mainView
		
		super.init(nibName: nil, bundle: nil)
		interactor = PostPreviewMediaInteractor(viewController: self, dataSource: dataSource)
		router = PostPreviewMediaRouter(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		//interactor.doSomething(item: 22)
	}
	
	override func loadView() {
		view = mainView
        mainView.medias = self.interactor.dataSource.itemMedias
		let numberPage = self.interactor.dataSource.itemMedias.count
		mainView.pageControl.numberOfPages = numberPage
		mainView.delegate = self
	}
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let index = IndexPath(item: mainView.index, section: 0)
        self.mainView.collectionView.scrollToItem(at: index, at: .left, animated: false)
        self.mainView.pageControl.currentPage = mainView.index
        self.mainView.collectionView.isHidden = false
    }
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
	}
	
	
	// MARK: - PostPreviewMediaDisplayLogic
	func displayViewModel(_ viewModel: PostPreviewMediaModel.ViewModel) {
		DispatchQueue.main.async {
			switch viewModel {
				
			case .doSomething(let viewModel):
				self.displayDoSomething(viewModel)
			}
		}
	}
}


// MARK: - PostPreviewMediaViewDelegate
extension PostPreviewMediaController: PostPreviewMediaViewDelegate {
	func removeMedia(_ index: Int) {
		let title = "Hapus Foto"
		let subtitle = "Anda yakin untuk menghapus foto ini?"
        let action = UIAlertAction(title: .get(.deletePost), style: .default) { _ in
            self.removePhoto(index)
        }
		let cancel = UIAlertAction(title: .get(.back), style: .cancel)

		let alertController = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)

		alertController.addAction(action)
		alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
	}

    private func removePhoto(_ index: Int) {
        let index = mainView.index
        if !self.mainView.medias.indices.contains(index) { return }
        self.mainView.removeImage(index)
        if let sourceController = self.sourceController {
            if self.mainView.medias.isEmpty {
                self.dismiss(animated: true) { sourceController.reloadMediaCollectionView(self.mainView.medias) }
            } else {
                sourceController.reloadMediaCollectionView(mainView.medias)
            }
        }
    }
	
	func changeMedia(_ index: Int) {
		let index = mainView.index
        showPicker(index)
	}

    func showPicker(_ index: Int) {
        let vc = KKCameraViewController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
        vc.handleMediaSelected = { [weak self] (item) in
            guard let self = self else { return }
            self.mainView.medias[index] = item
            self.mainView.collectionView.reloadData()
            if let sourceController = self.sourceController {
                sourceController.reloadMediaCollectionView(self.mainView.medias)
            }
        }
    }
}


// MARK: - Private Zone
private extension PostPreviewMediaController {
	
	func displayDoSomething(_ viewModel: NSObject) {

	}
}
