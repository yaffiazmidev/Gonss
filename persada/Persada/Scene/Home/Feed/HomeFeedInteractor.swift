//
//  NewSelebInteractor.swift
//  Persada
//
//  Created by Muhammad Noor on 17/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import Foundation
import Combine
import UIKit
import KipasKipasNetworking
import KipasKipasNetworkingUtils
import KipasKipasShared

// TODO: Migrate ke use case

typealias NewSelebInteractable = NewSelebBusinessLogic & NewSelebDataStore

protocol NewSelebBusinessLogic {
	func doRequest(_ request: FeedModel.Request)
	func setPage(data: Int)
	func addMedia(_ media: String)
	func addProductId(_ id: String)
	func saveParameterStory()
}

protocol NewSelebDataStore {
	var dataSource: FeedModel.DataSource { get set }
	var page: Int { get set }
}

final class NewSelebInteractor: Interactable, NewSelebDataStore {
	var page: Int = 0
	var dataSource: FeedModel.DataSource
	private let network: FeedNetworkModel = FeedNetworkModel()
	private let uploadNetwork = UploadNetworkModel()
	private let profileNetwork = ProfileNetworkModel()
    private let refreshToken = RefreshToken.shared
	var presenter: FeedPresentationLogic
    let uploader: MediaUploader

	var cancellables: [AnyCancellable] = []
	private var selebsubscriptions = Set<AnyCancellable>()
    private var storySubscriptions: AnyCancellable?
    private var publicStorySubscriptions: AnyCancellable?
	
	init(viewController: NewSelebDisplayLogic?, dataSource: FeedModel.DataSource) {
		self.dataSource = dataSource
		self.presenter = HomeFeedPresenter(viewController)
        self.uploader = MainQueueDispatchDecorator(decoratee: MediaUploadManager())
	}
}


// MARK: - NewSelebBusinessLogic
extension NewSelebInteractor: NewSelebBusinessLogic {

	func setPage(data: Int) {
		page = data
	}

	func doRequest(_ request: FeedModel.Request) {
		DispatchQueue.global(qos: .utility).async {
			switch request {
			case .story(let page):
				self.requestShowStories(page: page)
			case .like(let id, let status, let index):
				self.dataSource.index = index
				self.dataSource.statusLike = status
				self.requestLike(id: id, status: status)
			case .follow(let id, let index):
				self.dataSource.index = index
				self.requestFollow(id)
			case .uploadMedia(let item):
				self.uploadMedia(item)
			case .postStory(let param):
				self.postStory(param)
			case .detail(let username):
				self.detail(username)
			case .unlike(id: let id, status: let status, index: let index):
				self.dataSource.index = index
				self.requestUnlike(id: id, status: status)
            case .publicStory(let page):
                self.requestPublicStories(page: page)
			}
		}
	}
	
	func saveParameterStory() {
		let productId = [MediaPostProductId(id: dataSource.productId)]
		let type = "story"
		let medias = dataSource.media ?? []
		let mediaPostStory = [MediaPostStory(medias: medias, postProducts: productId)]

		self.postStory(ParameterPostStory(post: mediaPostStory, typePost: type))
	}
	
	func saveStory(_ value: Story?) {
		guard let value = value else {
			return
		}

		self.dataSource.story = value
	}
	
	func addMedia(_ media: String) {
		self.dataSource.mediaPath = media
	}
    
	func addProductId(_ id: String) {
		dataSource.productId = id
	}

}


// MARK: - Private Zone
private extension NewSelebInteractor {
	
	func detail(_ text: String) {
		
		profileNetwork.profileUsername(.profileUsername(text: text))
            .subscribe(on: DispatchQueue.global(qos: .background))
            .sink(receiveCompletion: { (completion) in
			switch completion {
			case .failure(let error):
				if error is ErrorMessage {
					let errorMsg = error as! ErrorMessage
					self.presenter.presentResponse(.detail(ProfileResult(code: "\(errorMsg.statusCode)", data: nil, message: "\(errorMsg.statusData ?? "") \(errorMsg.statusMessage ?? "")")))
				} else {
					print(error.localizedDescription)
				}
			case .finished: break
			}
		}) { [weak self] (model: ProfileResult) in
			guard let self = self else { return }
			
			self.presenter.presentResponse(.detail(model))
		}.store(in: &cancellables)
	}


