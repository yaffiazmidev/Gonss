//
//  CommentAction.swift
//  KipasKipas
//
//  Created by PT.Koanba on 28/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import Combine
import RxSwift
import RxCocoa


class CommentSectionInteractor {
    private let network: FeedNetworkModel = FeedNetworkModel()
    private let profileNetwork = ProfileNetworkModel()
    private var subscriptions = [AnyCancellable]()
    private let usecase: FeedUseCase = Injection.init().provideFeedUseCase()
    private let disposeBag: DisposeBag = DisposeBag()
    let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
    
    
    func likeComment(postId: String, commentId: String, isLike: Bool, onSuccess: @escaping () -> (), onError: @escaping (String) -> () ) {
        
        let status : String!
        if isLike {
            status = "like"
        } else {
            status = "unlike"
        }

        network.requestLike(.commentLike(id: postId, commentId: commentId, status: status)) { [weak self] (result) in

            guard self != nil else {
                return
            }

            switch result {
            case .success(_):
                onSuccess()
            case .failure(let error):
                onError(error?.statusMessage ?? "unknown error")
            }
        }
    }
    
    func likeFeed(postId: String, isLike: Bool, onSuccess: @escaping () -> (), onError: @escaping (String) -> () ) {
        
        let status : String!
        if isLike {
            status = "like"
        } else {
            status = "unlike"
        }

        network.requestLike(.likeFeed(id: postId, status: status)) { [weak self] (result) in

            guard self != nil else {
                return
            }

            switch result {
            case .success(_):
                onSuccess()
            case .failure(let error):
                onError(error?.statusMessage ?? "unknown error")
            }
        }
    }
    
    func deleteComment(id: String, onSuccess: @escaping () -> (), onError: @escaping (String) -> ()){
        network.deleteComment(.deleteComment(id: id)) { (completion) in
            switch completion {
            case .failure(let error):
                onError(error?.statusMessage ?? "unknown error")
            case .success(_):
                onSuccess()
            }
        }
    }
    
    func mention(word: String, onSuccess: @escaping (String, String) -> (), onError: @escaping (String) -> ()) {
        profileNetwork.profileUsername(.profileUsername(text: word)).sink(receiveCompletion: { (completion) in
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
            
        }.store(in: &subscriptions)
    }
    
    func deleteFeedByID(id: String, onSuccess: @escaping () -> (), onError: @escaping (String) -> ()) {
        usecase.deleteFeedByIdRemote(id: id)
            .subscribeOn(self.concurrentBackground)
            .observeOn(MainScheduler.instance)
            .subscribe{ result in
                if (result.code == "1000") {
                    onSuccess()
                }
            } onError: { err in
                if let error = err as? ErrorMessage {
                    onError(error.statusMessage ?? "unknown error")
                    return
                }
                onError(err.localizedDescription)
            } onCompleted: {
            }.disposed(by: disposeBag)
    }
    
    func report(id: String, onReportAlreadyExist: @escaping () -> (), onReportNotExist: @escaping () -> (), onError: @escaping (String) -> ()) {
        ReportNetworkModel().checkIsReportExist(.reportsExist(id: id)) { result in
            switch result {
            
            case .success(let isExist):
                guard let dataExist = isExist.data else { return }
                if dataExist {
                    onReportAlreadyExist()
                } else {
                    onReportNotExist()
                }
            case .failure(let error):
                if let error = error {
                    onError(error.statusMessage ?? "unknown error")
                    return
                }
                onError(error?.localizedDescription ?? "unknown error")
            }
        }
    }
}
