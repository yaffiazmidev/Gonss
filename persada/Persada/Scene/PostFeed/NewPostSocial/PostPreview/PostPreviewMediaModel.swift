//
//  PostPreviewMediaModel.swift
//  Persada
//
//  Created by movan on 10/07/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import KipasKipasShared

enum PostPreviewMediaModel {
	
	enum Request {
		case doSomething(item: Int)
	}
	
	enum Response {
		case doSomething(newItem: Int, isItem: Bool)
	}
	
	enum ViewModel {
		case doSomething(viewModelData: NSObject)
	}
	
	enum Route {
		case dismissPostPreviewMediaScene
		case remove(index: Int)
		case change(index: Int)
	}
	
	struct DataSource: DataSourceable {
        var itemMedias : [KKMediaItem] = []
		var responseMedias: [ResponseMedia] = []
	}
}
