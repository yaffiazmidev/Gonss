//
//  ReviewAddViewController.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 18/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit
import KipasKipasNetworking
import KipasKipasShared
import KipasKipasNetworkingUtils

class ReviewAddController: CustomHalfViewController {
    let orderId: String
    let productName: String
    let productPhotoUrl: String
    let mainView: ReviewAddView
    var creator: ReviewCreator!
    var uploader: MediaUploader!
    
    var onReviewCreated: (() -> Void)?
    
    required init(orderId: String, productName: String, productPhotoUrl: String, view: ReviewAddView){
        self.orderId = orderId
        self.productName = productName
        self.productPhotoUrl = productPhotoUrl
        self.mainView = view
        super.init(nibName: nil, bundle: nil)
        self.creator = RemoteReviewCreator(url: URL(string: APIConstants.baseURL)!, client: makeHTTPClient().authHTTPClient)
        self.uploader = MainQueueDispatchDecorator(decoratee: MediaUploadManager())
        viewHeight = 550
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.productNameLabel.text = productName
        mainView.productImageView.loadImage(at: productPhotoUrl)
        mainView.reviewCTV.ctvDelegate = self
        handleOnTap()
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        containerView.addSubview(mainView.closeView)
        containerView.addSubview(mainView.productView)
        containerView.addSubview(mainView.ratingLabel)
        containerView.addSubview(mainView.ratingView)
        containerView.addSubview(mainView.reviewLabel)
        containerView.addSubview(mainView.reviewCTV)
        containerView.addSubview(mainView.reviewMinLengthCaption)
        containerView.addSubview(mainView.reviewMaxLengthCaption)
        containerView.addSubview(mainView.mediaView)
        
        containerView.addSubview(mainView.submitView)
        
        mainView.closeView.anchor(top: containerView.topAnchor, right: containerView.rightAnchor, paddingTop: 12, paddingRight: 12, width: 20, height: 20)
        mainView.productView.anchor(top: mainView.closeView.bottomAnchor, left: containerView.leftAnchor, right: containerView.rightAnchor, paddingTop: 8, paddingLeft: 16, paddingRight: 16, height: 48)
        mainView.ratingLabel.anchor(top: mainView.productView.bottomAnchor, paddingTop: 16, paddingLeft: 16, paddingRight: 16)
        mainView.ratingView.anchor(top: mainView.ratingLabel.bottomAnchor, paddingTop: 12, paddingLeft: 16, paddingRight: 16)
        mainView.reviewLabel.anchor(top: mainView.ratingView.bottomAnchor, left: containerView.leftAnchor, right: containerView.rightAnchor, paddingTop: 40, paddingLeft: 16, paddingRight: 16)
        mainView.reviewCTV.anchor(top: mainView.reviewLabel.bottomAnchor, left: containerView.leftAnchor, right: containerView.rightAnchor, paddingTop: 4, paddingLeft: 16, paddingRight: 16)
        //        mainView.reviewMinLengthCaption.anchor(top: mainView.reviewCTV.bottomAnchor, left: containerView.leftAnchor, paddingTop: 4, paddingLeft: 16)
        mainView.reviewMaxLengthCaption.anchor(top: mainView.reviewCTV.bottomAnchor, right: containerView.rightAnchor, paddingTop: 4, paddingRight: 16)
        mainView.mediaView.anchor(top: mainView.reviewCTV.bottomAnchor, left: containerView.leftAnchor, right: containerView.rightAnchor, paddingTop: 32, paddingLeft: 16, paddingRight: 16)
        
        mainView.ratingLabel.centerXTo(containerView.centerXAnchor)
        mainView.ratingView.centerXTo(containerView.centerXAnchor)
        
        mainView.submitView.anchor( left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, height: 64)
        containerView.bringSubviewToFront(mainView.submitView)
    }
    
    private func handleOnTap(){
        mainView.closeView.onTap { [weak self] in
            self?.animateDismissView()
        }
        
        mainView.ratingView.didTouchCosmos = { [weak self] (rating) in
            self?.mainView.updateRatingLabel()
            self?.enableSubmitButton()
        }
        
        mainView.mediaView.handleAddMedia = { [weak self] in
            let vc = KKCameraViewController(type: .photo)
            vc.modalPresentationStyle = .fullScreen
            self?.present(vc, animated: true)
            vc.handleMediaSelected = { [weak self] (item) in
                guard let self = self else { return }
                self.mainView.mediaView.data.append(ReviewAddMedia(item: item))
                let index = self.mainView.mediaView.data.count - 1
                self.mainView.mediaView.refreshItem(at: index)
                self.uploadMedia(at: index)
            }
        }
        
        mainView.mediaView.handleRemoveMedia = { [weak self] (index) in
            guard let self = self else { return }
            if index <  self.mainView.mediaView.data.count {
                self.mainView.mediaView.data.remove(at: index)
                self.mainView.mediaView.removeItem(at: index)
            }
        }
        
        mainView.submitView.handleSubmit = { [weak self] in
            guard let self = self else { return }
            self.createReview()
        }
    }
    
