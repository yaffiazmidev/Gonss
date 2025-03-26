//
//  NewSelebPresenter.swift
//  Persada
//
//  Created by Muhammad Noor on 17/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import Foundation
import RxSwift
import RxCocoa
import Kingfisher
import Alamofire


final class HomeFeedPresenter: BaseFeedPresenter {


	override var feeds: Driver<[Feed]>? {
		get {
			return getFeeds()
		}
		set {

		}
	}
	
	private func getFeeds() -> Driver<[Feed]> {
		return self.feedsDataSource
			.asDriver { error in
			return Driver.empty()
		}
	}

    fileprivate func prefetchImages(_ validData: [Feed]) {
        var urlMedias = [String]()
        for validData_ in validData {
            let urlMediaPosts = validData_.post?.medias
            
            for urlMediaPost in urlMediaPosts ?? [] {
                
                let mediaType = urlMediaPost.type
                
                var urlValid = ""
                
                if(mediaType == "image"){
                    urlValid = urlMediaPost.url ?? ""
                } else if(mediaType == "video"){
                    urlValid = urlMediaPost.thumbnail?.large ?? ""
                }
                
                if urlValid.containsIgnoringCase(find: ossPerformance) == false {
                    urlValid = urlValid + ossPerformance
                }
                urlMedias.append(urlValid)
            }
        }
        
        let urls = urlMedias.map { URL(string: $0)! }
        
        let prefetcher = ImagePrefetcher(urls: urls) {
            skippedResources, failedResources, completedResources in
        }
        prefetcher.start()
    }
    
    func getNetworkFeed() {
		_loadingState.accept(true)
		usecase.getFeedNetwork(page: requestedPage)
			.subscribeOn(self.concurrentBackground)
			.observeOn(MainScheduler.instance)
			.subscribe{ result in
				self._loadingState.accept(false)
				//TODO : SHOULD BE ENUM
				let dataWithoutReported = result.data?.content?.filter{ $0.isReported == false }
				guard let validData = dataWithoutReported else { return }
				let validFeed = self.feedsDataSource.value.filter { $0.isReported == false }
            
                self.prefetchImages(validData)

                
                FeedSimpleCache.instance.saveFeeds(feeds: validData)
                
				if (result.code == "1000") {
					if self.requestedPage == 0 {
//						self.feedsDataSource.accept(validData)
                        self.expandedRow.removeAll()
					}
					else {
						self.feedsDataSource.accept(validFeed + validData)
					}
					self.requestedPage += 1
				}
			} onError: { err in
				self._errorMessage.accept(err.localizedDescription)
                self._loadingState.accept(false)
			} onCompleted: {
			}.disposed(by: disposeBag)
	}
    
    func getMyLatestFeed() {
        usecase.getLatestFeedNetwork(userId: getIdUser())
            .subscribeOn(self.concurrentBackground)
            .observeOn(MainScheduler.instance)
            .subscribe{ result in
                guard let validData = result.data?.content else { return }
                self.feedsDataSource.accept(validData + self.feedsDataSource.value)
                self.expandedRow.removeAll()
            } onError: { err in
                self._errorMessage.accept(err.localizedDescription)
            } onCompleted: {
            }.disposed(by: disposeBag)
    }

}


// MARK: - NewSelebPresentationLogic
extension HomeFeedPresenter: FeedPresentationLogic {
	
	func presentResponse(_ response: FeedModel.Response) {
		
		switch response {
		case .stories(let story):
			presentingStories(story)
        case .publicStories(let result):
            presentingPublicStories(result)
		case .like(let result):
			changeStatusLike(result)
		case .follow(let result):
			changeStatusFollow(result)
		case .postStory(_):
			print("post story")
		case .media(_):
			print("media story")
		case .paginationSeleb(let data):
			self.presentingPaginationSeleb(data)
		case .detail(let result):
			self.presentingDetailProfile(result)
		case .unlike(let result):
			self.changeStatusUnlike(result)
        case .failedToRefreshToken:
            self.presentFailedToRefreshToken()
		}
	}
    
    func uploadView() {
        
    }
}


// MARK: - Private Zone
private extension HomeFeedPresenter {
    
    func presentFailedToRefreshToken() {
        viewController?.displayViewModel(.failedToRefreshToken)
    }
	
	func presentingDetailProfile(_ result: ProfileResult) {

		guard let validData = result.data else {
			self._errorMessage.accept(result.message)
			viewController?.displayViewModel(.emptyProfile)
			return
		}
		
		viewController?.displayViewModel(.detail(viewModel: validData))
	}
	
	func presentingPaginationSeleb(_ result: FeedArray) {

		let validData: [Feed] = result.data?.content ?? []

		viewController?.displayViewModel(.paginationSeleb(data: validData))
	}

    func presentingStories(_ story: StoryResult) {

        var stories = story.data?.feedStoryAnotherAccounts?.content ?? []
        var validData: [StoriesItem] = stories.filter {
            $0.account?.username?.containsIgnoringCase(find: "deleted") ?? false == false
        }
        
        if let myStory = story.data?.myFeedStory {
            validData.insert(myStory, at: 0)
        } else {
            let profile = Profile(accountType: nil, bio: nil, email: nil, id: "", isFollow: nil, birthDate: nil, note: nil, isDisabled: nil, isSeleb: nil, isVerified: nil, mobile: nil, name: "My Story", photo: nil, username: "My Story", isSeller: false , socialMedias: [], donationBadge: nil, referralCode: "", urlBadge: "", isShowBadge: false, chatPrice: 0)
            let story = StoriesItem(id: "", typePost: "", stories: [], createAt: 0, account: profile, isBadgeActive: false)
            
            validData.insert(story, at: 0)
        }

        StorySimpleCache.instance.saveStories(stories: validData)
		viewController?.displayViewModel(.story(viewModel: validData))
	}
    
    func presentingPublicStories(_ result: PublicStoryResult) {

        let validData = result.data?.content ?? []
//        StorySimpleCache.instance.saveStories(stories: validData)
        viewController?.displayViewModel(.story(viewModel: validData))
    }
	
	func changeStatusLike(_ data: DefaultResponse) {
		viewController?.displayViewModel(.like(viewModel: data))
	}
	
	func changeStatusUnlike(_ data: DefaultResponse) {
		viewController?.displayViewModel(.unlike(viewModel: data))
	}
	
	func changeStatusFollow(_ data: ResultData<DefaultResponse>) {
		switch data {
		case .failure(let error):
			print(error?.statusMessage ?? "")
		case .success(let result):
			viewController?.displayViewModel(.follow(viewModel: result))
		}
	}
}
