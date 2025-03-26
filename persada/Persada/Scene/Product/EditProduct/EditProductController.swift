//
//  EditProductController.swift
//  KipasKipas
//
//  Created by Ibrohim Dasuqi on 20/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import AVKit
import KipasKipasShared
import KipasKipasNetworking
import KipasKipasNetworkingUtils

protocol EditProductDelegate {
    func setCategory(category: CategoryShopItem)
}

class EditProductController: UIViewController, ProductDisplayLogic, AlertDisplayer {
    
    private let network = UploadNetworkModel()
    private let mainView: EditProductView
    var isProduct: Product?
    var isArchive = false
    var medias: [KKMediaItem] = []
    var responseMedia: [ResponseMedia] = []
    var productPresenter: ProductPresenter!
    private let disposeBag = DisposeBag()
    private var isAdd = false
    private let inActive = "INACTIVE"
    var indexProduct: Int = 0
    lazy var imagePickerController: KKCameraViewController = {
        let vc = KKCameraViewController()
        vc.modalPresentationStyle = .fullScreen
        return vc
    }()
    private let hud = CPKProgressHUD.progressHUD(style: .loading(text: nil))
    
    var onSuccessAddProduct : () -> () = { }
    private var removedMediaID: [String] = []
    private var productID = ""
    private let uploader: MediaUploader = MainQueueDispatchDecorator(decoratee: MediaUploadManager())
    
