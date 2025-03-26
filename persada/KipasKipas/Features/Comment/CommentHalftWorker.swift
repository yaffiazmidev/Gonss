//
//  CommentHalftWorker.swift
//  KipasKipas
//
//  Created by DENAZMI on 18/08/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

protocol ICommentHalftWorker {
    typealias CompletionHandler<T> = (Swift.Result<T, DataTransferError>) -> Void
    
    func getComments(postId: String, page: Int, completion: @escaping CompletionHandler<RemoteCommentEntity?>)
    func addComment(postId: String, with value: String, completion: @escaping CompletionHandler<DefaultEntity?>)
    func deleteComment(id: String, completion: @escaping CompletionHandler<DefaultEntity?>)
    func likeComment(postId: String, id: String, status: String, completion: @escaping CompletionHandler<DefaultEntity?>)
    func addSubcomment(postId: String, commentId: String, with value: String, completion: @escaping CompletionHandler<DefaultEntity?>)
    func deleteSubcomment(id: String, completion: @escaping CompletionHandler<DefaultEntity?>)
    func likeSubcomment(postId: String, id: String, status: String, completion: @escaping CompletionHandler<DefaultEntity?>)
    func getAcoount(by username: String, completion: @escaping CompletionHandler<ProfileResult?>)
    func getFollowing(completion: @escaping CompletionHandler<RemoteFollowingItem?>)
}

class CommentHalftWorker: ICommentHalftWorker {
    
    private let network: DataTransferService
    
    init(network: DataTransferService) {
        self.network = network
    }
    
    func getComments(postId: String, page: Int, completion: @escaping CompletionHandler<RemoteCommentEntity?>) {
        let request = Endpoint<RemoteCommentEntity?>(with: CommentAPIEndpoint.comments(postId: postId, page: page))
        network.request(with: request, completion: completion)
    }
    
    func addComment(postId: String, with value: String, completion: @escaping CompletionHandler<DefaultEntity?>) {
        let request = Endpoint<DefaultEntity?>(with: CommentAPIEndpoint.addComment(postId: postId, value: value))
        network.request(with: request, completion: completion)
    }
    
    func deleteComment(id: String, completion: @escaping CompletionHandler<DefaultEntity?>) {
        let request = Endpoint<DefaultEntity?>(with: CommentAPIEndpoint.deleteComment(id: id))
        network.request(with: request, completion: completion)
    }
    
    func likeComment(postId: String, id: String, status: String, completion: @escaping CompletionHandler<DefaultEntity?>) {
        let request = Endpoint<DefaultEntity?>(with: CommentAPIEndpoint.likeComment(postId: postId, commentId: id, status: status))
        network.request(with: request, completion: completion)
    }
    
    func addSubcomment(postId: String, commentId: String, with value: String, completion: @escaping CompletionHandler<DefaultEntity?>) {
        let request = Endpoint<DefaultEntity?>(with: CommentAPIEndpoint.addSubcomment(postId: postId, commentId: commentId, value: value))
        network.request(with: request, completion: completion)
    }
    
    func deleteSubcomment(id: String, completion: @escaping CompletionHandler<DefaultEntity?>) {
        let request = Endpoint<DefaultEntity?>(with: CommentAPIEndpoint.deleteSubcomment(id: id))
        network.request(with: request, completion: completion)
    }
    
    func likeSubcomment(postId: String, id: String, status: String, completion: @escaping CompletionHandler<DefaultEntity?>) {
        let request = Endpoint<DefaultEntity?>(with: CommentAPIEndpoint.likeSubcomment(postId: postId, subcommentId: id, status: status))
        network.request(with: request, completion: completion)
    }
    
    func getAcoount(by username: String, completion: @escaping CompletionHandler<ProfileResult?>) {
        let request = Endpoint<ProfileResult?>(with: CommentAPIEndpoint.profile(username: username))
        network.request(with: request, completion: completion)
    }
    
    func getFollowing(completion: @escaping CompletionHandler<RemoteFollowingItem?>) {
        let endpoint = Endpoint<RemoteFollowingItem?>(
            path: "profile/\(getIdUser())/following",
            method: .get,
            headerParamaters: [
                "Authorization" : "Bearer \(getToken() ?? "")",
                "Content-Type":"application/json"
            ],
            queryParameters: ["page" : "0", "size": "10"]
        )
        
        network.request(with: endpoint, completion: completion)
    }
}
