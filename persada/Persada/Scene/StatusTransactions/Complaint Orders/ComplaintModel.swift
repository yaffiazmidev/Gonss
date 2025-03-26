//
//  ComplaintModel.swift
//  KipasKipas
//
//  Created by NOOR on 01/02/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import Foundation
import UIKit
import Combine
import KipasKipasShared

enum ComplaintModel {
	
	enum Request {
		case inputComplaint(data: ComplaintInput)
        case uploadPhoto(_ item: KKMediaItem)
		case uploadVideo(_ item: KKMediaItem)
	}
	
	enum Response {
		case complaint(result: DefaultResponse)
		case media(ResultData<ResponseMedia>)
	}
	
	enum ViewModel {
		case complaint(viewModel: DefaultResponse)
		case media(viewModel: ResponseMedia)
		case error(_ err: ErrorMessage?)
	}
	
	enum Route {
		case preview(_ images: UIImage, _ media: ResponseMedia)
		case dismissComplaintScene
		case confirmComplaint
	}
	
	class DataSource: DataSourceable {
		var id: String = ""
		var image: UIImage?
		var pathMedia: String = ""
		var media: ResponseMedia?
		var dataInputComplaint: ComplaintInput?
		@Published var reason: String = ""
	}
}

struct ComplaintInput: Encodable {
	var orderId: String
	var reason: String
	var evidenceVideoUrl: String
}