	func requestShowStories(page: Int) {
        storySubscriptions = network.fetchStory(.story(page: page))
            .subscribe(on: DispatchQueue.global(qos: .background))
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .failure(let error):
                    guard let error = error as? ErrorMessage, error.statusCode != 401 else {
                        self.refreshToken.refreshToken(token: getRefreshToken()) { [weak self] status in
                            switch status {
                            case .success:
                                self?.requestShowStories(page: page)
                            case .failed:
                                self?.presenter.presentResponse(.failedToRefreshToken)
                            }
                        }
                        return
                    }
                    
                    self.presenter.presentResponse(.stories(StoryResult(code: "\(error.statusCode ?? 404)", message: error.statusMessage, data: nil)))
                case .finished: break
                }
            }) { [weak self] (model: StoryResult) in
                guard let self = self else { return }
                self.presenter.presentResponse(.stories(model))
        }
	}
    
    func requestPublicStories(page: Int) {
        publicStorySubscriptions = network.fetchPublicStory(.publicStory(page: page))
            .subscribe(on: DispatchQueue.global(qos: .background))
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .failure(let error):
                    guard let error = error as? ErrorMessage, error.statusCode != 401 else {
                        self.refreshToken.refreshToken(token: getRefreshToken()) { [weak self] status in
                            switch status {
                            case .success:
                                self?.requestShowStories(page: page)
                            case .failed:
                                self?.presenter.presentResponse(.failedToRefreshToken)
                            }
                        }
                        return
                    }
                    self.presenter.presentResponse(.publicStories(PublicStoryResult(code: "\(error.statusCode ?? 0)", message: error.statusMessage, data: nil)))
                case .finished: break
                }
            }) { [weak self] (model: PublicStoryResult) in
							guard let self = self else { return }
                self.presenter.presentResponse(.publicStories(model))
        }
    }
	
	func requestLike(id: String, status: String) {

		network.requestLike(.likeFeed(id: id, status: status))
            .subscribe(on: DispatchQueue.global(qos: .background))
            .sink (receiveCompletion: { (completion) in
			switch completion {
			case .failure(let error): print(error.localizedDescription )
			case .finished: break
			}
		}) { [weak self] (model: DefaultResponse) in
			guard let self = self else { return }
			
			self.presenter.presentResponse(.like(model))
		}.store(in: &cancellables)
	}
	
	func requestUnlike(id: String, status: String) {

		network.requestLike(.likeFeed(id: id, status: status))
            .subscribe(on: DispatchQueue.global(qos: .background))
            .sink (receiveCompletion:  { (completion) in
			switch completion {
			case .failure(let error): print(error.localizedDescription )
			case .finished: break
			}
		}) { [weak self] (model: DefaultResponse) in
			guard let self = self else { return }
			
			self.presenter.presentResponse(.unlike(model))
		}.store(in: &cancellables)
	}
	
	func requestFollow(_ id: String) {

		profileNetwork.followAccount(.followAccount(id: id)) { [weak self] (result) in
			guard let self = self else {
				return
			}

			switch result {
			case .success(_):
				fallthrough
			default:
				self.presenter.presentResponse(.follow(result))
			}
		}
	}
	
	func postStory(_ param: ParameterPostStory) {
		
		uploadNetwork.createStory(.createStory, param) { [weak self] (result) in
			
			guard let self = self else {
				return
			}

			switch result {
			
			case .success(_):
				fallthrough
			default:
				self.presenter.presentResponse(.postStory(result))
			}
		}
	}
	
    func uploadMedia(_ item: KKMediaItem) {
        switch item.type {
        case .photo:
            self.uploadPhoto(item)
        case .video:
            self.uploadVideo(item)
        }
	}
    
    private func uploadPhoto(_ item: KKMediaItem) {
        if ReachabilityNetwork.isConnectedToNetwork() {
            
            guard let data = item.data, let uiImage = UIImage(data: data), let ext = item.path.split(separator: ".").last else {
                self.handleError("Failed to Upload")
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
                    self.handleError(error.getErrorMessage())
                    return
                }
            }
        } else {
            self.handleError("No Internet Connection")
            return
        }
    }
    
    private func uploadVideo(_ item: KKMediaItem) {
        uploadVideoThumbnail(item) { [weak self] (thumbnail, metadata) in
            self?.uploadVideoData(item, mediaCallback: { [weak self] (video) in
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
                self.handleError("Failed to Upload")
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
                    self.handleError(error.getErrorMessage())
                    return
                }
                
            }
            
        }else{
            self.handleError("No Internet Connection")
            return
        }
    }
    
    private func uploadVideoData(_ item: KKMediaItem, mediaCallback: @escaping (MediaUploaderResult)->()){
        if ReachabilityNetwork.isConnectedToNetwork() {
            guard let data = item.data, let ext = item.path.split(separator: ".").last else {
                handleError("Failed to Upload")
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
                    self.handleError(error.getErrorMessage())
                    return
                }
                
            }
            
        }else{
            self.handleError("No Internet Connection")
            return
        }
    }
    
    private func handleError(_ message: String){
        self.presenter.presentResponse(.media(.failure(ErrorMessage(statusCode: 0, statusMessage: "Failed to Upload", statusData: message))))
    }
}
