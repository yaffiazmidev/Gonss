//
//  ProductPresenter.swift
//  Persada
//
//  Created by NOOR on 30/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import Foundation
import RxSwift
import RxCocoa
import KipasKipasShared
import KipasKipasNetworking
import KipasKipasNetworkingUtils

protocol ProductPresentationLogic {
	func presentResponse(_ response: ProductModel.Response)
}

final class ProductPresenter: Presentable {
	private weak var viewController: ProductDisplayLogic?
	private let disposeBag = DisposeBag()
	private let usecase: ProductUseCase
	private let addressUsecase: AddressUseCase
	let _errorMessage = BehaviorRelay<String?>(value: nil)
    
	let productsDataSource: BehaviorRelay<[Product]> = BehaviorRelay<[Product]>(value: [])
	let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)

	var lastPage: Int = 0
	var requestedPage: Int = 0
	var counterProduct: Int = 0
	var isDataEmpty: Bool = false
    var indexProduct: Int = 0
    
    private let uploader: MediaUploader
	let _loadingState = BehaviorRelay<Bool>(value: false)
	var loadingState: Driver<Bool> {
		return _loadingState.asDriver()
	}

    //lazy var products: Driver<[Product]> = {
    //return self.getProducts()
    //}()
	
	init(_ viewController: ProductDisplayLogic?) {
        self.uploader = MainQueueDispatchDecorator(decoratee: MediaUploadManager())
		self.viewController = viewController
		self.usecase = Injection.init().provideProductUseCase()
		self.addressUsecase = Injection.init().provideAddressUseCase()
	}

    //private func getProducts() -> Driver<[Product]> {
    //return usecase.getProduct(productPageEnum: .products)
    //.subscribeOn(self.concurrentBackground)
    //.observeOn(MainScheduler.instance)
    //.map { product in
    //self.productsDataSource.accept(product)
    //self.counterProduct = product.count
    //return product
    //}.asDriver { error in
    //return Driver.empty()
    //}
    //}
    
    func removeProductMedia(productID: String, mediaID: String, onSuccess: @escaping () -> (), onRejected: @escaping () -> (), onError: @escaping (String) -> ()) {
        usecase.removeProductMedia(productID: productID, mediaID: mediaID)
            .subscribeOn(self.concurrentBackground)
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] result in
                guard let self = self else { return }
                
                self._loadingState.accept(false)
                if result.code == "1000" {
                    onSuccess()
                } else if let _ = result.message?.contains("rejected") {
                    onRejected()
                } else if let message = result.message {
                    onError(message)
                }
            } onError: { error in
                self._loadingState.accept(false)
                self._errorMessage.accept(error.localizedDescription)
                onError(error.localizedDescription)
            } onCompleted: {
            }.disposed(by: disposeBag)
    }
    
    func archiveProduct(productID : String, archive: Bool, onSuccessArchive: @escaping ()->()){
        usecase.activeSearchProducts(archive, id: productID)
            .subscribe(onNext: { (result) in
                onSuccessArchive()
            }, onError: { (error) in
                self._errorMessage.accept(error.localizedDescription)
            }).disposed(by: disposeBag)
    }
    
    func deleteProduct(productID : String, onSuccessDelete: @escaping ()->()){
        usecase.detailProduct(id: productID)
            .subscribe(onNext: { (result) in
                onSuccessDelete()
            }, onError: { (error) in
                self._errorMessage.accept(error.localizedDescription)
            }).disposed(by: disposeBag)
    }
	
	func getNetworkProduct() {
		_loadingState.accept(true)
		usecase.getNetworkProducts(page: requestedPage)
			.subscribeOn(self.concurrentBackground)
			.observeOn(MainScheduler.instance)
			.subscribe { [weak self] result in
				guard let self = self else { return }
				
				self._loadingState.accept(false)
				if result.code == "1000" {
					if self.requestedPage == 0 {
                        self.presentResponse(.products(result))
					} else {
                        self.presentResponse(.paginationProduct(result))
					}
					self.requestedPage += 1
				}
			} onError: { error in
				self._errorMessage.accept(error.localizedDescription)
			} onCompleted: {
			}.disposed(by: disposeBag)
	}
	
	func searchProducts(searchingText: String) {
		_loadingState.accept(true)
		usecase.searchProducts(text: searchingText)
			.subscribeOn(self.concurrentBackground)
			.observeOn(MainScheduler.instance)
			.subscribe { result in
				self._loadingState.accept(false)
                
                guard result.data?.content?.count != 0 else {
                    self.presentResponse(.emptySearchProduct)
                    return
                }
                
                if self.requestedPage == 0 || self.requestedPage == 1 {
                    self.presentResponse(.products(result))
                } else {
                    self.presentResponse(.paginationProduct(result))
                }
			} onError: { error in
				self._errorMessage.accept(error.localizedDescription)
			} onCompleted: {
			}.disposed(by: disposeBag)
	}
	
	private func saveProduct(productsNetwork: [Product], page: Int, currentData: [Product]? = nil) {
        if requestedPage == 0 || requestedPage == 1 {
            viewController?.displayViewModel(.product(viewModel: currentData ?? []))
        } else {
            viewController?.displayViewModel(.paginationProduct(viewModel: productsNetwork))
        }
	}
	
	func requestCheckAddress() {
		addressUsecase.getAddress(type: "BUYER_ADDRESS")
			.subscribeOn(self.concurrentBackground)
			.observeOn(MainScheduler.instance)
			.subscribe { address in
				self.viewController?.displayViewModel(.checkTheAddress(address: address.data ?? []))
			} onError: { error in
				self._errorMessage.accept(error.localizedDescription)
			} onCompleted: {
			}.disposed(by: disposeBag)
	}
    
    func editProduct(_ inProduct: Product) {
        _loadingState.accept(true)
        print("PRODUKNYA \(inProduct)")
        usecase.editProduct(inProduct)
            .subscribeOn(self.concurrentBackground)
            .observeOn(MainScheduler.instance)
            .subscribe { result in
                self._loadingState.accept(false)
                if result.code == "1000" {
                    self.presentResponse(.editProduct)
                }
            } onError: { error in
                self._loadingState.accept(false)
                if let error = error as? ErrorMessage {
                    self._errorMessage.accept(error.statusMessage)
                }
                self._errorMessage.accept(error.localizedDescription)
            } onCompleted: {
            }.disposed(by: disposeBag)
    }
    
    func addProduct(_ product: Product){
        _loadingState.accept(true)
        
        usecase.addProduct(product: product)
                .subscribeOn(self.concurrentBackground)
                .observeOn(MainScheduler.instance)
                .subscribe { result in
                    self._loadingState.accept(false)
                    if result.code == "1002" {
                        self.presentResponse(.addProduct)
                    }
                } onError: { error in
                    self._loadingState.accept(false)
                    if let error = error as? ErrorMessage {
                        self._errorMessage.accept(error.statusMessage)
                    }
                    self._errorMessage.accept(error.localizedDescription)
                } onCompleted: {
                }.disposed(by: disposeBag)
    }
    
    func uploadImage(_ image: KKMediaItem){
        
        if ReachabilityNetwork.isConnectedToNetwork() {
            
            guard let data = image.data, let uiImage = UIImage(data: data), let ext = image.path.split(separator: ".").last else {
                self._errorMessage.accept("Failed to Upload")
                return
            }
            
            let request = MediaUploaderRequest(media: data, ext: "\(ext)")
            uploader.upload(request: request) { [weak self] (result) in
                guard let self = self else { return }
                switch result{
                case .success(let response):
                    
                    let media = Medias(
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
                    self.presentResponse(.responseMedia([media]))
                    return
                    
                case .failure(let error):
                    self._errorMessage.accept(error.getErrorMessage())
                    return
                }
            }
        } else {
            self._errorMessage.accept("No Internet Connection")
            return
        }
    }
    
    func uploadVideo(_ video: KKMediaItem){
        uploadVideoThumbnail(thumbnail: video.videoThumbnail) { [weak self] (thumbnail, metadata) in
            guard let self = self else { return }
            self.uploadVideoFeedData(video: video) { [weak self] (video) in
                
                guard let self = self else { return }
                let media = Medias(
                    id: nil,
                    type: "video",
                    url: video.tmpUrl,
                    thumbnail: thumbnail,
                    metadata: metadata,
                    vodFileId: video.vod?.id,
                    vodUrl: video.vod?.url
                )
                self.presentResponse(.responseMedia([media]))
                
            }
        }
    }
    
    
    private func uploadVideoThumbnail(thumbnail: UIImage?, mediaCallback: @escaping (Thumbnail, Metadata)->()){
        
        if ReachabilityNetwork.isConnectedToNetwork() {
            
            guard let data = thumbnail?.pngData(), let image = thumbnail else {
                self._errorMessage.accept("Failed to Upload")
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
                    self._errorMessage.accept(error.getErrorMessage())
                    return
                }
                
            }
            
        }else{
            self._errorMessage.accept("No Internet Connection")
            return
        }
    }
    
    private func uploadVideoFeedData(video: KKMediaItem, mediaCallback: @escaping (MediaUploaderResult)->()){
        
        if ReachabilityNetwork.isConnectedToNetwork() {
            guard let data = video.data, let ext = video.path.split(separator: ".").last else {
                self._errorMessage.accept("Failed to Upload")
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
                    self._errorMessage.accept(error.getErrorMessage())
                    return
                }
                
            }
            
        }else{
            self._errorMessage.accept("No Internet Connection")
            return
        }
    }
    
    
    func deleteMedia(by idProduct: String, id: String) {
        _loadingState.accept(true)
        usecase.deleteMedia(by: idProduct, id: id)
            .subscribeOn(self.concurrentBackground)
            .observeOn(MainScheduler.instance)
            .subscribe { result in
                self._loadingState.accept(false)
                if result.code == "1000" {
                    self.presentResponse(.deletMedia)
                }
            } onError: { error in
                self._errorMessage.accept(error.localizedDescription)
            } onCompleted: {
            }.disposed(by: disposeBag)
    }
}


