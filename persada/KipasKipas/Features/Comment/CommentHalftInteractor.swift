//
//  CommentHalftInteractor.swift
//  KipasKipas
//
//  Created by DENAZMI on 08/08/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

protocol ICommentHalftInteractor {
    var page: Int { get set }
    var totalPage: Int { get set }
    var postId: String? { get set }
    var totalComments: Int { get set }
    
    func fetchComments()
    func addComment(with value: String)
    func replyComment(commentId: String, with value: String)
    func deleteComment(id: String)
    func deleteSubcomment(commentId: String, id: String)
    func likeComment(id: String, status: String)
    func likeSubcomment(id: String, status: String)
    func profile(with username: String)
    func requestFollowing()
}

class CommentHalftInteractor: ICommentHalftInteractor {
    
    var page: Int = 0
    var totalPage: Int = 0
    var postId: String?
    var totalComments: Int = 0
    
    let presenter: ICommentHalftPresenter
    let worker: ICommentHalftWorker
    
    init(presenter: ICommentHalftPresenter, worker: ICommentHalftWorker) {
        self.presenter = presenter
        self.worker = worker
    }
    
    func fetchComments() {
        worker.getComments(postId: postId ?? "", page: page) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                self.totalComments = response?.data?.totalElements ?? 0
                self.totalPage = (response?.data?.totalPages ?? 0) - 1
                self.page != 0 ? self.presenter.presentCommentsNextPage(with: response) : self.presenter.presentComments(with: response)
            }
        }
    }
    
    func addComment(with value: String) {
        worker.addComment(postId: postId ?? "", with: value) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(_):
                self.handleSuccessAddComment()
            }
        }
    }
    
    private func handleSuccessAddComment() {
        page = 0
        worker.getComments(postId: postId ?? "", page: page) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                self.totalPage = (response?.data?.totalPages ?? 0) - 1
                self.presenter.presentSuccessSendComment(with: response)
            }
        }
    }
    
    func replyComment(commentId: String, with value: String) {
        worker.addSubcomment(postId: postId ?? "", commentId: commentId, with: value) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(_):
                self.page = 0
                self.fetchComments()
            }
        }
    }
    
    func deleteComment(id: String) {
        worker.deleteComment(id: id) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(_):
                self.presenter.presentSuccessDeleteComment(id: id)
            }
        }
    }
    
    func likeComment(id: String, status: String) {
        worker.likeComment(postId: postId ?? "", id: id, status: status) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(_):
                break
            }
        }
    }
    
    func deleteSubcomment(commentId: String, id: String) {
        worker.deleteSubcomment(id: id) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(_):
                self.presenter.presentSuccessDeleteSubcomment(commentId: commentId, id: id)
            }
        }
    }
    
    func likeSubcomment(id: String, status: String) {
        worker.likeSubcomment(postId: postId ?? "", id: id, status: status) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(_):
                break
            }
        }
    }
    
    func profile(with username: String) {
        worker.getAcoount(by: username) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                self.presenter.presentEmptyProfile()
            case .success(let resultProfile):
                guard let profile = resultProfile?.data else { return }
                self.presenter.presentProfileWithUsername(profile: profile)
            }
        }
    }
    
    func requestFollowing() {
        worker.getFollowing() { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                self.presenter.presentFollowing(with: response)
            }
        }
    }
}
