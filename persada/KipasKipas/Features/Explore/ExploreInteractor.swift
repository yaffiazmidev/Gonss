//
//  ExploreInteractor.swift
//  KipasKipas
//
//  Created by DENAZMI on 07/03/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import Kingfisher

protocol IExploreInteractor: AnyObject {
    var page: Int { get set }
    var totalPage: Int { get set }
    
    func fetchChannels()
    func fetchExplorePosts()
    func loadMoreExplorePosts()
    func prefetchImages(_ feeds: [Feed])
}

class ExploreInteractor: IExploreInteractor {
    
    let presenter: IExplorePresenter
    let channelsGeneralPostsLoader: ChannelsGeneralPostsLoader
    let channelsLoader: ChannelsLoader
    let channelDetailLoader: ChannelDetailLoader
    
    var page: Int = 0
    var totalPage: Int = 0
    
    init(presenter: IExplorePresenter,
         channelsLoader: ChannelsLoader,
         channelDetailLoader: ChannelDetailLoader,
         channelsGeneralPostsLoader: ChannelsGeneralPostsLoader)
    {
        self.presenter = presenter
        self.channelsLoader = channelsLoader
        self.channelDetailLoader = channelDetailLoader
        self.channelsGeneralPostsLoader = channelsGeneralPostsLoader
    }
    
    func fetchChannels() {
        channelsLoader.load(request: ChannelsRequest(page: 0, isPublic: !AUTH.isLogin())) { [weak self] result in
            guard let self = self else { return }
            
            self.presenter.presentChannels(with: result)
        }
    }
    
    func fetchExplorePosts() {
        let request = ChannelsGeneralPostsRequest(page: page, isPublic: !AUTH.isLogin())
        channelsGeneralPostsLoader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            self.presenter.presentExplorePost(with: result)
            
            if case .success(let response) = result {
                self.totalPage = response.totalPage
            }
        }
    }
    
    func loadMoreExplorePosts() {
        page += 1
        fetchExplorePosts()
    }
    
    func prefetchImages(_ feeds: [Feed]) {
        var urlMedias = [String]()
        
        for validData_ in feeds {
            validData_.post?.medias?.forEach({ media in
                let urlMediaPost = media.thumbnail?.large ?? "urlMediaPost-nil"
                
                var urlValidBlur = ""
                
                if(urlMediaPost.containsIgnoringCase(find: ossPerformance) == false ) {
                    urlValidBlur = urlMediaPost + ossPerformance + "120" + "/blur,r_8,s_8"
                }
                                
                urlMedias.append(urlValidBlur)
                
                var urlValid = ""
                
                if(urlMediaPost.containsIgnoringCase(find: ossPerformance) == false ){
                    //urlValid = urlMediaPost + ossPerformance + OSSSizeImage.w720.rawValue
                    urlValid = urlMediaPost + ossPerformance + OSSSizeImage.w240.rawValue
                }
                
                //print("**===tprefetch urlMediaPost", urlValid)
                
                urlMedias.append(urlValid)
            })
            
            if let urlAccount = validData_.account?.photo, !urlAccount.isEmpty {
                let urlAccountOss = urlAccount + ossPerformance + OSSSizeImage.w80.rawValue
                urlMedias.append(urlAccountOss)
            }
        }
        print("hastags \(urlMedias)")
        let urls = urlMedias.map { URL(string: $0)! }
        
        let prefetcher = ImagePrefetcher(urls: urls) {
            skippedResources, failedResources, completedResources in
        }
        prefetcher.start()
    }
}
