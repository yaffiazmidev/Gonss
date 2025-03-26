//
//  EditMediaController.swift
//  KipasKipas
//
//  Created by Ibrohim Dasuqi on 27/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import KipasKipasShared
import KipasKipasNetworking
import KipasKipasNetworkingUtils

final class EditMediaController: UIViewController, ProductDisplayLogic, AlertDisplayer {
    private var mainView: EidtMediaView
    private var dataSource: Product
    var index: Int = 0
    private var presenter: ProductPresenter!
    var sourceController: UIViewController?
    private let disposeBag = DisposeBag()
    private let hud = CPKProgressHUD.progressHUD(style: .loading(text: nil))
    
    let uploader: MediaUploader
    lazy var imagePickerController: KKCameraViewController = {
        let vc = KKCameraViewController()
        vc.modalPresentationStyle = .fullScreen
        return vc
    }()
    
    init(mainView: EidtMediaView, dataSource: Product) {
        self.mainView = mainView
        self.dataSource = dataSource
        self.uploader = MainQueueDispatchDecorator(decoratee: MediaUploadManager())
        super.init(nibName: nil, bundle: nil)
        self.presenter = ProductPresenter(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        KKLogFile.instance.log(label:"EditMediaController", message: "open")

        presenter._loadingState.bind { [weak self] loading in
            if loading {
                DispatchQueue.main.async {
                    guard let view = self?.view else { return }
                    
                    self?.hud.show(in: view)
                    return
                }
                
            } else {
                self?.hud.dismiss()
            }
        }.disposed(by: disposeBag)
    }
    
    override func loadView() {
        view = mainView
        mainView.images = self.dataSource.medias!
        let numberPage = self.dataSource.medias!.count
        mainView.pageControl.numberOfPages = numberPage
        mainView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let index = IndexPath(item: index, section: 0)
        self.mainView.collectionView.scrollToItem(at: index, at: .left, animated: true)
        self.mainView.pageControl.currentPage = self.index
        self.mainView.index = self.index
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
    }
}

// MARK: - PostPreviewMediaViewDelegate
extension EditMediaController: EidtMediaViewDelegate {
    func removeMedia(_ index: Int) {
        if mainView.images.count == 1 {
            self.displayAlert(with: .get(.media), message: .get(.fotoVideoMinimalSatu), actions: [UIAlertAction(title: .get(.close), style: .default, handler: nil)])
        } else {
            
            let action = UIAlertAction(title: .get(.deletePost), style: .default) { _ in
                self.removePhoto(index)
            }
            let cancel = UIAlertAction(title: .get(.back), style: .cancel)
            
            self.displayAlert(with: .get(.hapusFoto), message: .get(.subtitleHapusFoto), actions: [action, cancel])
        }
        
    }
    
    private func removePhoto(_ index: Int) {
        self.presenter._loadingState.accept(true)
        let media = mainView.images[index]
        self.removeMediaLocal(index: index, media: media)
    }
    
