//
//  EditProfileInteractor.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 13/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import Foundation
import UIKit
import KipasKipasShared
import KipasKipasNetworking
import KipasKipasNetworkingUtils

typealias EditProfileInteractable = EditProfileBusinessLogic & EditProfileDataStore

protocol EditProfileBusinessLogic {

	func doRequest(_ request: EditProfileModel.Request)
}

protocol EditProfileDataStore {
	var dataSource: EditProfileModel.DataSource { get }
}

final class EditProfileInteractor: Interactable, EditProfileDataStore {

	var dataSource: EditProfileModel.DataSource
	var service: ProfileNetworkModel
	var presenter: EditProfilePresentationLogic
    let uploader: MediaUploader!

	init(viewController: EditProfileDisplayLogic?, dataSource: EditProfileModel.DataSource) {
		self.dataSource = dataSource
		self.service = ProfileNetworkModel()
		self.presenter = EditProfilePresenter(viewController)
        self.uploader = MainQueueDispatchDecorator(decoratee: MediaUploadManager())
	}
}


// MARK: - EditProfileBusinessLogic
extension EditProfileInteractor: EditProfileBusinessLogic {

	func doRequest(_ request: EditProfileModel.Request) {
		DispatchQueue.global(qos: .userInitiated).async {

			switch request {

				case .getProfile(let id):
					self.getProfile(id)

				case .uploadImage(let item):
					self.uploadImage(item)
				case .updateUploadedImageUrl(let source):
					self.updateImageUrl(source)
				case let .updateProfile(bio, name, photo, birthDate, gender, socmed):
					self.updateProfile(bio, name, photo, birthDate, gender, socmed)
			}

		}
	}
}


// MARK: - Private Zone
private extension EditProfileInteractor {

	func getProfile(_ id: String) {
        
		service.getAccount(.profile(id: id)) { data in
			self.presenter.presentResponse(.getProfile(data: data))
		}
	}

	func uploadImage(_ item: KKMediaItem) {
        dataSource.item = item
        
        if ReachabilityNetwork.isConnectedToNetwork() {
            
            guard let data = item.data, let uiImage = UIImage(data: data), let ext = item.path.split(separator: ".").last else {
                self.presenter.presentResponse(.uploadImage(data: .failure(ErrorMessage(statusCode: 0, statusMessage: "Failed to Upload", statusData: "Failed to Upload"))))
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
                    self.presenter.presentResponse(.uploadImage(data: .success(media)))
                    return
                    
                case .failure(let error):
                    self.presenter.presentResponse(.uploadImage(data: .failure(ErrorMessage(statusCode: 0, statusMessage: error.getErrorMessage(), statusData: error.getErrorMessage()))))
                    return
                }
            }
        } else {
            self.presenter.presentResponse(.uploadImage(data: .failure(ErrorMessage(statusCode: 0, statusMessage: "Failed to Upload", statusData: "No Internet Connection"))))
            return
        }
	}

	func updateImageUrl(_ source: String) {
		dataSource.imageUrl = source
	}

	func updateProfile(_ bio: String,_ name: String, _ photo: String?, _ birthDate: String?, _ gender: String?, _ socmed: [SocialMedia] = []){
        let profile = EditProfile(name: name, bio: bio, photo: photo, birthDate: birthDate, gender: gender,  socialMedias: socmed)
        service.updateAccount(.updateAccount(id: dataSource.id, bio: bio, name: name, photo: photo, birthDate: birthDate, gender: gender, socmed: socmed), profile) { [weak self] data in
			guard let self = self else { return }
			
			self.presenter.presentResponse(.updateProfile(data: data))
		}
	}
}
