//
//  PostModel.swift
//  Persada
//
//  Created by NOOR on 30/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import Foundation
import UIKit
import KipasKipasShared

enum PostModel {
	
	enum Request {
		case uploadVideo(path: String)
		case postSocial(with: ParameterPostSocial)
		case postProduct(with: ParameterPostProduct)
        case uploadMedia
	}
	
	enum Response {
		case media(ResultData<[ResponseMedia]>)
		case responsePost(ResultData<DefaultResponse>)
	}
	
	enum ViewModel {
		case media(viewModel: ResponseMedia)
		case post(viewModel: DefaultResponse)
		case error(_ err: ErrorMessage?)
	}
	
	enum Route {
		case gallery(_ index: Int)
        case preview(_ index: Int, _ itemMedias: [KKMediaItem], _ responseMedias: [ResponseMedia])
		case chooseChannel
		case back
        case dismiss
	}
	
	struct DataSource: DataSourceable {
		var isCreateFeed: Bool = false
		var channel: Channel?
        var product: Product?
		var typePost: String? = "social"
		var nameItem: String?
		var priceItem: String = "0"
		var lengthItem: String = "0"
		var widthItem: String = "0"
		var weightItem: String = "0"
		var heightItem: String = "0"
		var description: String?
		var pathMedia: String?
		var pathImages: [String?] = []
        var itemMedias: [KKMediaItem]? = []
		var imagesPath: [String] = []
		var responseMedias: [ResponseMedia]? = []
		var paramStatusSocial: ParameterPostSocial?
		var paramStatusProduct: ParameterPostProduct?
	}
}