    required init(mainView: EditProductView, dataSource: Product?, isAdd : Bool = false) {
        self.mainView = mainView
        self.isProduct = dataSource
        //        if let media = dataSource?.medias {
        //            for i in media {
        //                responseMedia.append(ResponseMedia(id: i.id, type: i.type, url: i.url, thumbnail: i.thumbnail, metadata: i.metadata))
        //
        //            }
        //        }
        self.isAdd = isAdd
        super.init(nibName: nil, bundle: nil)
        self.productPresenter = ProductPresenter(self)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.hideKeyboardWhenTappedAround()
        
        let title = isAdd ? .get(.addProduct) : String.get(.simpanPerubahan)
        let rightBarButton = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(onClickSave(_:)))
        rightBarButton.isEnabled = isAdd ? false : true
        rightBarButton.tintColor = .primary
        rightBarButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.Roboto(.medium, size: 14)],
                                              for: .normal)
        self.navigationItem.rightBarButtonItem = rightBarButton
        configure()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bindNavigationBar("")
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func loadView() {
        view = mainView
        view.backgroundColor = .white
    }
    
    private func configure() {
        
        mainView.handleTapCategoryProduct = { [weak self] in
            guard let self = self else { return }
            self.routeToCategoryProduct()
        }
        
        mainView.handleInfo = {
            self.displayAlert(with: .get(.weightInfo), message: .get(.weightTermCondition), actions: [UIAlertAction(title: .get(.ok), style: .default, handler: nil)])
        }
        
        [mainView.nameItemView, mainView.priceItemView, mainView.stockItemView, mainView.lengthItemView, mainView.widthItemView, mainView.weightItemView, mainView.highItemView].forEach { textField in
            textField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingDidEnd)
        }
        
        self.mainView.priceItemView.rx.controlEvent(.editingDidEnd)
            .asObservable()
            .withLatestFrom(self.mainView.priceItemView.rx.text.orEmpty)
            .subscribe(onNext:{ [weak self] (text) in
                self?.mainView.priceItemView.text = text.digits().toMoney()
                self?.enableRightBarButton()
            })
            .disposed(by: disposeBag)
        
        self.mainView.nameItemView.rx.controlEvent(.editingDidEnd)
            .asObservable()
            .withLatestFrom(self.mainView.nameItemView.rx.text.orEmpty)
            .subscribe(onNext:{ [weak self] (text) in
                self?.mainView.labelLengthNameProduct.text = "\(text.count)/70"
                self?.enableRightBarButton()
            })
            .disposed(by: disposeBag)
        
        self.mainView.weightItemView.rx.controlEvent(.editingDidEnd)
            .asObservable()
            .withLatestFrom(self.mainView.weightItemView.rx.text.orEmpty)
            .subscribe(onNext: { [weak self] weightValue in
                self?.enableRightBarButton()
            })
            .disposed(by: disposeBag)
        
        self.mainView.stockItemView.rx.controlEvent(.editingDidEnd)
            .asObservable()
            .withLatestFrom(self.mainView.stockItemView.rx.text.orEmpty)
            .subscribe(onNext:{ [weak self] (text) in
                self?.mainView.stockItemView.text = text
                self?.enableRightBarButton()
            })
            .disposed(by: disposeBag)
        
        self.mainView.captionCTV.nameTextField.rx.didChange
            .asObservable()
            .withLatestFrom(self.mainView.captionCTV.nameTextField.rx.text.orEmpty)
            .subscribe(onNext:{ [weak self] (text) in
                guard let count = self?.mainView.captionCTV.nameTextField.text.count else { return }
                self?.mainView.labelLengthDescriptionProduct.text = "\(count)/1000"
                if text.count == 1 {
                    if text.first == " " {
                        self?.mainView.captionCTV.nameTextField.text = ""
                        return
                    }
                }
                self?.enableRightBarButton()
            })
            .disposed(by: disposeBag)
        
        productPresenter._loadingState.bind { [weak self] loading in
            if loading {
                guard let view = self?.view else { return }
                self?.hud.show(in: view)
                return
            } else {
                self?.hud.dismiss()
            }
        }.disposed(by: disposeBag)
        
        productPresenter._errorMessage.bind {  [weak self] error in
            guard let error = error else { return }
            let action = UIAlertAction(title: "OK", style: .default)
            self?.displayAlert(with: "Error", message: error,actions: [action])
            
            self?.navigationItem.rightBarButtonItem?.isEnabled = true
        }.disposed(by: disposeBag)
        
        mainView.collectionView.delegate = self
        mainView.collectionView.dataSource = self
        
        guard let _ = self.isProduct?.id else { return }
        guard let product = self.isProduct else { return }
        let mea = product.measurement!
        
        let whenAlreadySelectCategoryProductName = isProduct?.categoryId != nil && isProduct?.categoryName != nil
        mainView.categoryProductButtonSelectView.name.text = whenAlreadySelectCategoryProductName ? isProduct?.categoryName : "Kategori"
        
        mainView.nameItemView.text = product.name
        mainView.priceItemView.text = "Rp " + String(Int(product.price!))
        if mainView.stockItemView.text.isNilOrEmpty {
            mainView.stockItemView.text = "\(product.stock ?? 0)"
        }
        mainView.captionCTV.nameTextField.text = product.postProductDescription!
        mainView.captionCTV.placeholderLabel.isHidden = true
        mainView.lengthItemView.text = "\(mea.length!) cm"
        mainView.widthItemView.text = "\(mea.width!) cm"
        mainView.highItemView.text = "\(mea.height!) cm"
        mainView.weightItemView.text = "\(mea.weight!) kg"
        mainView.labelLengthNameProduct.text = "\(product.name!.count)/70"
        mainView.labelLengthDescriptionProduct.text = "\(product.postProductDescription!.count)/1000"
    }
    
    @objc
    func editingChanged(_ textField: UITextField) {
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
        
        
        enableRightBarButton()
    }
    
    func enableRightBarButton() {
        var isValidLength: Bool = true
        var isValidWidth: Bool = true
        var isValidHeight: Bool = true
        var isValidWeight: Bool = false
        
        mainView.lengthItemView.setBorderColor = .whiteSmoke
        mainView.widthItemView.setBorderColor = .whiteSmoke
        mainView.highItemView.setBorderColor = .whiteSmoke
        
        if let length = mainView.lengthItemView.text, !(length.isEmpty) && length.first == "0" {
            mainView.lengthItemView.setBorderColor = .warning
            isValidLength = false
        }
        
        if let width = mainView.widthItemView.text, !(width.isEmpty) && width.first == "0" {
            mainView.widthItemView.setBorderColor = .warning
            isValidWidth = false
        }
        
        if let height = mainView.highItemView.text, !(height.isEmpty) && height.first == "0" {
            mainView.highItemView.setBorderColor = .warning
            isValidHeight = false
        }
        
        if (mainView.weightItemView.text?.isEmpty == false) {
            let weight = (mainView.weightItemView.text ?? "0").replacingOccurrences(of: ",", with: ".")
            
            var weightDouble : Double = 0.0
            if weight.containsIgnoringCase(find: "Kg") {
                weightDouble = deleteUnitKg(weight)
            } else {
                weightDouble = Double(weight) ?? 0.0
            }
            
            if weightDouble < Double(0.1) {
                mainView.labelWeightError.text = .get(.minimalBerat01)
                mainView.labelWeightError.isHidden = false
                isValidWeight = false
            } else {
                isValidWeight = true
                mainView.labelWeightError.isHidden = true
            }
            
            if weightDouble > Double(50) {
                mainView.labelWeightError.text = .get(.maksimalBerat50)
                mainView.labelWeightError.isHidden = false
                isValidWeight = false
            }
        }
        
        let isValidDimention = isValidLength && isValidWidth && isValidHeight
        navigationItem.rightBarButtonItem?.isEnabled = isValidWeight && isValidDimention
        
        if isAdd {
            let mediasItem : [KKMediaItem]? = medias
            guard
                let name = mainView.nameItemView.text, !name.isEmpty,
                let categoryProductId = isProduct?.categoryId, !categoryProductId.isEmpty,
                let price = mainView.priceItemView.text, !price.isEmpty && price.prefix(4) != "Rp 0",
                let stock = mainView.stockItemView.text, !stock.isEmpty && stock != "0",
                let length = mainView.lengthItemView.text, !length.isEmpty && length != "0",
                let width = mainView.widthItemView.text, !width.isEmpty && width != "0",
                let height = mainView.highItemView.text, !height.isEmpty && height != "0",
                let weight = mainView.weightItemView.text, !weight.isEmpty,
                let count = mediasItem, !count.isEmpty
            else {
                navigationItem.rightBarButtonItem?.isEnabled = false
                return
            }
        } else {
            guard
                let name = mainView.nameItemView.text, !name.isEmpty,
                let categoryProductId = isProduct?.categoryId, !categoryProductId.isEmpty,
                let price = mainView.priceItemView.text, !price.isEmpty && price.prefix(1) != "0", price != "Rp 0",
                let stock = mainView.stockItemView.text, !stock.isEmpty && stock != "0",
                let length = mainView.lengthItemView.text, !length.isEmpty && length != "0",
                let width = mainView.widthItemView.text, !width.isEmpty && width != "0",
                let height = mainView.highItemView.text, !height.isEmpty && height != "0",
                let weight = mainView.weightItemView.text, !weight.isEmpty,
                let count = isProduct?.medias, !count.isEmpty
            else {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                return
            }
        }
    }
    // MARK: - ProductDisplayLogic
    func displayViewModel(_ viewModel: ProductModel.ViewModel) {
        switch viewModel {
        case .productDetail:
            routeToDetail(product: isProduct!)
        case .addProduct:
            self.displayAlertSuccessAddProduct()
        case .media(let viewModel):
            self.productPresenter._loadingState.accept(false)
            if self.isProduct?.medias == nil {
                self.isProduct?.medias = viewModel
                self.mainView.collectionView.reloadData()
                self.enableRightBarButton()
                return
            }
            self.isProduct?.medias?.append(contentsOf: viewModel)
            self.mainView.collectionView.reloadData()
            self.enableRightBarButton()
        default:
            break
        }
        
    }
    
    func displayAlertSuccessAddProduct(){
        let action = UIAlertAction(title: .get(.ok), style: .default, handler: { alert in
            self.onSuccessAddProduct()
            self.navigationController?.popViewController(animated: true)
        })
        self.displayAlert(with: .get(.berhasil), message: .get(.productAddDesc), actions: [action])
    }
    
    @objc func onClickSave(_ sender: UIBarButtonItem) {
        if isAdd {
            postProduct()
        } else {
            removeChangedPhoto { [weak self] in
                self?.createParam()
            }
        }
    }
    
    private func removeChangedPhoto(completion: @escaping () -> ()) {
        self.productPresenter._loadingState.accept(true)
        if removedMediaID.isEmpty {
            completion()
            return
        }
        self.removedMediaID.forEach { [weak self] id in
            guard let self = self else { return }
            productPresenter.removeProductMedia(productID: self.productID, mediaID: id) {
                completion()
            } onRejected: {
                
            } onError: { error in
                self.productPresenter._loadingState.accept(false)
                self.displayAlert(with: .get(.error), message: error, actions: [UIAlertAction(title: .get(.ok), style: .default, handler: nil)])
            }
        }
    }
    
    
    private func createParam(){
        self.isProduct?.name = self.mainView.nameItemView.text
        let price = self.mainView.priceItemView.text?.replacingOccurrences(of: "Rp ", with: "")
        self.isProduct?.price = Double(price?.replacingOccurrences(of: ".", with: "") ?? "0")
        let desc = self.mainView.captionCTV.nameTextField.text ?? "-"
        self.isProduct?.postProductDescription = desc.count == 0 ? "-" : desc
        let stock = Int(mainView.stockItemView.text ?? "0")
        self.isProduct?.stock = stock
        
        
        self.isProduct?.measurement = ProductMeasurement(weight: deleteUnitKg(self.mainView.weightItemView.text ?? "0"), length: deleteUnitCm( self.mainView.lengthItemView.text ?? "0"), height: deleteUnitCm(self.mainView.highItemView.text ?? "0"), width: deleteUnitCm(self.mainView.widthItemView.text ?? "0"))
        
        guard var product = isProduct else { fatalError() }
        print("Productnya \(product)")
        if isAdd {
            product.accountId = getIdUser()
            productPresenter.addProduct(product)
            return
        }
        productPresenter.editProduct(product)
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func deleteUnitCm(_ str: String) -> Double {
        let str = str.replacingOccurrences(of: ",", with: ".")
        return str.suffix(3) == " cm" ?  Double(str.dropLast(3))!: 0
    }
    
    private func deleteUnitKg(_ str: String) -> Double {
        let str = str.replacingOccurrences(of: ",", with: ".")
        return str.suffix(3) == " kg" ?  Double(str.dropLast(3))!: 0
    }
    
    
    func routeToCategoryProduct() {
        let controller = SelectCategoryShopUIFactory.create(isPublic: false)
        controller.delegateEditProduct = self
        controller.bindNavigationBar("Kategori", true)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func routeToDetail(product: Product) {
        let detailController = ProductDetailFactory.createProductDetailController(dataSource: product)
        detailController.isFromEdit = true
        detailController.isArchive = isArchive
        detailController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailController, animated: true)
    }
    
    func updateProductRowAtPreviousController(with product: Product){
        for item in navigationController?.viewControllers ?? [] {
            if let myProductController = item as? MyProductViewController {
                let indexProduct = indexProduct
                myProductController.updateRow(at: indexProduct, data: ProductItem.fromProduct(product))
            } else if let detailProductController = item as? ProductDetailController  {
                detailProductController.presenter.configure(value: product)
                detailProductController.refreshView()
            } else if let productController = item as? ProductController {
                let indexProduct = indexProduct
                productController.updateRow(at: indexProduct, data: product)
            } else if let newHomeController = item as? NewHomeController {
                for controller in newHomeController.viewControllerList {
                    if let productController = controller as? ProductController {
                        let indexProduct = indexProduct
                        productController.updateRow(at: indexProduct, data: product)
                    }
                }
            }
        }
    }
    
    func showPicker(_ index: Int) {
        self.present(imagePickerController, animated: true)
        imagePickerController.handleMediaSelected = { [weak self] (media) in
            guard let self = self else { return }
            if self.isAdd {
                DispatchQueue.global(qos: .background).async {
                    self.medias.append(media)
                }
            } else {
                self.productPresenter._loadingState.accept(true)
                
                
                DispatchQueue.global(qos: .background).async {
                    switch media.type {
                    case .photo:
                        self.productPresenter.uploadImage(media)
                    case .video:
                        self.productPresenter.uploadVideo(media)
                    }
                }
            }
            
            self.enableRightBarButton()
            self.mainView.collectionView.reloadData()
        }
    }
    
    func reloadMediaCollectionView(_ images: [Medias]) {
        self.isProduct?.medias = images
        mainView.collectionView.reloadData()
    }
    
    func setChangedRemovedID(productID: String, mediaID: String) {
        self.productID = productID
        self.removedMediaID.append(mediaID)
    }
}

