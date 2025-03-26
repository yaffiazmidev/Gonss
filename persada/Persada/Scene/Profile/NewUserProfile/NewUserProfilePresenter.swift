//
//  NewUserProfilePresenter.swift
//  Persada
//
//  Created by monggo pesen 3 on 19/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import Foundation
import RxSwift
import RxCocoa
import FeedCleeps
import Kingfisher

protocol NewUserProfilePresentationLogic {
    func presentResponse(_ response: NewUserProfileModel.Response)
}

final class NewUserProfilePresenter: Presentable {
    private weak var viewController: NewUserProfileDisplayLogic?
    private let disposeBag = DisposeBag()
    private let usecase: ProfileUseCase
    private let feedUseCase: FeedUseCase
    var identifier = ""
    var isFinishedUpdate = true
    var lastPrepareIndex = 0
    var getPostIsCalled = false
    
    var requestedPage: Int = 0
    var totalPage: Int = 0
    var userId: String = ""
    let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
    
    let feedsDataSource: BehaviorRelay<[Feed]> = BehaviorRelay<[Feed]>(value: [])
    let saveFeedsDataSource: BehaviorRelay<[Feed]> = BehaviorRelay<[Feed]>(value: [])
    var feedAlreadyShow:BehaviorRelay<[Feed]> = BehaviorRelay<[Feed]>(value: [])
    
    let _errorMessage = BehaviorRelay<String?>(value: nil)
    var errorMessage: Driver<String?> {
        return _errorMessage.asDriver()
    }
    
    let _fetchingNetwork = BehaviorRelay<Bool>(value: false)
    var fetchingNetwork: Driver<Bool> {
        return _fetchingNetwork.asDriver()
    }
    
    let _loadingState = BehaviorRelay<Bool>(value: false)
    var loadingState: Driver<Bool> {
        return _loadingState.asDriver()
    }
    
    private let _counterProfile = BehaviorRelay<TotalCountProfile?>(value: nil)
    var counterProfile: Driver<TotalCountProfile?> {
        return _counterProfile.asDriver()
    }
    
    let _account = BehaviorRelay<Profile?>(value: nil)
    var account: Driver<Profile?> {
        return _account.asDriver()
    }
    
    private let loader: FeedProfileLoader = RemoteFeedProfileLoader()
    
    init(_ viewController: NewUserProfileDisplayLogic?) {
        self.viewController = viewController
        self.usecase = Injection.init().provideProfileUseCase()
        self.feedUseCase = Injection.init().provideFeedUseCase()
    }
    
//    public func updateData(id: String) {
//        let notifyReadyFeedKey = Notification.Name(rawValue: "com.kipaskipas.notifyReadyFeedKey")
//        NotificationCenter.default.addObserver(self, selector: #selector(updateReadyToShowData), name: notifyReadyFeedKey, object: nil)
//    }
//
//    @objc func updateReadyToShowData(notification: NSNotification) {
//        if let data = notification.object as? NSDictionary {
//            if let feed = data[identifier] as? FeedCleeps.Feed {
//                DispatchQueue.main.async { [weak self] in
//                    self?.feedAlreadyShow.accept([FeedItemMapper.map(feed: feed)])
//                    self?.lastPrepareIndex += 1
//                }
//            }
//        }
//    }
    
