//
//  SceneDelegate+Profile.swift
//  KipasKipasCallApp
//
//  Created by Rahmat Trinanda Pramudya Amar on 23/12/23.
//

import Foundation
import KipasKipasCall
import KipasKipasNetworking

protocol ProfileDelegate {
    func didProfileSearch(username: String, completion: @escaping (([CallProfile]?, String?) -> Void))
    func didProfileData(userId: String, completion: @escaping ((CallProfile?, String?) -> Void))
}

extension SceneDelegate: ProfileDelegate {
    func makeProfileSearchLoader() -> CallProfileSearchLoader {
        return RemoteCallProfileSearchLoader(url: baseURL, client: authenticatedHTTPClient)
    }
    
    func makeProfileDataLoader() -> CallProfileDataLoader {
        return RemoteCallProfileDataLoader(url: baseURL, client: authenticatedHTTPClient)
    }
    
    func didProfileSearch(username: String, completion: @escaping (([CallProfile]?, String?) -> Void)) {
        makeProfileSearchLoader().load(request: CallProfileSearchLoaderRequest(username: username)) { result in
            switch result {
            case let .success(profile):
                completion(profile, nil)
            case let .failure(error):
                completion(nil, self.getErrorMessage(error))
            }
        }
    }
    
    func didProfileData(userId: String, completion: @escaping ((CallProfile?, String?) -> Void)) {
        makeProfileDataLoader().load(request: CallProfileDataLoaderRequest(userId: userId)) { result in
            switch result {
            case let .success(profile):
                completion(profile, nil)
            case let .failure(error):
                completion(nil, self.getErrorMessage(error))
            }
        }
    }
    
    private func getErrorMessage(_ error: Error) -> String {
        if let error = error as? KKNetworkError {
            switch error {
            case .connectivity:
                return "Gagal menghubungkan ke server"
            case .invalidData:
                return "Gagal memuat data"
            case .responseFailure(let error):
                return error.message
            default:
                return error.localizedDescription
            }
        }
        
        return error.localizedDescription
    }
}