    private func enableSubmitButton(){
        let reviewCount = mainView.reviewCTV.nameTextField.text.count
        mainView.reviewMaxLengthCaption.text = "\(reviewCount)/1000"
        mainView.reviewMaxLengthCaption.isHidden = reviewCount == 0
        //        mainView.reviewMinLengthCaption.isHidden = reviewCount >= 40
        
        if mainView.ratingView.rating < 1 {
            mainView.submitView.submitButton.isEnabled = false
            mainView.submitView.submitButton.backgroundColor = .whiteSmoke
            return
        }
        
        //        if reviewCount > 0 && reviewCount < 40 {
        //            mainView.submitView.submitButton.isEnabled = false
        //            mainView.submitView.submitButton.backgroundColor = .whiteSmoke
        //            return
        //        }
        
        mainView.submitView.submitButton.isEnabled = true
        mainView.submitView.submitButton.backgroundColor = .primary
    }
    
    private func showSuccessDialog(){
        let vc = CustomPopUpViewController(title: .get(.reviewSuccessAddTitle), description: .get(.reviewSuccessAddDesc), iconImage: UIImage(named: .get(.iconThumbUp)), iconHeight: 90, okBtnTitle: .get(.back))
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
        
        vc.handleTapOKButton = {
            vc.dismiss(animated: true){
                self.dismiss(animated: true){
                    self.onReviewCreated?()
                }
            }
        }
    }
}

extension ReviewAddController: CustomTextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        enableSubmitButton()
    }
}