//MARK: - Collection View Delegate & Data Source
extension EditProductController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isAdd {
            let totalImages = medias.count
            
            if totalImages == 5 {
                return 5
            }
            
            return totalImages + 1
        } else {
            var totalImages = 0
            if let productCount = self.isProduct?.medias?.count {
                totalImages = productCount
                if productCount == 5 {
                    return 5
                }
            }
            return totalImages + 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCustomCell(with: PostItemCell.self, indexPath: indexPath)
        let row = indexPath.row
        
        if isAdd {
            let totalImages = medias.count
            
            if totalImages != 0 && row <= totalImages {
                if row < totalImages {
                    let sourceFile = medias[row]
                    switch sourceFile.type {
                    case .photo:
                        cell.imageView.image = UIImage(data: sourceFile.data!)!
                        cell.iconView.isHidden = true
                    case .video:
                        cell.imageView.image = sourceFile.videoThumbnail
                        cell.iconView.isHidden = false
                        cell.iconView.image = UIImage(named: AssetEnum.iconPlay.rawValue)
                    }
                    
                } else {
                    cell.imageView.image = UIImage(named: .get(.btnAddMedia))
                    cell.iconView.isHidden = true
                }
            } else {
                cell.imageView.image = UIImage(named: .get(.btnAddMedia))
                cell.iconView.isHidden = true
            }
            
            cell.handleMedia = {
                let medias = self.medias
                var uiImages: [UIImage] = []
                for item in medias {
                    if item.type == .video {
                        uiImages.append(item.videoThumbnail!)
                    }else {
                        uiImages.append(UIImage(data: item.data!)!)
                    }
                }
                if self.isMediaAvailable(row, uiImages) {
                    let media = self.responseMedia
                    self.routeToPreview(medias, media)
                } else {
                    self.showPicker(row)
                }
                
                
                
            }
        } else {
            if let totalImages = self.isProduct?.medias?.count {
                if totalImages != 0 && row <= totalImages {
                    if row < totalImages {
                        let sourceFile = self.isProduct?.medias![row]
                        cell.imageView.loadImage(at: (sourceFile?.thumbnail?.small)!)
                    } else {
                        cell.imageView.image = UIImage(named: .get(.btnAddMedia))
                    }
                } else {
                    cell.imageView.image = UIImage(named: .get(.btnAddMedia))
                }
            } else {
                cell.imageView.image = UIImage(named: .get(.btnAddMedia))
            }
            
            
            cell.handleMedia = {
                if let totalImages = self.isProduct?.medias?.count {
                    if indexPath.row < totalImages {
                        let editMediaController = EditMediaController(mainView: EidtMediaView(), dataSource: self.isProduct!)
                        editMediaController.index = row
                        editMediaController.sourceController = self
                        editMediaController.hidesBottomBarWhenPushed = true
                        self.navigationController?.present(editMediaController, animated: true)
                    } else {
                        self.showPicker(row)
                    }
                } else {
                    self.showPicker(row)
                }
                
            }
        }
        
        
        
        
        return cell
    }
    
    func isMediaAvailable(_ index: Int, _ image: [UIImage]) -> Bool {
        let isValid = image.indices.contains(index)
        return isValid == true ? true : false
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50 , height: 50)
    }
}

