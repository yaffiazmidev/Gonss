//
//  PostInteractor.swift
//  Persada
//
//  Created by NOOR on 30/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import Foundation
import UIKit
import KipasKipasShared
import KipasKipasNetworkingUtils

typealias PostSocialInteractable = PostBusinessLogic & PostDataStore

protocol PostBusinessLogic {
	
	func doRequest(_ request: PostModel.Request)
	func saveChannel(_ id: String, _ name: String)
	func addImage(_ index: Int, _ image: UIImage)
	func addPathImage(_ index: Int, _ path: String)
	func saveMedia(_ media: ResponseMedia)
	func removeMedia(_ index: Int)
	func changeType(_ type: String)
	func description(_ text: String)
	func saveParameterSocial()
	func saveParameterProduct()
	func statePost(_ status: String) -> Bool
	func isMediaAvailable(_ index: Int, _ image: [UIImage]) -> Bool
	func addShippingAttribute(_ name: String, _ price: String, _ length: String,_ weight: String,_ height: String,_ width: String)
    func uploadMedia()
}

protocol PostDataStore {
    var dataSource: PostModel.DataSource { get set }
}

final class PostInteractor: Interactable, PostDataStore {
    
    var dataSource: PostModel.DataSource
    
    var presenter: PostPresentationLogic
    
    private let uploader: MediaUploader
    
    init(viewController: PostDisplayLogic?, dataSource: PostModel.DataSource) {
        self.uploader = MainQueueDispatchDecorator(decoratee: MediaUploadManager())
        self.dataSource = dataSource
        self.presenter = PostPresenter(viewController)
    }
}


// MARK: - PostBusinessLogic
extension PostInteractor: PostBusinessLogic {

	func addShippingAttribute(_ name: String, _ price: String, _ length: String, _ weight: String, _ height: String, _ width: String) {
		self.dataSource.nameItem = name
		self.dataSource.lengthItem = length
		self.dataSource.widthItem = width
		self.dataSource.weightItem = weight
		self.dataSource.heightItem = height
		self.dataSource.priceItem = price
	}

	func isMediaAvailable(_ index: Int, _ image: [UIImage]) -> Bool {
		let isValid = image.indices.contains(index)
		return isValid == true ? true : false
	}

	func statePost(_ status: String) -> Bool {
		guard status == "social" else {
			return false
		}
		
		return true
	}
	
	func saveParameterSocial() {
		let channelId = ChannelId(id: self.dataSource.channel?.id ?? "")
		let description = self.dataSource.description
		let media = self.dataSource.responseMedias ?? []
		let type = self.dataSource.typePost
		let mediaPostSocial = MediaPostSocial(channel: channelId, descriptionField: description, medias: media, type: type)

		self.dataSource.paramStatusSocial = ParameterPostSocial(post: mediaPostSocial, typePost: type)
		
		guard let postSocial = self.dataSource.paramStatusSocial else {
			return
		}
		
		self.postSocial(postSocial)
	}
	
	func saveParameterProduct() {
		let channelId = ChannelId(id: self.dataSource.channel?.id)
		let description = self.dataSource.description
		let media = self.dataSource.responseMedias ?? []
		let type = self.dataSource.typePost
		let name = self.dataSource.nameItem
        let price = Int(self.dataSource.priceItem)
        let weight = Double(self.dataSource.weightItem)
        let height = Double(self.dataSource.heightItem)
        let width = Double(self.dataSource.widthItem)
        let length = Double(self.dataSource.lengthItem)
        let measurement = ProductMeasurement(weight: weight, length: length, height: height, width: width)
        
        self.dataSource.paramStatusProduct = ParameterPostProduct(name: name, description: description, price: price, measurement: measurement, medias: media, accountId: getIdUser())
        
        guard let postProduct = self.dataSource.paramStatusProduct else {
            return
        }
        
        self.postProduct(postProduct)
    }
    
    func description(_ text: String) {
        self.dataSource.description = text
    }
    
    func changeType(_ type: String) {
        self.dataSource.typePost = type
    }
    
    func addImage(_ index: Int, _ image: UIImage) {
        //		if self.dataSource.images.indices.contains(index) == false {
        //			self.dataSource.images.append(image)
        //		} else {
        //			self.dataSource.images[index] = image
        //		}
    }
    
    func addPathImage(_ index: Int, _ path: String) {
        if self.dataSource.pathImages.indices.contains(index) == false {
            self.dataSource.pathImages.append(path)
        } else {
            self.dataSource.pathImages[index] = path
        }
    }
    
    func saveChannel(_ id: String, _ name: String) {
        self.dataSource.channel?.name = name
        self.dataSource.channel?.id = id
    }
    
    func saveMedia(_ media: ResponseMedia) {
        //		self.dataSource.media?.append(media)
    }
    
    func removeMedia(_ index: Int) {
        //		self.dataSource.media?.remove(at: index)
        //		self.dataSource.images.remove(at: index)
    }
    
