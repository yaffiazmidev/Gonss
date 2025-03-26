//
//  ComplaintInteractor.swift
//  KipasKipas
//
//  Created by NOOR on 01/02/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import Foundation
import UIKit
import Combine
import KipasKipasShared
import KipasKipasNetworkingUtils

typealias ComplaintInteractable = ComplaintBusinessLogic & ComplaintDataStore

protocol ComplaintBusinessLogic {
	
	func doRequest(_ request: ComplaintModel.Request)
}

protocol ComplaintDataStore {
	var dataSource: ComplaintModel.DataSource { get set }
}

final class ComplaintInteractor: Interactable, ComplaintDataStore {
	
	var dataSource: ComplaintModel.DataSource
	private var subscription = Set<AnyCancellable>()
	private var presenter: ComplaintPresentationLogic
    private let uploader: MediaUploader
	
	init(viewController: ComplaintDisplayLogic?, dataSource: ComplaintModel.DataSource) {
		self.dataSource = dataSource
		self.presenter = ComplaintPresenter(viewController)
        self.uploader = MainQueueDispatchDecorator(decoratee: MediaUploadManager())
	}
}


// MARK: - ComplaintBusinessLogic
extension ComplaintInteractor: ComplaintBusinessLogic {
	
	func doRequest(_ request: ComplaintModel.Request) {
		DispatchQueue.global(qos: .userInitiated).async {
			
			switch request {
				
			case .inputComplaint(let item):
				self.complaint(item)
            case .uploadPhoto(let item):
                self.uploadPhoto(item)
			case .uploadVideo(let item):
				self.uploadVideo(item)
			}
		}
	}
}


// MARK: - Private Zone
private extension ComplaintInteractor {
	
	func complaint(_ input: ComplaintInput) {
		let network = OrderNetworkModel()
		network.postComplaint(.complaint, input).sink { (completion) in
			switch completion {
			case .failure(let error): print(error.localizedDescription)
			case .finished: break
			}
		} receiveValue: { (model: DefaultResponse) in
			self.presenter.presentResponse(.complaint(result: model))
		}.store(in: &subscription)

	}
	
    private func uploadPhoto(_ item: KKMediaItem) {
        if ReachabilityNetwork.isConnectedToNetwork() {
            
            guard let data = item.data, let uiImage = UIImage(data: data), let ext = item.path.split(separator: ".").last else {
                self.presenter.presentResponse(.media(.failure(ErrorMessage(statusCode: 0, statusMessage: "Failed to Upload", statusData: "Failed to Upload"))))
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
                    self.presenter.presentResponse(.media(.success(media)))
                    return
                    
                case .failure(let error):
                    self.handleError(error)
                    return
                }
            }
        } else {
            self.presenter.presentResponse(.media(.failure(ErrorMessage(statusCode: 0, statusMessage: "Failed to Upload", statusData: "No Internet Connection"))))
            return
        }
    }
    
    private func uploadVideo(_ item: KKMediaItem) {
        uploadVideoThumbnail(item) { [weak self] (thumbnail, metadata) in
            self?.uploadVideoData(item ,mediaCallback: { [weak self] (video) in
                let media = ResponseMedia(
                    id: nil,
                    type: "video",
                    url: video.tmpUrl,
                    thumbnail: thumbnail,
                    metadata: metadata,
                    vodFileId: video.vod?.id,
                    vodUrl: video.vod?.url
                )
                
                self?.presenter.presentResponse(.media(.success(media)))
            })
        }
    }
    
    private func uploadVideoThumbnail(_ item: KKMediaItem, mediaCallback: @escaping (Thumbnail, Metadata)->()){
        
        if ReachabilityNetwork.isConnectedToNetwork() {
            
            guard let data = item.videoThumbnail?.pngData(), let image = item.videoThumbnail else {
                self.presenter.presentResponse(.media(.failure(ErrorMessage(statusCode: 0, statusMessage: "Failed to Upload", statusData: "Failed to Upload"))))
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
                    self.handleError(error)
                    return
                }
                
            }
            
        }else{
            self.presenter.presentResponse(.media(.failure(ErrorMessage(statusCode: 0, statusMessage: "Failed to Upload", statusData: "No Internet Connection"))))
            return
        }
    }
    
    private func uploadVideoData(_ item: KKMediaItem, mediaCallback: @escaping (MediaUploaderResult)->()){
        if ReachabilityNetwork.isConnectedToNetwork() {
            guard let data = item.data, let ext = item.path.split(separator: ".").last else {
                self.presenter.presentResponse(.media(.failure(ErrorMessage(statusCode: 0, statusMessage: "Failed to Upload", statusData: "Failed to Upload"))))
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
                    self.handleError(error)
                    return
                }
                
            }
            
        }else{
            self.presenter.presentResponse(.media(.failure(ErrorMessage(statusCode: 0, statusMessage: "Failed to Upload", statusData: "No Internet Connection"))))
            return
        }
    }
    
    private func handleError(_ error: Error){
        self.presenter.presentResponse(.media(.failure(ErrorMessage(statusCode: 0, statusMessage: error.getErrorMessage(), statusData: error.getErrorMessage()))))
    }
}