extension EditProductController : PostControllerType {
    
    func reloadMediaCollectionView(_ medias: [KKMediaItem]) {
        self.medias = medias
        mainView.collectionView.reloadData()
        enableRightBarButton()
    }
    
    
    func routeToPreview(_ itemMedias: [KKMediaItem],_ responseMedias: [ResponseMedia]) {
        let destinationDS = PostPreviewMediaModel.DataSource(itemMedias: itemMedias, responseMedias: responseMedias)
        let destinationVC = PostPreviewMediaController(mainView: PostPreviewMediaView(), dataSource: destinationDS)
        self.definesPresentationContext = true
        destinationVC.sourceController = self
        
        // Pass data to the destination data store
        self.present(destinationVC, animated: true, completion: nil)
    }
    
    func postProduct() {
        self.productPresenter._loadingState.accept(true)
        DispatchQueue.global(qos: .background).async {
            self.uploadLoop(medias: self.medias) {
                DispatchQueue.main.async {
                    self.createParam()
                }
            }
        }
    }
    
    func uploadLoop(medias : [KKMediaItem], endLoop : @escaping ()->()){
        
        let semaphore = DispatchSemaphore(value: 0)
        
        DispatchQueue.global(qos: .background).sync {
            for item in medias {
                switch item.type {
                case .photo:
                    self.uploadPhotoFeed(image: item) { [weak self] media in
                        guard let self = self else { return }
                        
                        let thumbnail = Thumbnail(large: media.thumbnail?.large, medium: media.thumbnail?.medium, small: media.thumbnail?.small)
                        let metadata = Metadata(width: media.metadata?.width, height: media.metadata?.height, size: media.metadata?.size, duration: media.metadata?.duration)
                        
                        let mediaResult = Medias(id: media.id, type: media.type, url: media.url, isHlsReady: nil, hlsUrl: nil, thumbnail: thumbnail, metadata: metadata)
                        
                        if self.isProduct?.medias == nil {
                            self.isProduct?.medias = [mediaResult]
                        } else {
                            self.isProduct?.medias?.append(mediaResult)
                        }
                        
                        semaphore.signal()
                    }
                    
                case .video:
                    self.uploadVideoFeed(video: item) { [weak self] (media) in
                        
                        guard let self = self else { return }
                        
                        let thumbnail = Thumbnail(large: media.thumbnail?.large, medium: media.thumbnail?.medium, small: media.thumbnail?.small)
                        let metadata = Metadata(width: media.metadata?.width, height: media.metadata?.height, size: media.metadata?.size, duration: media.metadata?.duration)
                        
                        let mediaResult = Medias(id: media.id, type: media.type, url: media.url, isHlsReady: nil, hlsUrl: nil, thumbnail: thumbnail, metadata: metadata)
                        if self.isProduct?.medias == nil {
                            self.isProduct?.medias = [mediaResult]
                        } else {
                            self.isProduct?.medias?.append(mediaResult)
                        }
                        
                        semaphore.signal()
                    }
                }
                semaphore.wait()
            }
            
            if medias.count == self.isProduct?.medias?.count && self.isProduct?.medias?.count != 0 {
                endLoop()
                return
            }
        }
        
        
        
    }
    
