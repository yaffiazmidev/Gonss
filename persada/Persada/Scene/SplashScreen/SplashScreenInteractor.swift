//
//  SplashScreenInteractor.swift
//  KipasKipas
//
//  Created by Yaffi Azmi on 09/11/21.
//

import UIKit
import RxSwift
import RxCocoa

protocol SplashScreenInteractorBusinessLogic: AnyObject {
	var parameters: [String: Any]? { get }
    
    func getHomeFeedFirstPage()
}

class SplashScreenInteractor: SplashScreenInteractorBusinessLogic {
    
    var presenter: SplashScreenPresenterPresentingLogic?
    var parameters: [String: Any]?
    let disposeBag = DisposeBag()
    let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
    let feedUsecase: FeedUseCase
    
    init(presenter: SplashScreenPresenterPresentingLogic, feedUsecase: FeedUseCase) {
        self.presenter = presenter
        self.feedUsecase = feedUsecase
    }
        
    func getHomeFeedFirstPage() {
        guard ReachabilityNetwork.isConnectedToNetwork() else {
            presenter?.presentHomeFeedFirstPage([])
            return
        }
        
//        feedUsecase.getFeedNetwork(page: 0).subscribeOn(concurrentBackground).observeOn(MainScheduler.instance)
//            .subscribe { [weak self] result in
//                self?.presenter?.presentHomeFeedFirstPage([])
//            } onError: { [weak self] err in
//                self?.presenter?.presentHomeFeedFirstPage([])
//            } onCompleted: {
//            }.disposed(by: disposeBag)

        presenter?.presentHomeFeedFirstPage([])
    }
}
