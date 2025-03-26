//
//  NotificationSocialPresenter.swift
//  KipasKipas
//
//  Created by movan on 13/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Combine

final class NotificationSocialPresenter {
    
    var didSelectRowTrigger = PublishSubject<IndexPath>()
    let notificationResult = BehaviorRelay<[NotificationSocial]>(value: [])
    let isEmpty = BehaviorRelay<Bool?>(value: nil)
    let notificationSize = BehaviorRelay<String>(value: "0")
    private let disposeBag = DisposeBag()
    private let router : NotificationSocialRouter!
    private let interactor = NotificationSocialInteractor()
    private var headerSubscriptions = [AnyCancellable]()
    
    var page = 0

    
    init(router : NotificationSocialRouter?) {
        
        self.router = router
        
//        didSelectRowTrigger.asObservable()
//            .observeOn(MainScheduler.asyncInstance)
//            .bind(onNext: selectRow)
//            .disposed(by: disposeBag)
        
        
        fetchNotificationResult()

    }
    
    func fetchNotificationResult(){
        // PE-13955
        guard getToken() != nil else { return }
        
        interactor.notificationSocialResponse(page: page, size: 20).subscribe { [weak self] (result) in
                    guard let self = self else { return }
                    
            if let data = result.element?.data {
                if self.page <= data.totalPages ?? 0 {
                    if self.page == 0 {
                        self.notificationResult.accept(data.content! )
                        self.isEmpty.accept(data.content?.isEmpty ?? nil)
                    } else {
                        self.notificationResult.accept(self.notificationResult.value + data.content! )
                    }

                    let totalNotifIsRead = self.notificationResult.value.filter { $0.isRead == false }.count
                    NotificationCenter.default.post(name: .notifyUpdateCounterSocial, object: ["NotifyUpdateCounterSocial" : Tampung(page: self.page, size: totalNotifIsRead)])
                    self.notificationSize.accept(String( totalNotifIsRead ))
                    
                    self.page += 1
                }
            }
        }.disposed(by: disposeBag)
    }

    func isReadNotificationSocial(id: String) {
        interactor.isReadNotification(type: "social", id: id).subscribe { [weak self] (result) in
            guard let self = self else { return }

            var notifSocialValid = self.notificationResult.value.map { item -> NotificationSocial in
                var data = item
                if id == data.id ?? "" {
                    data.isRead = true
                }
                return data
            }
            
            self.notificationResult.accept(notifSocialValid)

        }.disposed(by: disposeBag)

    }
    
    func selectRow(indexPath: IndexPath) {
        
        let item = notificationResult.value[indexPath.row]
        let id = item.feed
        let notifId = item.id
        let targetId = item.targetId
        let action : ActionType = ActionType(rawValue: (item.actionType)!)!
        let target : TargetType = TargetType(rawValue: (item.targetType)!)!
        
        isReadNotificationSocial(id: notifId ?? "")
        
        switch (action, target) {
        case (.commentSub,.feed):
            //            self.router.showSubcomment(targetId!)
            getFeedById(id: id!, onSuccess: { feed in
                if let feed = feed {
                    self.router.showComment([feed])
                    return
                }
                self.router.showComment(nil)
            })
            break
        case (.comment,.feed):
//            self.router.showComment(id!)
            getFeedById(id: id!, onSuccess: { feed in
                if let feed = feed {
                    self.router.showComment([feed])
                    return
                }
                self.router.showComment(nil)
            })
            break
        case (.mention,.commentSub):
//            self.router.showSubcomment(targetId!)
            getFeedById(id: id!, onSuccess: { feed in
                if let feed = feed {
                    self.router.showComment([feed])
                    return
                }
                self.router.showComment(nil)
            })
            break
        case (.mention,.feed):
//            self.router.showComment(id!)
            getFeedById(id: id!, onSuccess: { feed in
                if let feed = feed {
                    self.router.showComment([feed])
                    return
                }
                self.router.showComment(nil)
            })
            break
        case (.mention,.comment):
//            self.router.showComment(id!)
            getFeedById(id: id!, onSuccess: { feed in
                if let feed = feed {
                    self.router.showComment([feed])
                    return
                }
                self.router.showComment(nil)
            })
            break
        case (.like, .feed):
//            self.router.showComment(id!)
            getFeedById(id: id!, onSuccess: { feed in
                if let feed = feed {
                    self.router.showComment([feed])
                    return
                }
                self.router.showComment(nil)
            })
            break
        case (.like, .comment):
//            self.router.showComment(id!)
            getFeedById(id: id!, onSuccess: { feed in
                if let feed = feed {
                    self.router.showComment([feed])
                    return
                }
                self.router.showComment(nil)
            })
            break
        case (.like, .commentSub):
            self.router.showSubcomment(id!)
            break
        case (.follow, .follow):
                guard let accountId = item.actionAccount?.id else {
                    return
                }
                self.router.showFollow(accountId)
            break
        case (.update_badge, .donation_badge), (.unlock_badge, .donation_badge):
            showDonationRankAndBadge?(getIdUser())
        default:
            break
        }
    }
    
    func routeToShowProducts(){
        router.showProducts()
    }
    
    private func getFeedById(id: String, onSuccess: @escaping (_ feed: Feed?) -> ()) {
        FeedNetworkModel().PostDetail(.postDetail(id: id)).sink(receiveCompletion: {(completion) in
            switch completion {
            case .failure(let error):
                print(error.localizedDescription)
                if let errorMessage = error as? ErrorMessage {
                    if let code = errorMessage.statusCode {
                        if code == 404 {
                            onSuccess(nil)
                        }
                    }
                }
            case .finished: break
            }
        }) {(model: PostDetailResult) in
            onSuccess(model.data)
        }.store(in: &headerSubscriptions)
    }
}


enum ActionType : String {
    case feed
    case commentSub
    case comment
    case mention
    case like
    case follow
    case update_badge
    case unlock_badge
}

enum TargetType : String {
    case feed
    case comment
    case commentSub
    case follow
    case donation_badge
}
