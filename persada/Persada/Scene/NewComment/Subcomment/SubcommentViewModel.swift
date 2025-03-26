//
//  SubcommentViewModel.swift
//  KipasKipas
//
//  Created by Yaffi Azmi on 14/09/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import Combine
import RxSwift
import RxCocoa

class SubcommentViewModel {
    
    private let feedNetwork: FeedNetworkModel?
    private let profileNetwork: ProfileNetworkModel?
    private var subcommentsubscriptions = Set<AnyCancellable>()
    var subcommentDataSource: SubcommentModel.SubcommentDataSource?
    
    var subCommentResult = BehaviorRelay<SubcommentResult?>(value: nil)
    var isSuccessCommentLike = BehaviorRelay<Bool>(value: false)
    var isSuccessSendComment = BehaviorRelay<Bool?>(value: nil)
    public var filterFollower = BehaviorRelay<[FeedCommentMentionEntity]>(value: [])
    
    init(subcommentDataSource: SubcommentModel.SubcommentDataSource?, feedNetwork: FeedNetworkModel, profileNetwork: ProfileNetworkModel) {
        self.feedNetwork = feedNetwork
        self.profileNetwork = profileNetwork
        self.subcommentDataSource = subcommentDataSource
    }
    
    func searchAccount(_ text: String) {
        profileNetwork?.searchFollowers(.searchFollowing(id: getIdUser(), name: text, page: 0))
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .finished:
                    break
                case .failure(let error): print(error.localizedDescription)
                }
            }) { [weak self] (model: FollowerResult) in
                guard let self = self else { return }
                let result = model.data?.content?.compactMap({ FeedCommentMentionEntity(follower: $0) })
                self.filterFollower.accept(result ?? [])
        }.store(in: &subcommentsubscriptions)
    }
    
    func mention(word: String, onSuccess: @escaping (String, String) -> (), onError: @escaping (String) -> ()) {
        profileNetwork?.profileUsername(.profileUsername(text: word)).sink(receiveCompletion: { (completion) in
            switch completion {
            case .failure(let error):
                if let error = error as? ErrorMessage {
                    onError(error.statusMessage ?? "unknown error")
                    return
                }
                onError(error.localizedDescription)
            case .finished: break
            }
        }) { [weak self] (model: ProfileResult) in
            guard self != nil else { return }
            guard let id = model.data?.id else { return }
            onSuccess(id, model.data?.accountType ?? "social")
            
        }.store(in: &subcommentsubscriptions)
    }
    
    func fetchSubcomment() {
        feedNetwork?.fetchSubcomment(.subcomment(id: subcommentDataSource?.id ?? "", page: 0)).sink(receiveCompletion: { (completion) in
            switch completion {
            case .failure(let error): print(error.localizedDescription)
                fallthrough
            case .finished: break
            }
        }) { [weak self] (model: SubcommentResult) in
            self?.subCommentResult.accept(model)
        }.store(in: &subcommentsubscriptions)
    }
    
    func requestLike(postId: String, id: String, status: String) {
        feedNetwork?.requestLike(.subcommentLike(id: postId, subcommentId: id, status: status)) { [weak self] (result) in
            switch result {
            case .success(let value):
                print("---\(value)")
                self?.fetchSubcomment()
            case .failure(let error):
                print("---\(error?.localizedDescription ?? "Something wrong!")")
            }
        }
    }

    func deleteComment(id: String) {
        feedNetwork?.deleteComment(.deleteComment(id: id)) { [weak self] (result) in
            switch result {
            case .success(let value):
                print("---\(value)")
                self?.fetchSubcomment()
            case .failure(let error):
                print("---\(error?.localizedDescription ?? "Something wrong!")")
            }
        }
    }
    
    func deleteSubComment(id: String) {
        feedNetwork?.deleteSubComment(.deleteSubComment(id: id)) { [weak self] (result) in
            switch result {
            case .success(let value):
                print("---\(value)")
                self?.fetchSubcomment()
            case .failure(let error):
                print("---\(error?.localizedDescription ?? "Something wrong!")")
            }
        }
    }
    
    func addSubcomment(_ postId: String, _ commentId: String, value: String, onSuccess: @escaping (Bool) -> ()) {
        feedNetwork?.addSubcomment(.addSubcomment(id: postId, commentId: commentId, value: value)) { (result) in
            switch result {
            case .success(_):
                print("---\(value)")
                onSuccess(true)
            case .failure(let error):
                onSuccess(false)
                print("---\(error?.localizedDescription ?? "Something wrong!")")
            }
        }
    }
}