    func doRequest(_ request: PostModel.Request) {
        DispatchQueue.global(qos: .userInitiated).async {
            switch request {
            case .uploadVideo(let path):
                self.uploadVideo(path)
            case .postSocial(let param):
                self.postSocial(param)
            case .postProduct(let param):
                self.postProduct(param)
            case .uploadMedia:
                self.uploadMedia()
            }
        }
    }
}


// MARK: - Private Zone
private extension PostInteractor {
    
    func uploadVideo(_ path: String) {
	}
	
	func postSocial(_ param: ParameterPostSocial) {
		
		let network = UploadNetworkModel()
		
		network.postSocial(.postSocial, param) { [weak self] (result) in

			guard let self = self else {
				return
			}
//			self.presenter.presentResponse(.responsePost(result))
            switch result {
            case .success(let response):
                self.presenter.showFeed(response)
            case .failure(let error):
                guard let error = error else { return }
                self.presenter.showError(error)
            }
        }
    }
    
    func postProduct(_ param: ParameterPostProduct) {
        
        let network = UploadNetworkModel()
        
        network.postProduct(.postProduct, param) { [weak self] (result) in
            
            guard let self = self else {
                return
            }
            //			self.presenter.presentResponse(.responsePost(result))
            switch result {
            case .success(let response):
                self.presenter.showFeed(response)
            case .failure(let error):
                guard let error = error else { return }
                self.presenter.showError(error)
            }
        }
    }
}

extension PostInteractor{
    
    //Progress Syncronus Upload Media
    
    func uploadMedia() {
        guard let medias = dataSource.itemMedias, let media = medias.first else { return }
        switch media.type {
            
        case .photo:
            uploadPhoto(media)
            
        case .video:
            uploadVideo(media)
            
        }
    }
    
    //Post Upload
    private func uploadPhoto(_ item: KKMediaItem){
        guard let data = item.data, let uiImage = UIImage(data: data), let ext = item.path.split(separator: ".").last else {
            self.handleResponseFailedUploadMedia(ErrorMessage(statusCode: 0, statusMessage: "Failed to Upload", statusData: "Failed to Upload"))
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
                self.handleResponseSuccessUploadMedia(media)
                return
                
            case .failure(let error):
                self.handleResponseFailedUploadMedia(ErrorMessage(statusCode: 0, statusMessage: error.getErrorMessage(), statusData: error.getErrorMessage()))
                return
            }
        }
        
        
    }
    
    private func uploadVideo(_ item: KKMediaItem){
        let errorCallback = { [weak self] (error: Error?) in
            guard let self = self else { return }
            if let error = error {
                self.handleResponseFailedUploadMedia(ErrorMessage(statusCode: 0, statusMessage: error.getErrorMessage(), statusData: error.getErrorMessage()))
                return
            }
            
            self.handleResponseFailedUploadMedia(ErrorMessage(statusCode: 0, statusMessage: "Failed to Upload", statusData: "Failed to Upload"))
            return
        }
        
        uploadVideoThumbnail(thumbnail: item.videoThumbnail, mediaCallback: { [weak self] (thumbnail, metadata) in
            
            guard let self = self else { return }
            self.uploadVideoData(video: item, mediaCallback: { [weak self] (video) in
                
                guard let self = self else { return }
                let media = ResponseMedia(
                    id: nil,
                    type: "video",
                    url: video.tmpUrl,
                    thumbnail: thumbnail,
                    metadata: metadata,
                    vodFileId: video.vod?.id,
                    vodUrl: video.vod?.url
                )
                self.handleResponseSuccessUploadMedia(media)
                
            }, errorCallback: errorCallback)
            
        }, errorCallback: errorCallback)
    }
    
    private func uploadVideoThumbnail(thumbnail: UIImage?, mediaCallback: @escaping (Thumbnail, Metadata)->(), errorCallback: @escaping (Error?)->()){
        
        
        guard let data = thumbnail?.pngData(), let image = thumbnail else {
            errorCallback(nil)
            return
        }
        
        let request = MediaUploaderRequest(media: data, ext: "jpeg")
        uploader.upload(request: request) { [weak self] (result) in
            
            guard self != nil else { return }
            
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
                errorCallback(error)
                return
            }
            
        }
    }
    
    private func uploadVideoData(video: KKMediaItem, mediaCallback: @escaping (MediaUploaderResult)->(), errorCallback: @escaping(Error?) -> ()){
        
        
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
    
    //Handling Response Upload
    
    private func handleResponseSuccessUploadMedia(_ res: ResponseMedia){
        //        dataSource.media.append(res)
        dataSource.responseMedias?.removeFirst()
        if dataSource.responseMedias!.count == 0 {
            saveParameterProduct() //Continue to post product
        } else{
            uploadMedia() //Continue to upload media
        }
    }
    
    private func handleResponseFailedUploadMedia(_ err: ErrorMessage?){
        if let er = err{
            presenter.showError(er)
        }
    }
    
}