// MARK: - ProductPresentationLogic
extension ProductPresenter: ProductPresentationLogic {
	func presentResponse(_ response: ProductModel.Response) {
		switch response {
        case .products(let result):
            presentingProduct(result)
        case .paginationProduct(let result):
            presentingPaginationProduct(result)
        case .presentErrorResponse(data: let data):
            presentingError(err: data)
        case .emptySearchProduct:
            presentingEmptySearch()
        case .editProduct:
            presentingProductDetail()
        case .responseMedia(let media):
            presentingMedia(media)
        case .deletMedia:
            presentingDeleteMedia()
        case .addProduct:
            viewController?.displayViewModel(.addProduct)
        }
	}
}


// MARK: - Private Zone
private extension ProductPresenter {
	
	func presentingProduct(_ result: ProductResult) {
		
		guard let validData = result.data?.content else {
			return
		}
		
		viewController?.displayViewModel(.product(viewModel: validData))
	}
	
	func presentingPaginationProduct(_ result: ProductResult) {
		
		guard let validData = result.data?.content else {
			return
		}
		
		viewController?.displayViewModel(.paginationProduct(viewModel: validData))
	}

	func presentingProductByIdPagination(_ result: ProductResultById) {
		guard let validData = result.data else {
			return
		}

		viewController?.displayViewModel(.listProductById(viewModel: validData))
	}

	func presentingError(err: ErrorMessage){
		viewController?.displayViewModel(.presentErrorResponse(data: err))
	}
    
    func presentingEmptySearch() {
        viewController?.displayViewModel(.emptySearchProduct)
    }
    
    func presentingProductDetail() {
        viewController?.displayViewModel(.productDetail)
    }
    
    func presentingMedia(_ media: [Medias]) {
        viewController?.displayViewModel(.media(viewModel: media))
    }
    
    func presentingDeleteMedia() {
        //navigationController?.popViewController(animated: false)
        //viewController?.navigationController?.popViewController(animated: false)
        viewController?.displayViewModel(.deleteMedia)
    }
}
