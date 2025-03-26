//
//  EditProfilePresenter.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 13/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import Foundation

protocol EditProfilePresentationLogic {
	func presentResponse(_ response: EditProfileModel.Response)
}

final class EditProfilePresenter: Presentable {
	private weak var viewController: EditProfileDisplayLogic?

	init(_ viewController: EditProfileDisplayLogic?) {
		self.viewController = viewController
	}
}


// MARK: - EditProfilePresentationLogic
extension EditProfilePresenter: EditProfilePresentationLogic {

	func presentResponse(_ response: EditProfileModel.Response) {

		switch response {
			
			case .getProfile(let data):
				presentProfile(data)
			case .uploadImage(let data):
				presentUploadResponse(data)
			case .updateProfile(data: let data):
				presentUpdateProfile(data)
		}
	}
}


// MARK: - Private Zone
private extension EditProfilePresenter {

	func presentProfile(_ data: ResultData<EditProfileResult>) {
		viewController?.displayViewModel(.getProfile(viewModelData: data))
	}

	func presentUploadResponse(_ data: ResultData<ResponseMedia>) {
		viewController?.displayViewModel(.uploadImage(viewModelData: data))
	}

	func presentUpdateProfile(_ data: ResultData<DefaultResponse>) {
		viewController?.displayViewModel(.updateProfile(data: data))
	}
}
