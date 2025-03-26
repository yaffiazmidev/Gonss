//
//  NewUserProfileInteractor.swift
//  Persada
//
//  Created by monggo pesen 3 on 19/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import Foundation
import Combine
import KipasKipasShared
import KipasKipasNetworking
import KipasKipasNetworkingUtils

typealias NewUserProfileInteractable = NewUserProfileBusinessLogic & NewUserProfileDataStore

protocol NewUserProfileBusinessLogic {
	
	func setId(id: String)
	func requestProfile(_ request: NewUserProfileModel.Request)
	func setPage(data: Int)
}

protocol NewUserProfileDataStore {
	var dataSource: NewUserProfileModel.DataSource { get set }
}

final class NewUserProfileInteractor: Interactable, NewUserProfileDataStore {
	
	var dataSource: NewUserProfileModel.DataSource
	var subscriptions = Set<AnyCancellable>()
	var presenter: NewUserProfilePresentationLogic
	var profileSubscription: AnyCancellable?
	
	var profileHeader: Profile?
	var followings: TotalFollow?
	var followers: TotalFollow?
	var profilePosts: [ProfilePostCellViewModel]?
	private let network: ProfileNetworkModel = ProfileNetworkModel()
    let uploader: MediaUploader!
	
	init(viewController: NewUserProfileDisplayLogic?, dataSource: NewUserProfileModel.DataSource) {
		self.dataSource = dataSource
		self.presenter = NewUserProfilePresenter(viewController)
        self.uploader = MainQueueDispatchDecorator(decoratee: MediaUploadManager())
	}
}


// MARK: - NewUserProfileBusinessLogic
extension NewUserProfileInteractor: NewUserProfileBusinessLogic {
	func setPage(data: Int) {
		dataSource.page = data
	}
	
	func setId(id: String) {
		dataSource.id = id
	}
	
	func requestProfile(_ request: NewUserProfileModel.Request) {
		DispatchQueue.global(qos: .userInitiated).async {
			
			switch request {
			case .profile(let id):
				self.profileHeader(id: id)
			case .fetchTotalFollower(let id):
				self.totalFollower(id: id)
			case .fetchTotalFollowing(let id):
				self.totalFollowing(id: id)
			case .fetchProfilePost(let id, let type, let isPagination):
				self.fetchProfilePost(id, type, isPagination)
            case let .uploadPicture(item):
                self.uploadPicture(media: item)
            case let .updatePicture(id, url):
                self.updatePicture(id: id, with: url)
            }
		}
	}
}


// MARK: - Private Zone
private extension NewUserProfileInteractor {
	
	func profileHeader(id: String)  {
		
		network.fetchAccount(.profile(id: id)) { [weak self] (result) in
			
			guard let self = self else {
				return
			}
			
			switch result {
			case .success(let values):
				
				self.profileHeader = values.data
				fallthrough
			default:
				self.presenter.presentResponse(.profile(result))
			}
		}
	}
	
	func totalFollower(id: String) {
		
		network.fetchFollowers(.followers(id: id)) { [weak self] (result) in
			
			guard let self = self else {
				return
			}
			
			switch result {
			case .success(let value):
				
				self.followers = value
				fallthrough
			default:
				self.presenter.presentResponse(.totalFollower(result))
			}
		}
	}
	
	func totalFollowing(id: String) {
		
		network.fetchFollowings(.followings(id: id)) { [weak self] (result) in
			
			guard let self = self else {
				return
			}
			
			switch result {
			case .success(let value):
				
				self.followings = value
				fallthrough
			default:
				self.presenter.presentResponse(.totalFollowing(result))
			}
		}
	}

	func fetchProfilePost(_ id: String, _ type: String, _ isPagination: Bool) {
		
		profileSubscription = network.requestPostAccount(.postAccount(id: id, type: type, page: dataSource.page ?? 0))
			.sink(receiveCompletion: { (completion) in
				switch completion {
				case.failure(let error): print(error.localizedDescription)
				case .finished: break
				}
			}) { [weak self] (model: ProfilePostResult) in
				guard let self = self else { return }
				
//				if isPagination {
//					self.presenter.presentResponse(.paginationPost(result: model, page: self.dataSource.page ?? 0))
//				} else {
//					self.presenter.presentResponse(.profilePosts(result: model, page: self.dataSource.page ?? 0))
//				}
		}
	}
    
    func uploadPicture(media item: KKMediaItem) {
        if ReachabilityNetwork.isConnectedToNetwork() {
            
            guard let data = item.data, let uiImage = UIImage(data: data), let ext = item.path.split(separator: ".").last else {
                self.presenter.presentResponse(.uploadPicture(data: .failure(ErrorMessage(statusCode: 0, statusMessage: "Failed to Upload", statusData: "Failed to Upload"))))
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
                    self.presenter.presentResponse(.uploadPicture(data: .success(media)))
                    return
                    
                case .failure(let error):
                    self.presenter.presentResponse(.uploadPicture(data: .failure(ErrorMessage(statusCode: 0, statusMessage: error.getErrorMessage(), statusData: error.getErrorMessage()))))
                    return
                }
            }
        } else {
            self.presenter.presentResponse(.uploadPicture(data: .failure(ErrorMessage(statusCode: 0, statusMessage: "Failed to Upload", statusData: "No Internet Connection"))))
            return
        }
    }
    
    func updatePicture(id: String, with url: String) {
        let data = EditProfile(name: nil, bio: nil, photo: url, birthDate: nil, gender: nil,  socialMedias: nil)
        network.updateAccount(.updateAccount(id: id, bio: nil, name: nil, photo: url, birthDate: nil, gender: nil, socmed: nil), data) { [weak self] (result) in
            guard let self = self else { return }
            
            switch result {
            case .success(let value):
                let url = url.replacingOccurrences(of: "tmp/", with: "")
                self.profileHeader?.photo = url
                self.presenter.presentResponse(.updatePicture(data: .success(url)))
                break
            case let .failure(error):
                self.presenter.presentResponse(.uploadPicture(data: .failure(error)))
            }
        }
    }
}
