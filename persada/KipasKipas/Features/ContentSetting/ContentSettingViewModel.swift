//
//  ContentSettingViewModel.swift
//  KipasKipas
//
//  Created by DENAZMI on 21/02/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import Foundation
import SendbirdChatSDK
import KipasKipasDirectMessage
import RxSwift

protocol ContentSettingUsecase: AnyObject {
    func requestFollower()
    func sendContentToDM(userId: String, message: String)
    func deletePost(with id: String?)
}

protocol ContentSettingViewModelDelegate: AnyObject {
    func displayFollowers(with response: [RemoteFollowingContent])
    func displayError(with message: String)
    func displaySendContent(userId: String)
    func displayErrorDeletePost(with message: String)
    func displaySuccessDeletePost(id: String?)
}

class ContentSettingViewModel: ContentSettingUsecase {
    
    weak var delegate: ContentSettingViewModelDelegate?
    private let network: DataTransferService
    private(set) lazy var channelUseCase = CreateGroupChannelUseCase()
    private(set) lazy var feedUseCase: FeedUseCase = Injection.init().provideFeedUseCase()
    let disposeBag = DisposeBag()
    let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
    
    init(network: DataTransferService) {
        self.network = DIContainer.shared.apiDataTransferService
    }
    
    func requestFollower() {
        let endpoint = Endpoint<RemoteFollowingItem?>(
            path: "profile/\(getIdUser())/following",
            method: .get, 
            headerParamaters: [
                "Authorization" : "Bearer \(getToken() ?? "")",
                "Content-Type":"application/json"
            ],
            queryParameters: ["page" : "0", "size": "10"]
        )
        
        network.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.delegate?.displayFollowers(with: response?.data?.content ?? [])
            case .failure(let error):
                self.delegate?.displayError(with: error.message)
            }
        }
    }
    
    func sendContentToDM(userId: String, message: String) {
        createChannel(with: userId) { [weak self] (channel, errorMessage) in
            guard let self = self else { return }
            
            if let errorMessage = errorMessage {
                self.delegate?.displayError(with: errorMessage)
                return
            }
            
            guard let channel = channel else {
                self.delegate?.displayError(with: "Error: Failed to create conversation..)")
                return
            }
            
            sendMessageToDM(channel: channel, with: message) { isSuccess in
                guard isSuccess else {
                    self.delegate?.displayError(with: "Error: Failed to send this content..)")
                    return
                }
                
                self.delegate?.displaySendContent(userId: userId)
            }
        }
    }
    
    func deletePost(with id: String?) {
        feedUseCase.deleteFeedById(id: id ?? "")
            .subscribeOn(concurrentBackground)
            .observeOn(MainScheduler.instance)
            .subscribe{ result in
                //                guard let self = self else { return }
                //                self._loadingState.accept(false)
            } onError: { [weak self] err in
                guard let self = self else { return }
                self.delegate?.displayErrorDeletePost(with: err.localizedDescription)
            } onCompleted: { [weak self] in
                guard let self = self else { return }
                self.delegate?.displaySuccessDeletePost(id: id)
            }.disposed(by: disposeBag)
    }
}

extension ContentSettingViewModel {
    
    private func sendMessageToDM(channel: GroupChannel, with message: String, completion: @escaping ((Bool) -> Void)) {
        let mobileMessageId = UUID().uuidString
        
        let params = UserMessageCreateParams(message: message)
        params.data = "{\"isPaid\":false,\"messageId\":\"\(mobileMessageId)\"}"
        
        GroupChannelUserMessageUseCase(channel: channel).sendMessage(params: params) { result in
            switch result {
            case .success(_): 
                completion(true)
            case .failure(_): 
                completion(false)
            }
        }
    }
    
    private func createChannel(with userId: String?, completion: @escaping ((GroupChannel?, String?) -> Void)) {
        guard let userId = userId, !userId.isEmpty else {
            completion(nil, "Error: User not found..")
            return
        }
        
        channelUseCase.createGroupChannel(selectedUserId: userId) { result in
            switch result {
            case .success(let response):
                
                guard let channel = response else {
                    completion(nil, "Error: Data not found..")
                    return
                }
                
                completion(channel, nil)
            case .failure(let error):
                let errorMessage = "Error: Failed to create conversation, \(error.localizedDescription)"
                completion(nil, errorMessage)
            }
        }
    }
}
