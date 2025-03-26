//
//  RxCommentNetworkModel.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 24/02/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift

public final class RxCommentNetworkModel {
	private let network: Network<CommentResult>


	init(network: Network<CommentResult>) {
		self.network = network
	}

	func getComments(id: String, page: Int) -> Observable<CommentResult> {
		let endpoint = FeedEndpoint.comments(id: id, page: page)
		return network.getItems(endpoint.path, parameters: endpoint.parameter)
	}
}