    private func uploadPhotoFeed(image: KKMediaItem, mediaCallback: @escaping (ResponseMedia)->()) {
        if ReachabilityNetwork.isConnectedToNetwork() {
            guard let data = image.data, let uiImage = UIImage(data: data), let ext = image.path.split(separator: ".").last else {
                self.productPresenter._loadingState.accept(false)
                self.productPresenter._errorMessage.accept("Failed to Upload")
                return
            }
            
            let request = MediaUploaderRequest(media: data, ext: "\(ext)")
            uploader.upload(request: request) { [weak self] (result) in
                guard let self = self else { return }
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
                    mediaCallback(media)
                    return
                    
                case .failure(let error):
                    self.productPresenter._loadingState.accept(false)
                    self.productPresenter._errorMessage.accept(error.getErrorMessage())
                    return
                }
            }
        } else {
            self.productPresenter._loadingState.accept(false)
            self.productPresenter._errorMessage.accept("No Internet Connection")
            return
        }
    }
    
    private func uploadVideoFeed(video: KKMediaItem, mediaCallback: @escaping (ResponseMedia)->()) {
        uploadVideoFeedThumbnail(thumbnail: video.videoThumbnail) { [weak self] (thumbnail, metadata) in
            guard let self = self else { return }
            self.uploadVideoFeedData(video: video) { [weak self] (video) in
                guard self != nil else { return }
                let media = ResponseMedia(
                    id: nil,
                    type: "video",
                    url: video.tmpUrl,
                    thumbnail: thumbnail,
                    metadata: metadata,
                    vodFileId: video.vod?.id,
                    vodUrl: video.vod?.url
                )
                mediaCallback(media)
            }
        }
    }
    
    private func uploadVideoFeedThumbnail(thumbnail: UIImage?, mediaCallback: @escaping (Thumbnail, Metadata)->()){
        if ReachabilityNetwork.isConnectedToNetwork() {
            
            guard let data = thumbnail?.pngData(), let image = thumbnail else {
                self.productPresenter._loadingState.accept(false)
                self.productPresenter._errorMessage.accept("Failed to Upload")
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
                    self.productPresenter._loadingState.accept(false)
                    self.productPresenter._errorMessage.accept(error.getErrorMessage())
                    return
                }
                
            }
            
        }else{
            self.productPresenter._loadingState.accept(false)
            self.productPresenter._errorMessage.accept("No Internet Connection")
            return
        }
    }
    
    private func uploadVideoFeedData(video: KKMediaItem, mediaCallback: @escaping (MediaUploaderResult)->()){
        if ReachabilityNetwork.isConnectedToNetwork() {
            guard let data = video.data, let ext = video.path.split(separator: ".").last else {
                self.productPresenter._loadingState.accept(false)
                self.productPresenter._errorMessage.accept("Failed to Upload")
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
                    self.productPresenter._loadingState.accept(false)
                    self.productPresenter._errorMessage.accept(error.getErrorMessage())
                    return
                }
                
            }
            
        }else{
            self.productPresenter._loadingState.accept(false)
            self.productPresenter._errorMessage.accept("No Internet Connection")
            return
        }
    }
}

extension EditProductController: EditProductDelegate {
    func setCategory(category: CategoryShopItem) {
        isProduct?.categoryId = category.id
        mainView.categoryProductButtonSelectView.name.text = category.name
        mainView.categoryProductButtonSelectView.name.textColor = .black
        enableRightBarButton()
    }
}
