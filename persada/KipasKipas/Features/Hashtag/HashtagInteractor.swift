//
//  HashtagInteractor.swift
//  KipasKipas
//
//  Created by DENAZMI on 19/08/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Kingfisher

protocol IHashtagInteractor: AnyObject {
    var page: Int { get set }
    var totalPage: Int { get set }
    var hashtag: String? { get set }
    
    func fetchHashtags()
    func prefetchImages(_ feeds: [Feed])
}

class HashtagInteractor: IHashtagInteractor {
    
    private let network: DataTransferService
    let presenter: IHashtagPresenter
    var page: Int = 0
    var totalPage: Int = 0
    var hashtag: String?
   
    
    init(presenter: IHashtagPresenter, network: DataTransferService) {
        self.presenter = presenter
        self.network = network
    }
    
    func fetchHashtags() {
        guard let value = hashtag, !value.isEmpty else { return }
        let request = Endpoint<FeedArray?>(with: HashtagAPIEndpoint.getHashtags(value: value, page: page))
        
        network.request(with: request) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
                self.presenter.presentHashtags(with: nil)
            case .success(let response):
                self.totalPage = (response?.data?.totalPages ?? 0) - 1
                self.presenter.presentHashtags(with: response)
            }
        }
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
                    urlValid = urlMediaPost + ossPerformance + OSSSizeImage.w720.rawValue
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
