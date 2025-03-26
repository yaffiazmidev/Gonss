//
//  ChannelDetailModel.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 31/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import Foundation
import RxSwift
import RxCocoa

enum ChannelDetailModel {
  
  enum Request {
    case doSomething(item: Int)
		case requestDetailPost(postId: String)
  }
  
  enum Response {
    case doSomething(newItem: Int, isItem: Bool)
  }
  
  enum ViewModel {
    case doSomething(viewModelData: NSObject)
  }
  
  enum Route {
		case selectedComment(id: String, item: Feed)
		case shared(text: String)
		case showProfile(id: String, type: String)
	
  }
  
  struct DataSource: DataSourceable {
    //var test: Int
		var id: String?
		var feed: Feed?
		var channelId: String?
  }
}
