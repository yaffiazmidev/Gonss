//
//  ProfilePresenter.swift
//  KipasKipas
//
//  Created by DENAZMI on 24/12/23.
//

import UIKit
import FeedCleeps
import KipasKipasNetworking

protocol IProfilePresenter {
    typealias Completion<T> = Swift.Result<T, Error>
    
    func presentUserProfile(with result: Completion<RemoteUserProfileData>)
    func presentUserProfileMutual(with result: Completion<RemoteAcountMutualData>)
    func presentUserProfilePost(with result: Completion<RemoteFeedItemData>)
    func presentUserProfileUploadPicture(with result: Completion<ResponseMedia>)
    func presentUserProfileUpdatePicture(with result: Completion<String>)
    func presentUpdateIsFollow(with result: Completion<DefaultItem>)
    func presentProductsEtalse(with result: Completion<ProductArrayItem>)
}

class ProfilePresenter: IProfilePresenter {
	weak var controller: IProfileViewController?
	
	init(controller: IProfileViewController) {
		self.controller = controller
	}
    
    func presentUserProfile(with result: Completion<RemoteUserProfileData>) {
        switch result {
        case .success(let response):
            controller?.displayUserProfile(data: response)
        case .failure(let error): 
//            controller?.displayError(error.localizedDescription)
            controller?.displayErrorUserProfile()
            print(error.localizedDescription)
        }
    }
    
    func presentUserProfileMutual(with result: Completion<RemoteAcountMutualData>){
        switch result {
        case .success(let response): 
            controller?.displayUserProfileMutual(data: response)
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    
    func presentUserProfilePost(with result: Completion<RemoteFeedItemData>) {
        switch result {
        case .success(let response):
            controller?.displayUserProfilePosts(contents: response.content ?? [])
        case .failure(let error):
            controller?.displayError(error.localizedDescription)
            print(error.localizedDescription)
        }
    }
    
    func presentUserProfileUploadPicture(with result: Completion<ResponseMedia>) {
        switch result {
        case let .failure(error):
            controller?.displayError(error.getErrorMessage())
        case let .success(response):
            controller?.displayUserProfileUploadedPicture(data: response)
        }
    }
    
    func presentUserProfileUpdatePicture(with result: Completion<String>) {
        switch result {
        case let .failure(error):
            controller?.displayError(error.getErrorMessage())
        case let .success(response):
            controller?.displayUserProfileUpdatedPicture(data: response)
        }
    }
    
    func presentUpdateIsFollow(with result: Completion<DefaultItem>) {
        switch result {
        case let .failure(error):
            controller?.displayError(error.getErrorMessage())
        case .success(_):
            controller?.displayUpdatedIsFollow()
        }
    }
    
    func presentProductsEtalse(with result: Completion<ProductArrayItem>) {
        switch result {
        case let .failure(error):
//            controller?.displayError(error.getErrorMessage())
            print(error.localizedDescription)
        case let .success(response):
            let productItems = response.data.compactMap({
                ShopViewModel(
                    id: $0.id,
                    name: $0.name,
                    price: $0.price,
                    ratingAverage: $0.ratingAverage,
                    ratingCount: $0.ratingCount,
                    totalSales: $0.totalSales,
                    metadataHeight: Double($0.medias?.first?.metadata?.height ?? "0"),
                    metadataWidth: Double($0.medias?.first?.metadata?.width ?? "0"),
                    city: $0.city ?? "",
                    isShowCity: true,
                    imageURL: $0.medias?.first?.thumbnail?.medium ?? ""
                )
            })
            controller?.displayProductEtalase(products: productItems)
        }
    }
}
