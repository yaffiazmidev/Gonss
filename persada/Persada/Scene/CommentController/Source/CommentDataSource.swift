//
//  CommentInteractor.swift
//  KipasKipas
//
//  Created by PT.Koanba on 23/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import Combine
import Kingfisher
import RxSwift
import RxCocoa
import UIKit

class CommentDataSource {
    
    private let profileNetwork = ProfileNetworkModel()
    private let network: FeedNetworkModel = FeedNetworkModel()
    private var headerSubscriptions = [AnyCancellable]()
    private var subscriptions = [AnyCancellable]()
    private var addCommentSubscriptions = [AnyCancellable]()
    private var id : String?
    private var accountId : String?
    
    public var errorMessage = BehaviorRelay<String?>(value: nil)
    public var isLoading = BehaviorRelay<Bool?>(value: nil)
    public var isLoadingCommentUpdate = BehaviorRelay<Bool?>(value: nil)
    
    public var commentUpdated = BehaviorRelay<PostViewModel?>(value: nil)
    public var postViewModel = BehaviorRelay<PostViewModel?>(value: nil)
    public var followerData = BehaviorRelay<FollowerData?>(value: nil)
    public var filterFollower = BehaviorRelay<[FeedCommentMentionEntity]>(value: [])
    
    public var newsCommentUpdated = BehaviorRelay<NewsCommentViewModel?>(value: nil)
    public var newsCommentViewModel = BehaviorRelay<NewsCommentViewModel?>(value: nil)
    
    private var post: PostDetailResult?
    private var news: NewsDetailResult?
    private var comment : CommentResult?
    
    public var page = 0
    
    private var isNews = false
    
    init(id: String, isNews: Bool = false) {
        self.id = id
        self.isNews = isNews
        if isNews {
            getHeaderNewsComment()
        } else {
            getFollowings()
            getHeaderPostComment()
        }
        
    }
    