// MARK: - Network Handler
extension ReviewAddController {
    func createReview(){
        mainView.submitView.submitButton.showLoading()
        
        let hideUsername = mainView.submitView.hideUsernameCheckBox.isChecked
        let review = mainView.reviewCTV.nameTextField.text ?? ""
        let rating = mainView.ratingView.rating
        var medias: [ReviewMedia] = []
        self.mainView.mediaView.data.forEach { media in
            if let m = media.media {
                medias.append(m)
            }
        }
        
        creator.create(request: .init(orderId: orderId, body: ReviewCreateBodyRequest(medias: medias, isAnonymous: hideUsername, review: review, rating: rating))) { [weak self] (result) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.mainView.submitView.submitButton.hideLoading()
                switch(result){
                case .success(_):
                    self.showSuccessDialog()
                    break
                case .failure(let error):
                    print("*** failed post review \(error)")
                    self.showLongToast(message: "Gagal mengirim review")
                    break
                }
            }
        }
    }
    
    func uploadMedia(at index: Int){
        let media = self.mainView.mediaView.data[index]
        
        let errorCallback = { [weak self] (error: Error?) in
            guard let self = self else { return }
            var message = "Gagal mengunggah media"
            if let error = error {
                message += "\n\(error.getErrorMessage())"
            }
            self.showToast(message: message)
            self.mainView.mediaView.data.remove(at: index)
            self.mainView.mediaView.removeItem(at: index)
        }
        
        if media.item.type == .video {
            self.uploadVideo(video: media.item, mediaCallback: { [weak self] reviewMedia in
                guard let self = self else { return }
                media.media = reviewMedia
                self.mainView.mediaView.refreshItem(at: index)
            }, errorCallback: errorCallback)
        }else {
            self.uploadPhoto(image: media.item, mediaCallback: { [weak self] reviewMedia in
                guard let self = self else { return }
                media.media = reviewMedia
                self.mainView.mediaView.refreshItem(at: index)
            }, errorCallback: errorCallback)
        }
        
    }
    
    private func uploadPhoto(image: KKMediaItem, mediaCallback: @escaping (ReviewMedia)->(), errorCallback: @escaping (Error?)->()) {
        
        guard let data = image.data, let uiImage = UIImage(data: data), let ext = image.path.split(separator: ".").last else {
            errorCallback(nil)
            return
        }
        
        let request = MediaUploaderRequest(media: data, ext: "\(ext)")
        uploader.upload(request: request) { [weak self] (result) in
            guard let self = self else { return }
            switch result{
            case .success(let response):
                
                let media = ReviewMedia(
                    id: nil,
                    type: "image",
                    url: response.tmpUrl,
                    thumbnail: ReviewMediaThumbnail(
                        large: response.url,
                        medium: response.url,
                        small: response.url
                    ),
                    metadata: ReviewMediaMetadata(
                        width: "\(uiImage.size.width * uiImage.scale)",
                        height: "\(uiImage.size.height * uiImage.scale)",
                        size: "0",
                        duration: 0
                    ),
                    isHLSReady: nil,
                    hlsURL: nil,
                    username: "",
                    photo: "",
                    accountId: "",
                    isAnonymous: false,
                    review: "",
                    rating: 0,
                    createAt: 0
                )
                mediaCallback(media)
                return
                
            case .failure(let error):
                errorCallback(error)
                return
            }
        }
        
    }
    
    private func uploadVideo(video: KKMediaItem, mediaCallback: @escaping (ReviewMedia)->(), errorCallback: @escaping (Error?)->()) {
        
        uploadVideoThumbnail(thumbnail: video.videoThumbnail, mediaCallback: { [weak self] (thumbnail, metadata) in
            guard let self = self else { return }
            
            self.uploadVideoData(video: video, mediaCallback: { [weak self] (video) in
                
                guard self != nil else { return }
                
                let media = ReviewMedia(
                    id: nil,
                    type: "video",
                    url: video.tmpUrl,
                    thumbnail: thumbnail,
                    metadata: metadata,
                    isHLSReady: nil,
                    hlsURL: nil,
                    username: "",
                    photo: "",
                    accountId: "",
                    isAnonymous: false,
                    review: nil,
                    rating: 0,
                    createAt: 0,
                    vodFileId: video.vod?.id,
                    vodUrl: video.vod?.url
                )
                mediaCallback(media)
                
            }, errorCallback: errorCallback)
            
        }, errorCallback: errorCallback)
        
    }
    
    private func uploadVideoThumbnail(thumbnail: UIImage?, mediaCallback: @escaping (ReviewMediaThumbnail, ReviewMediaMetadata)->(), errorCallback: @escaping (Error?)->()){
        
        guard let data = thumbnail?.pngData(), let image = thumbnail else {
            errorCallback(nil)
            return
        }
        
        let request = MediaUploaderRequest(media: data, ext: "jpeg")
        uploader.upload(request: request) { [weak self] (result) in
            
            guard self != nil else { return }
            
            switch result{
            case .success(let response):
                
                let thumbnail = ReviewMediaThumbnail(
                    large: response.tmpUrl,
                    medium: response.url,
                    small: response.url
                )
                
                let metadata = ReviewMediaMetadata(
                    width: "\(image.size.width * image.scale)",
                    height: "\(image.size.height * image.scale)",
                    size: "0",
                    duration: 0
                )
                
                mediaCallback(thumbnail, metadata)
                return
                
            case .failure(let error):
                errorCallback(error)
                return
            }
            
        }
    }
    
    private func uploadVideoData(video: KKMediaItem, mediaCallback: @escaping (MediaUploaderResult)->(), errorCallback: @escaping (Error?)->()){
        
        guard let data = video.data, let ext = video.path.split(separator: ".").last else {
            errorCallback(nil)
            return
        }
        
        let request = MediaUploaderRequest(media: data, ext: "\(ext)")
        uploader.upload(request: request) { [weak self] (result) in
            
            guard self != nil else { return }
            
            switch(result){
            case .success(let response):
                mediaCallback(response)
                return
                
            case .failure(let error):
                errorCallback(error)
                return
            }
            
        }
    }
    
    
    private func makeHTTPClient() -> (httpClient: HTTPClient, authHTTPClient: AuthenticatedHTTPClientDecorator) {
        
        let baseURL = URL(string: APIConstants.baseURL)!
        
        let httpClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        
        let localTokenLoader = LocalTokenLoader(store: makeKeychainTokenStore())
        let remoteTokenLoader = RemoteTokenLoader(url: baseURL, client: httpClient)
        let fallbackTokenLoader = TokenLoaderCacheDecorator(decoratee: remoteTokenLoader, cache: localTokenLoader)
        let tokenLoader = TokenLoaderWithFallbackComposite(primary: remoteTokenLoader, fallback: fallbackTokenLoader)
        
        let authHTTPClient = AuthenticatedHTTPClientDecorator(decoratee: httpClient, cache: makeKeychainTokenStore(), loader: tokenLoader)
        
        return (httpClient, authHTTPClient)
    }
    
    private func makeKeychainTokenStore() -> TokenStore {
        return KeychainTokenStore()
    }
}
