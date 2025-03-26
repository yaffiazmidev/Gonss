//
//  ChannelSearchHashtagModel.swift
//  KipasKipas
//
//  Created by movan on 04/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation

enum ChannelSearchHashtagModel {
    
    enum Request {
        case searchHashtag(text: String)
    }
    
    enum Response {
        case hashtag(data: HashtagResult)
        case hashtagError(message: String)
    }
    
    enum ViewModel {
        case hashtag(viewModel: [Hashtag])
        case hashtagError(message: String)
    }
    
    enum Route {
        case dismissChannelSearchHashtagScene
        case showHashtag(_ tag: String)
    }
    
    struct DataSource: DataSourceable {
        var data: [Hashtag]?
        var text: String?
    }
}