    func getFollowings() {
        profileNetwork.fetchFollowings(.listFollowings(id: getIdUser(), page: 0))
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }) { [weak self] (model: FollowerResult) in
                guard let self = self else { return }
                let result = model.data?.content?.compactMap({ FeedCommentMentionEntity(follower: $0) })
                self.filterFollower.accept(result ?? [])
        }.store(in: &subscriptions)
    }
    
    func searchAccount(_ text: String) {
        profileNetwork.searchFollowers(.searchFollowing(id: getIdUser(), name: text, page: 0))
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
        }.store(in: &subscriptions)
    }
    
    func getHeaderPostComment(){
        self.isLoading.accept(true)
        guard let id = self.id else { return }
        network.PostDetail(.postDetail(id: id)).sink(receiveCompletion: { (completion) in
            self.isLoading.accept(false)
            switch completion {
            case .failure(let error):
                print(error.localizedDescription)
                self.postViewModel.accept(nil)
                if let error = error as? ErrorMessage {
                    self.errorMessage.accept(error.statusMessage)
                    return
                }
                self.errorMessage.accept(error.localizedDescription)
            case .finished: break
            }
        }) { [weak self] (model: PostDetailResult) in
            guard let self = self else { return }
            self.post = model
            
            self.fetchComment(0)
        }.store(in: &headerSubscriptions)
    }
    
    func getHeaderNewsComment(){
        self.isLoading.accept(true)
        guard let id = self.id else { return }
        network.fetchDetailNews(.newsDetail(id: id), { [weak self] (result) in
            guard let self = self else {
                return
            }
            switch result {
            case .failure(let error):
                guard let error = error else { return }
                self.postViewModel.accept(nil)
                self.errorMessage.accept(error.localizedDescription)
            case .success(let response):
                self.news = response
                self.fetchComment(0)
            }
        })
    }
    
    func fetchComment(_ page: Int) {
        self.isLoading.accept(true)
        guard let id = self.id else { return }
        network.fetchComment(.comments(id: id, page: page)).sink(receiveCompletion: { (completion) in
            self.isLoading.accept(false)
            switch completion {
            case .failure(let error):
                print(error.localizedDescription)
                self.postViewModel.accept(nil)
                if let error = error as? ErrorMessage {
                    self.errorMessage.accept(error.statusMessage)
                    return
                }
                self.errorMessage.accept(error.localizedDescription)
            case .finished: break
            }
        }) { [weak self] (model: CommentResult) in
            guard let self = self else { return }
            self.comment = model
            self.comment?.data?.content?.reverse()
            
            if self.isNews {
                guard let news = self.news, let comment = self.comment else { return }
                self.mappingResponseToNewsViewModel(news: news, comment: comment)
            } else {
                guard let post = self.post, let comment = self.comment else { return }
                self.mappingResponseToPostViewModel(post: post, comment: comment)
            }
        }.store(in: &subscriptions)
    }
    
    
    func updateComment(){
        self.isLoadingCommentUpdate.accept(true)
        guard let id = self.id else { return }
        network.fetchComment(.comments(id: id, page: 0)).sink(receiveCompletion: { (completion) in
            self.isLoadingCommentUpdate.accept(false)
            switch completion {
            case .failure(let error):
                print(error.localizedDescription)
                self.postViewModel.accept(nil)
                if let error = error as? ErrorMessage {
                    self.errorMessage.accept(error.statusMessage)
                    return
                }
                self.errorMessage.accept(error.localizedDescription)
            case .finished: break
            }
        }) { [weak self] (model: CommentResult) in
            guard let self = self else { return }
            self.comment = model
            
            guard let comment = self.comment else { return }
            self.mappingResponseToViewModel(comment: comment)
        }.store(in: &subscriptions)
    }
    
    
    func addComment(id: String, value: String, onSuccess: @escaping () -> Void, onError: @escaping (String) -> Void){
        network.addComment(.addComment(id: id, value: value)) { [weak self] (result) in
            guard self != nil else { return }

            switch result {
            case .success(_):
                onSuccess()
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


// Mapping Data
extension CommentDataSource {
    func mappingResponseToPostViewModel(post: PostDetailResult, comment: CommentResult) {
        
        guard let data = post.data else { return }
        guard let createdAt = data.createAt else { return }
        guard let id = data.id else { return }
        guard let account = data.account else { return }
        guard let post = data.post else { return }
        
        
       
        var mediaItemViewModel : [MediaItemViewModel] = []
        
        
        
        guard let medias = post.medias else { return }
        for media in medias {
            guard let thumbnail = media.thumbnail?.small else { return }
            guard var url = media.thumbnail?.medium else { return }
            
            
            let urls = [url]
                       .map { URL(string: $0)! }
            if media.type == "image" {
                let prefetcher = ImagePrefetcher(urls: urls) {
                    skippedResources, failedResources, completedResources in
                    print("These resources are prefetched: \(completedResources)")
                }
                prefetcher.start()
                
               
            } else {
                guard let videoUrl = media.url else { return }
                url = videoUrl
            }
           
            

            
            mediaItemViewModel.append(MediaItemViewModel(thumbnail: thumbnail, url: url, isVideo: media.type == "video" ? true : false))
        }
        
        let height: Double = Double(medias.first?.metadata?.height ?? "1920") ?? 1920
        let width: Double = Double(medias.first?.metadata?.width ?? "1920") ?? 1920
        let ratio = width / height
        var newHeight = UIScreen.main.bounds.width / CGFloat(ratio)
        let acceptableHeight = UIScreen.main.bounds.height * 0.7
        if newHeight > acceptableHeight {
            newHeight = acceptableHeight
        }
        
        let media = MediaViewModel(media: mediaItemViewModel, isHaveProduct: post.product != nil, productID: post.product?.id, height: Int(newHeight), price: post.product?.price?.toMoney() ?? "")
        
        let isOnWikipedia = account.socialMedias?.contains(where: { socialmedia in
            socialmedia.socialMediaType == SocialMediaType.wikipedia.rawValue
        })
        
        let wikiURL = account.socialMedias?.filter({ socialmedia in
            socialmedia.socialMediaType == SocialMediaType.wikipedia.rawValue
        }).first
        
        let user = UserViewModel(userPhoto: account.photo ?? "", userName: account.username ?? "", type: account.accountType ?? "social", userID: account.id ?? "", isHaveShop: data.isProductActiveExist ?? false, isOnWikipedia: isOnWikipedia ?? false, wikipediaURL: wikiURL?.urlSocialMedia ?? "", isVerified: account.isVerified ?? false, account: account)
        
        
        guard let date = TimeFormatHelper.soMuchTimeAgoNew(date: createdAt) else { return }
        
        guard let likes = data.likes else { return }
        guard let comments = data.comments else { return }
        guard let isLike = data.isLike else { return }
        let likeCommentViewModel = LikeAndCommentViewModel(totalLikes: likes, totalComment: comments, isLiked: isLike)
        
        var commentViewModel : [CommentViewModel] = []
        
        guard let commentList = comment.data?.content else { return }
        for com in commentList {
            
            guard let id = com.id else { return }
            guard let photo = com.account?.photo else { return }
            guard let name = com.account?.username else { return }
            guard let createAt = com.createAt else { return }
            guard let date = TimeFormatHelper.soMuchTimeAgoNew(date: createAt) else { return }
            guard let value = com.value else { return }
            guard let isLike = com.isLike else { return }
			guard let isReported = com.isReported else { return }
            guard let likes = com.like else { return }
            guard let comments = com.commentSubs?.count else { return }
            
			if isReported == false {
				commentViewModel.append(CommentViewModel(commentID: id, userPhoto: photo, userName: name, date: date, comment: value, isLike: isLike, isReported: isReported, totalLikes: likes, totalComment: comments, userID: id, type: com.account?.accountType ?? "social", createAt: createAt))
			}
        }
        
        let emptyCommentViewModel = EmptyCommentViewModel(isEmpty: commentViewModel.isEmpty)
        
        let postVM = PostViewModel(postID: id, user: user, media: media, caption: CaptionViewModel(userName: account.username ?? "", caption: post.postDescription ?? "", date: date), action: likeCommentViewModel, comments: commentViewModel, emptyComment: emptyCommentViewModel)
        postViewModel.accept(postVM)
    }
    
    func mappingResponseToNewsViewModel(news: NewsDetailResult, comment: CommentResult) {
        
        guard let data = news.data else { return }
        guard let createdAt = data.createAt else { return }
        guard let id = data.id else { return }
        guard let postNews = data.postNews else { return }
        
        let date = "\(TimeFormatHelper.epochConverter(date: "", epoch: Double(createdAt), format: "dd MMMM yyyy"))"
        let newsHeaderViewModel = NewsHeaderViewModel(title: postNews.title ?? "", date: date, source: postNews.siteReference ?? "", mediaURL: postNews.medias?.first?.url ?? "", type: postNews.medias?.first?.type ?? "", thumbnail: postNews.medias?.first?.thumbnail?.small ?? "")
        
        let newsAuthorViewModel = NewsAuthorViewModel(editor: postNews.editor ?? "", author: postNews.author ?? "" )
        
        var commentViewModel : [CommentViewModel] = []
        
        guard let commentList = comment.data?.content else { return }
        for com in commentList {
            
            guard let id = com.id else { return }
            guard let photo = com.account?.photo else { return }
            guard let name = com.account?.username else { return }
            guard let createAt = com.createAt else { return }
            guard let date = TimeFormatHelper.soMuchTimeAgoNew(date: createAt) else { return }
            guard let value = com.value else { return }
            guard let isLike = com.isLike else { return }
            guard let isReported = com.isReported else { return }
            guard let likes = com.like else { return }
            guard let comments = com.commentSubs?.count else { return }
            
            commentViewModel.append(CommentViewModel(commentID: id, userPhoto: photo, userName: name, date: date, comment: value, isLike: isLike, isReported: isReported, totalLikes: likes, totalComment: comments, userID: id, type: com.account?.accountType ?? "social", createAt: createAt))
        }
        
        let emptyCommentViewModel = EmptyCommentViewModel(isEmpty: commentViewModel.isEmpty)
        
        let newsVM = NewsCommentViewModel(postID: id, newsHeader: newsHeaderViewModel, newsAuthor: newsAuthorViewModel, comments: commentViewModel, emptyComment: emptyCommentViewModel)
        
        self.newsCommentViewModel.accept(newsVM)
    }
    
    func mappingResponseToViewModel(comment: CommentResult) {
        
      
        var commentViewModel : [CommentViewModel] = []
        
        guard let commentList = comment.data?.content else { return }
        for com in commentList {
            
            guard let id = com.id else { return }
            guard let photo = com.account?.photo else { return }
            guard let name = com.account?.username else { return }
            guard let createAt = com.createAt else { return }
            guard let date = TimeFormatHelper.soMuchTimeAgoNew(date: createAt) else { return }
            guard let value = com.value else { return }
            guard let isLike = com.isLike else { return }
			guard let isReported = com.isReported else { return }
            guard let likes = com.like else { return }
            guard let comments = com.comments else { return }
            
			if isReported == false {
				commentViewModel.append(CommentViewModel(commentID: id, userPhoto: photo, userName: name, date: date, comment: value, isLike: isLike, isReported: isReported, totalLikes: likes, totalComment: comments, userID: id, type: com.account?.accountType ?? "social", createAt: createAt))
			}
        }
        
        if isNews {
            let newsVM = self.newsCommentViewModel.value
            newsVM?.comments = commentViewModel
            newsCommentUpdated.accept(newsVM)
        } else {
            let postVM = self.postViewModel.value
            postVM?.comments = commentViewModel
            commentUpdated.accept(postVM)
        }
    }
}
