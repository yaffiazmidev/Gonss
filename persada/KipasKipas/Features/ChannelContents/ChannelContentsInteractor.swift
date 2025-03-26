//
//  ChannelContentsInteractor.swift
//  KipasKipas
//
//  Created by DENAZMI on 08/09/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import Kingfisher

protocol IChannelContentsInteractor {
    var page: Int { get set }
    var totalPage: Int { get set }
    var channelId: String { get set }
    var isLastPage: Bool { get set }

    func fetchChannelDetail()
    func fetchContents()
    func followChannel()
    func unfollowChannel()
    func loadMoreContents()
    func prefetchImages(_ feeds: [Feed])
}

class ChannelContentsInteractor: IChannelContentsInteractor {

    let presenter: IChannelContentsPresenter
    let worker: IChannelContentsWorker

    var page: Int = 0
    var totalPage: Int = 0
    var channelId: String = ""
    var isLastPage = false

    init(presenter: IChannelContentsPresenter, worker: IChannelContentsWorker) {
        self.presenter = presenter
        self.worker = worker
    }
    
    func followChannel() {
        worker.followChannel(with: channelId) { [weak self] result in
            guard let self = self else { return }
            self.presenter.presentFollowChannel(with: result)
        }
    }
    
    func unfollowChannel() {
        worker.unfollowChannel(with: channelId) { [weak self] result in
            guard let self = self else { return }
            self.presenter.presentUnfollowChannel(with: result)
        }
    }
    
    func fetchChannelDetail() {
        worker.getChannel(with: channelId) { [weak self] result in
            guard let self = self else { return }
            self.presenter.presentChannelDetail(with: result)
        }
    }

    func fetchContents() {
        worker.getChannelContents(with: channelId, page: page) { [weak self] result in
            guard let self = self else { return }
            self.presenter.presentContents(with: result)
            if case .success(let response) = result, let data = response.data {
                self.isLastPage = data.numberOfElements ?? 0 < 10
                self.totalPage = (data.totalPages ?? 0) - 1
            }
        }
    }
    
    func loadMoreContents() {
        page += 1
        fetchContents()
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