    private func removeMediaChange(item: KKMediaItem,_ index: Int) {
        self.presenter._loadingState.accept(true)
        let media = mainView.images[index]
        presenter.removeProductMedia(productID: dataSource.id ?? "", mediaID: media.id ?? "") {
            switch item.type {
            case .photo:
                self.presenter._loadingState.accept(true)
                self.uploadImage(item, index: index)
            case .video:
                self.presenter._loadingState.accept(true)
                self.uploadVideo(item, index: index)
            }
        } onRejected: {
            self.presenter._loadingState.accept(false)
            self.displayAlert(with: .get(.error), message: "Unknown Error", actions: [UIAlertAction(title: .get(.ok), style: .default, handler: nil)])
        } onError: { error in
            self.displayAlert(with: .get(.error), message: error, actions: [UIAlertAction(title: .get(.ok), style: .default, handler: nil)])
        }
        
        
    }
    
    
    private func removeMediaLocal(index : Int, media: Medias){
        self.presenter._loadingState.accept(false)
        self.index = index
        if !self.mainView.images.indices.contains(index) { return }
        
        if let editProductController = self.sourceController as? EditProductController {
            editProductController.setChangedRemovedID(productID: dataSource.id ?? "", mediaID: media.id ?? "")
            self.mainView.removeImage(index)
            editProductController.reloadMediaCollectionView(self.mainView.images)
        }
        
        if self.mainView.images.isEmpty {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func changeMedia(_ index: Int) {
        showPicker(index)
    }
    
    
    func showPicker(_ index: Int) {
        self.present(imagePickerController, animated: true)
        imagePickerController.handleMediaSelected = { [weak self] (media) in
            guard let self = self else { return }
            self.presenter._loadingState.accept(true)
                        
            KKLogFile.instance.log(label:"EditMediaController", message: "showPicker handleMediaSelected")
            
            DispatchQueue.global(qos: .background).async {
                switch media.type {
                case .photo:
                    self.uploadImage(media, index: index)
                case .video:
                    self.uploadVideo(media, index: index)
                }
            }
            
            self.mainView.collectionView.reloadData()
        }
    }
    
    // MARK: - ProductDisplayLogic
    func displayViewModel(_ viewModel: ProductModel.ViewModel) {
        switch viewModel {
        case .deleteMedia:
            if !self.mainView.images.indices.contains(index) { return }
            self.mainView.removeImage(index)
            
            if let editProductController = self.sourceController as? EditProductController {
                editProductController.reloadMediaCollectionView(mainView.images)
            }
            if self.mainView.images.isEmpty {
                self.dismiss(animated: true, completion: nil)
            }
        default:
            break
        }
        
    }
    
}


extension EditMediaController {
    func uploadImage(_ item: KKMediaItem, index : Int){
        self.presenter._loadingState.accept(true)
        
        if ReachabilityNetwork.isConnectedToNetwork() {
            
            guard let data = item.data, let uiImage = UIImage(data: data), let ext = item.path.split(separator: ".").last else {
                self.presenter._loadingState.accept(false)
                self.displayAlert(with: .get(.error), message: "Failed to Upload", actions: [UIAlertAction(title: .get(.ok), style: .default, handler: nil)])
                return
            }
            
            let request = MediaUploaderRequest(media: data, ext: "\(ext)")
            uploader.upload(request: request) { [weak self] (result) in
                guard let self = self else { return }
                self.presenter._loadingState.accept(false)
                
                switch result{
                case .success(let response):
                    
                    let media = ResponseMedia(
                        id: nil,
                        type: "image",
                        url: response.tmpUrl,
                        thumbnail: Thumbnail(large: response.url, medium: response.url, small: response.url),
                        metadata: Metadata(
                            width: "\(uiImage.size.width * uiImage.scale)",
                            height: "\(uiImage.size.height * uiImage.scale)",
                            size: "0"
                        )
                    )
                    
                    let mediasResponse = media.toMedias()
                    let mediaID = self.mainView.images[index].id ?? ""
                    self.mainView.replaceImage(index, media: mediasResponse)
                    if let editProductController = self.sourceController as? EditProductController {
                        editProductController.setChangedRemovedID(productID: self.dataSource.id ?? "", mediaID: mediaID)
                        editProductController.reloadMediaCollectionView(self.mainView.images)
                    }
                    
                    return
                    
                case .failure(let error):
                    self.handleError(error)
                    return
                }
            }
        } else {
            self.presenter._loadingState.accept(false)
            self.displayAlert(with: .get(.error), message: "No Internet Connection", actions: [UIAlertAction(title: .get(.ok), style: .default, handler: nil)])
            return
        }
    }
    
    private func uploadVideo(_ item: KKMediaItem, index: Int) {
        
        KKLogFile.instance.log(label:"EditMediaController", message: "uploadVideo will uploadVideoThumbnail")
        
        uploadVideoThumbnail(item) { [weak self] (thumbnail, metadata) in
            KKLogFile.instance.log(label:"EditMediaController", message: "uploadVideo will uploadVideoData")
            
            self?.uploadVideoData(item, mediaCallback: { [weak self] (video) in
                guard let self = self else { return }
                self.presenter._loadingState.accept(false)
                
                let media = ResponseMedia(
                    id: nil,
                    type: "video",
                    url: video.tmpUrl,
                    thumbnail: thumbnail,
                    metadata: metadata,
                    vodFileId: video.vod?.id,
                    vodUrl: video.vod?.url
                )
                
                let mediasResponse = media.toMedias()
                self.mainView.replaceImage(index, media: mediasResponse)
                if let editProductController = self.sourceController as? EditProductController {
                    editProductController.reloadMediaCollectionView(self.mainView.images)
                }
            })
        }
    }
    
    private func uploadVideoThumbnail(_ item: KKMediaItem, mediaCallback: @escaping (Thumbnail, Metadata)->()){
        if ReachabilityNetwork.isConnectedToNetwork() {
            
            guard let data = item.videoThumbnail?.pngData(), let image = item.videoThumbnail else {
                self.presenter._loadingState.accept(false)
                self.displayAlert(with: .get(.error), message: "Failed to Upload", actions: [UIAlertAction(title: .get(.ok), style: .default, handler: nil)])
                return
            }
            
            let request = MediaUploaderRequest(media: data, ext: "jpeg")
            uploader.upload(request: request) { [weak self] (result) in
                
                guard let self = self else { return }
                
                switch result{
                case .success(let response):
                    
                    let thumbnail = Thumbnail(
                        large: response.tmpUrl,
                        medium: response.url,
                        small: response.url
                    )
                    
                    let metadata = Metadata(
                        width: "\(image.size.width * image.scale)",
                        height: "\(image.size.height * image.scale)",
                        size: "0"
                    )
                    
                    mediaCallback(thumbnail, metadata)
                    return
                    
                case .failure(let error):
                    self.presenter._loadingState.accept(false)
                    self.handleError(error)
                    return
                }
                
            }
            
        }else{
            self.presenter._loadingState.accept(false)
            self.displayAlert(with: .get(.error), message: "No Internet Connection", actions: [UIAlertAction(title: .get(.ok), style: .default, handler: nil)])
            return
        }
    }
    
    private func uploadVideoData(_ item: KKMediaItem, mediaCallback: @escaping (MediaUploaderResult)->()){
        if ReachabilityNetwork.isConnectedToNetwork() {
            guard let data = item.data, let ext = item.path.split(separator: ".").last else {
                self.displayAlert(with: .get(.error), message: "Failed to Upload", actions: [UIAlertAction(title: .get(.ok), style: .default, handler: nil)])
                return
            }
            
            let request = MediaUploaderRequest(media: data, ext: "\(ext)")
            uploader.upload(request: request) { [weak self] (result) in
                
                guard let self = self else { return }
                
                switch(result){
                case .success(let response):
                    mediaCallback(response)
                    return
                    
                case .failure(let error):
                    self.presenter._loadingState.accept(false)
                    self.handleError(error)
                    return
                }
                
            }
            
        }else{
            self.presenter._loadingState.accept(false)
            self.displayAlert(with: .get(.error), message: "No Internet Connection", actions: [UIAlertAction(title: .get(.ok), style: .default, handler: nil)])
            return
        }
    }
    
    private func handleError(_ error: Error){
        self.displayAlert(with: .get(.error), message: error.getErrorMessage(), actions: [UIAlertAction(title: .get(.ok), style: .default, handler: nil)])
    }
}