    func getFeed(by userId: String) {
        let request = PagedFeedProfileLoaderRequest(userId: userId, page: requestedPage)
        loader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.getPostIsCalled = true
                if self.requestedPage == 0 {
                    self.lastPrepareIndex = 0
//                    ProxyServer.shared.feeds[self.identifier] = []
                    self.isFinishedUpdate = true
                }
                
                self.totalPage = (response.data?.totalPages ?? 0) - 1
                if let validData = response.data?.content?.filter({ !($0.isReported ?? false) }) as? [KipasKipas.Feed] {
                    self.feedAlreadyShow.accept(validData)
                } else {
                    self.feedAlreadyShow.accept([])
                }
            case .failure(let error):
                self.getPostIsCalled = true
                print(error.localizedDescription)
                self._errorMessage.accept(error.localizedDescription)
            }
        }
    }
    
    func getAccountNetwork(id: String) {
        usecase.getNetworkProfile(id: id)
            .subscribeOn(self.concurrentBackground)
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] result in
                guard let self = self else { return }
                
                self._account.accept(result.data)
                self.presentingProfile(ResultData.success(result))
            } onError: { err in
                self._errorMessage.accept(err.localizedDescription)
                if let error = err as? ErrorMessage, error.statusCode == 401 {
                    
                }
            } onCompleted: {
                //				self.getLocalCounter(id: id)
            }.disposed(by: disposeBag)
    }
    
    func getLocalCounter(id: String) {
//        usecase.getCounterLocal(id: id)
//            .subscribe { [weak self] result in
//                guard let self = self else { return }
//                
//                self._counterProfile.accept(result)
//            } onError: { err in
//                self._errorMessage.accept(err.localizedDescription)
//            }
//            .disposed(by: disposeBag)
    }
    
    func getNetworkCounter(id: String) {
        usecase.getCounterNetwork(id: id)
            .subscribeOn(self.concurrentBackground)
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] result in
                guard let self = self else { return }
                
                //				self.saveCounter(id: id, count: result)
                self._counterProfile.accept(result)
            } onError: { err in
                if let error = err as? ErrorMessage, error.statusCode == 401 {
                    
                }
            } onCompleted: {
                //				self.getLocalCounter(id: id)
            }
            .disposed(by: disposeBag)
    }
    
    func saveCounter(id: String, count: TotalCountProfile) {
//        usecase.saveCounterLocal(id: id, count: count)
//            .subscribeOn(self.concurrentBackground)
//            .observeOn(MainScheduler.instance)
//            .subscribe { [weak self] result in
//
//            } onError: { err in
//                self._errorMessage.accept(err.localizedDescription)
//            }.disposed(by: disposeBag)
    }
    
    func followAccount(id: String) {
        self._fetchingNetwork.accept(true)
        self._loadingState.accept(true)
        usecase.followAccount(id: id)
            .subscribeOn(self.concurrentBackground)
            .observeOn(MainScheduler.instance)
            .subscribe {  [weak self] result in
                guard let self = self else { return }
                
                self._fetchingNetwork.accept(false)
                self._loadingState.accept(false)
                self.getNetworkCounter(id: id)
            } onError: { err in
                self._errorMessage.accept(err.localizedDescription)
            }.disposed(by: disposeBag)
    }
    
    func unFollowAccount(id: String) {
        self._fetchingNetwork.accept(true)
        self._loadingState.accept(true)
        usecase.unFollowAccount(id: id)
            .subscribeOn(self.concurrentBackground)
            .observeOn(MainScheduler.instance)
            .subscribe {  [weak self] result in
                guard let self = self else { return }
                
                self._fetchingNetwork.accept(false)
                self._loadingState.accept(false)
                self.getNetworkCounter(id: id)
            } onError: { err in
                self._errorMessage.accept(err.localizedDescription)
            }.disposed(by: disposeBag)
    }
    
    func prefetchImages(_ feeds: [Feed]) {
        var urlMedias = [String]()
        
        for validData_ in feeds {
//            print("azmi: \(self.identifier) \(validData_.account?.name ?? "") media count \(validData_.post?.medias?.count ?? 0)")
            validData_.post?.medias?.forEach({ media in
                let urlMediaPost = media.thumbnail?.large ?? "urlMediaPost-nil"
                
                var urlValidBlur = ""
                
                if(urlMediaPost.containsIgnoringCase(find: ossPerformance) == false ) {
                    urlValidBlur = urlMediaPost + ossPerformance + "120"+"/blur,r_8,s_8"
                }
                
                urlMedias.append(urlValidBlur)
                
                var urlValid = ""
                
                if(urlMediaPost.containsIgnoringCase(find: ossPerformance) == false ){
                    urlValid = urlMediaPost + ossPerformance + OSSSizeImage.w720.rawValue
                }
                
                urlMedias.append(urlValid)
            })
            
            if let urlAccount = validData_.account?.photo, !urlAccount.isEmpty {
                let urlAccountOss = urlAccount + ossPerformance + OSSSizeImage.w80.rawValue
                urlMedias.append(urlAccountOss)
            }
        }
        
        let urls = urlMedias.map { URL(string: $0)! }
        
        let prefetcher = ImagePrefetcher(urls: urls) {
            skippedResources, failedResources, completedResources in
        }
        prefetcher.start()
    }
}

extension NewUserProfilePresenter: NewUserProfilePresentationLogic {
    
    func presentResponse(_ response: NewUserProfileModel.Response) {
        
        switch response {
            
        case .profile(let result):
            presentingProfile(result)
        case .totalFollower(let result):
            self.presentingTotalFollower(result)
        case .totalFollowing(let result):
            self.presentingTotalFollowing(result)
        case .uploadPicture(let data):
            self.presentingUploadPicture(data)
        case let .updatePicture(data):
            self.presentingUpdatePicture(data)
        }
    }
}


// MARK: - Private Zone
private extension NewUserProfilePresenter {
    func presentingProfile(_ data: ResultData<ProfileResult>) {
        switch data {
        case .failure(let error):
            if error?.statusCode == 401 {
                
            }
        case .success(let response):
            guard let profile = response.data else {
                return
            }
            viewController?.displayViewModel(.profile(viewModel: profile))
        }
    }
    
    func presentingTotalFollower(_ data: ResultData<TotalFollow>) {
        switch data {
        case .failure(let error):
            if error?.statusCode == 401 {
                
            }
        case .success(let response):
            viewController?.displayViewModel(.totalFollower(viewModel: response))
        }
    }
    
    func presentingTotalPost(_ data: ResultData<TotalFollow>) {
        switch data {
        case .failure(let error):
            if error?.statusCode == 401 {
                
            }
        case .success(let response):
            viewController?.displayViewModel(.totalPost(viewModel: response))
        }
    }
    
    func presentingTotalFollowing(_ data: ResultData<TotalFollow>) {
        switch data {
        case .failure(let error):
            if error?.statusCode == 401 {
                
            }
        case .success(let response):
            viewController?.displayViewModel(.totalFollowing(viewModel: response))
        }
    }
    
    func presentingUploadPicture(_ data: ResultData<ResponseMedia>) {
        switch data {
        case let .failure(error):
            viewController?.displayViewModel(.error(message: error?.statusMessage ?? "Unknown Error"))
        case let .success(response):
            viewController?.displayViewModel(.pictureUploaded(viewModel: response))
        }
    }
    
    func presentingUpdatePicture(_ data: ResultData<String>) {
        switch data {
        case let .failure(error):
            viewController?.displayViewModel(.error(message: error?.statusMessage ?? "Unknown Error"))
        case let .success(response):
            viewController?.displayViewModel(.pictureUpdated(viewModel: response))
        }
    }
}
